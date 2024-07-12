import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/data/sensor_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DataWriterService {
  final Logger _log = Logger('DataWriterService');

  late Timer _timer;

  final Set<DateTime> _collectedDts = {};
  final Map<DateTime, UserAccelerometerEvent> _userAccelerometerBuffer = {};
  final Map<DateTime, AccelerometerEvent> _accelerometerBuffer = {};
  final Map<DateTime, GyroscopeEvent> _gyroscopeBuffer = {};
  final Map<DateTime, MagnetometerEvent> _magnetometerBuffer = {};

  DataWriterService();

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

  void flushCollectedData() {
    _log.fine('Flush data');

    final outputFile = File('out.dat');
    final outputFileSink = outputFile.openWrite();

    outputFileSink.add(SensorData.csvHeader().codeUnits);

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
      outputFileSink.add(sensorData.toCsv().codeUnits);
    }
    // Flush file
    outputFileSink.flush();

    outputFileSink.close();

    // Delete saved data
    _log.fine('Saved ${_collectedDts.length} timestamps samples');
    for (DateTime dt in collectedDtsBuffer) {
      _collectedDts.remove(dt);
      _userAccelerometerBuffer.remove(dt);
      _accelerometerBuffer.remove(dt);
      _gyroscopeBuffer.remove(dt);
      _magnetometerBuffer.remove(dt);
    }
  }

  void start() {
    _timer = Timer.periodic(
        const Duration(seconds: 1), (timer) => flushCollectedData());
  }

  void stop() {
    _timer.cancel();
    // Flush data saved in buffer
    flushCollectedData();
  }
}
