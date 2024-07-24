import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:sensor_collector/models/foreground_service_events.dart';
import 'package:sensor_collector/repositories/data_writer.dart';
import 'package:sensor_collector/repositories/sensor_collector.dart';

class SensorCollectorServiceTaskHandler extends TaskHandler {
  final _log = Logger('SensorCollectorServiceTaskHandler');

  final DataWriterService dataWriterService = DataWriterService();
  late SensorCollectorService sensorCollectorService =
      SensorCollectorService(dataWriterService);
  late StreamSubscription<File> _dataWriterServiceStreamSubscription;
  late Timer _timer;
  final DateTime _startedAt = DateTime.now();

  SensorCollectorServiceTaskHandler();

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _log.info('SensorCollectorServiceTaskHandler.onStart');

    // Create new files listener
    _dataWriterServiceStreamSubscription = dataWriterService.dataFilesStream
        .listen((file) =>
            sendPort?.send(ForegroundServiceEvent.newDataFile(file).toJson()));
    _startTimer(sendPort);
    // Start sensor collection
    sensorCollectorService.start();
    _log.info('SensorCollectorServiceTaskHandler started');
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _log.info('SensorCollectorServiceTaskHandler.onDestroy');
    _timer.cancel();
    await sensorCollectorService.stop();
    await _dataWriterServiceStreamSubscription.cancel();
    _log.info('SensorCollectorServiceTaskHandler.onDestroy exit');
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    _log.info(
        'SensorCollectorServiceTaskHandler.onRepeatEvent: NotImplemented');
  }

  void _startTimer(final SendPort? sendPort) {
    _timer = Timer(const Duration(seconds: 1), () {
      final Duration elapsed = DateTime.now().difference(_startedAt);
      _log.info('SensorCollectorServiceTaskHandler.ticker elapsed=$elapsed');
      sendPort?.send(ForegroundServiceEvent.elapsedTime(elapsed).toJson());
      FlutterForegroundTask.updateService(
        notificationTitle: 'Sensor Collector',
        notificationText: elapsed.toString().split(".")[0],
      );
      _startTimer(sendPort);
    });
  }
}
