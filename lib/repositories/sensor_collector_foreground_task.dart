import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/scheduler.dart';
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
    _dataWriterServiceStreamSubscription =
        dataWriterService.dataFilesStream.listen((file) {
      _log.fine(
          'SensorCollectorServiceTaskHandler.dataFilesStream.send file=${basename(file.path)}');
      sendPort?.send(
          ForegroundServiceEvent.newDataFile(file, basename(file.path))
              .toJson());
    });
    _startTimer(sendPort);
    // Start sensor collection
    // TODO sensorCollectorService.start();
    _log.info('SensorCollectorServiceTaskHandler started');
  }

  // Called when the task is destroyed.
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _log.info('SensorCollectorServiceTaskHandler.onDestroy');
    _timer.cancel();
    // TODO sensorCollectorService.stop();
    _dataWriterServiceStreamSubscription.cancel();
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
