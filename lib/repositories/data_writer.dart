import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/models/sensor_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:path/path.dart' as p;
import 'package:mutex/mutex.dart';

class DataWriterService {
  final Logger _log = Logger('DataWriterService');
  final Set<DateTime> _collectedDts = {};
  final Map<DateTime, UserAccelerometerEvent> _userAccelerometerBuffer = {};
  final Map<DateTime, AccelerometerEvent> _accelerometerBuffer = {};
  final Map<DateTime, GyroscopeEvent> _gyroscopeBuffer = {};
  final Map<DateTime, MagnetometerEvent> _magnetometerBuffer = {};
  final Mutex _mu = Mutex();

  late Timer _timer;
  late Duration flushPeriod;
  late File _outputFile;
  late IOSink _outputFileSink;

  final StreamController<File> _dataFilesStreamController = StreamController();
  Stream<File> get dataFilesStream => _dataFilesStreamController.stream;

  DataWriterService({this.flushPeriod = const Duration(seconds: 1)});

  Future<void> init() async {
    // Add all available data files to the stream
    final availableDataFilesPaths = await _listAvailableDataFiles();
    for (var dataFilePath in availableDataFilesPaths) {
      _dataFilesStreamController.add(dataFilePath);
    }
  }

  void addUserAccelerometerEvent(DateTime dt, UserAccelerometerEvent event) {
    _collectedDts.add(dt);
    _userAccelerometerBuffer[dt] = event;
  }

  void addAccelerometerEvent(DateTime dt, AccelerometerEvent event) {
    _collectedDts.add(dt);
    _accelerometerBuffer[dt] = event;
  }

  void addGyroscopeEvent(DateTime dt, GyroscopeEvent event) {
    _collectedDts.add(dt);
    _gyroscopeBuffer[dt] = event;
  }

  void addMagnetometerEvent(DateTime dt, MagnetometerEvent event) {
    _collectedDts.add(dt);
    _magnetometerBuffer[dt] = event;
  }

  Future<void> flushCollectedData() async {
    _log.fine('Flush collected data');

    // Lock mutex to prevent parallel file write
    await _mu.acquire();

    final collectedDtsBuffer = Set.from(_collectedDts);
    for (DateTime dt in collectedDtsBuffer) {
      final sensorData = SensorData(
        dt,
        userAccelerometerEvent: _userAccelerometerBuffer[dt],
        accelerometerEvent: _accelerometerBuffer[dt],
        gyroscopeEvent: _gyroscopeBuffer[dt],
        magnetometerEvent: _magnetometerBuffer[dt],
      );

      // Write to csv file
      _outputFileSink.add(GZipCodec().encode(sensorData.toCsv().codeUnits));
    }
    // Flush file
    await _outputFileSink.flush();

    // Delete saved data
    for (DateTime dt in collectedDtsBuffer) {
      _collectedDts.remove(dt);
      _userAccelerometerBuffer.remove(dt);
      _accelerometerBuffer.remove(dt);
      _gyroscopeBuffer.remove(dt);
      _magnetometerBuffer.remove(dt);
    }

    _mu.release();
  }

  Future<void> start() async {
    // Create new file
    final filePath = await _generateFilePath();
    _outputFile = File(filePath);
    _outputFileSink = _outputFile.openWrite();
    // Write header in gzip
    _outputFileSink.add(GZipCodec().encode(SensorData.csvHeader().codeUnits));
    await _outputFileSink.flush();
    // Start periodic flush to file
    _timer = Timer.periodic(flushPeriod, (t) => flushCollectedData());
    _log.fine('Start periodic collected data flush. filePath = $filePath');
  }

  Future<void> stop() async {
    _log.fine('Stop periodic collected data flush');
    _timer.cancel();
    // Flush data saved in buffer
    await flushCollectedData();
    // Close file
    await _outputFileSink.close();
    // Send new file to the available data files stream
    _dataFilesStreamController.add(_outputFile);
  }

  static String _generateFileName() {
    final datetimeString = DateTime.now()
        .toIso8601String()
        .replaceAll("T", "-")
        .replaceAll(":", "-");
    return "sensor-data-$datetimeString.csv.gz";
  }

  static Future<Directory> _generateFileDirectory() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // downloads folder - android only - API>30
      return Directory('/storage/emulated/0/Download/SensorCollector');
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  static Future<String> _generateFilePath() async {
    final fileDir = await _generateFileDirectory();
    if (!await fileDir.exists()) {
      fileDir.create();
    }
    return p.join(fileDir.path, _generateFileName());
  }

  Future<List<File>> _listAvailableDataFiles() async {
    final directory = await _generateFileDirectory();
    return directory
        .list()
        .where((entity) => entity is File)
        .map((entity) => entity as File)
        .toList();
  }
}
