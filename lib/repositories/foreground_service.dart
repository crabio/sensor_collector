import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/repositories/sensor_collector_foreground_task.dart';
import 'package:sensor_collector/utils/log.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // Init logger for foreground service
  initLogger(level: Level.FINE);
  FlutterForegroundTask.setTaskHandler(SensorCollectorServiceTaskHandler());
}

class ForegroundService {
  static void initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'sensor_collector',
        channelName: 'Sensor Collector Notification',
        channelDescription: 'Collecting sensor data...',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        isOnceEvent: true,
        autoRunOnBoot: true,
      ),
    );
  }

  static Future<void> startForegroundTask(
      void Function(dynamic event) onReceiveData) async {
    print('${DateTime.now()} startForegroundTask');
    if (await FlutterForegroundTask.isRunningService) {
      throw Exception('FlutterForegroundTask is already running');
    }

    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    if (receivePort == null) {
      throw Exception('FlutterForegroundTask has no receivePort');
    }
    print('receivePort = $receivePort');
    receivePort.listen(onReceiveData);

    final requestResult = await FlutterForegroundTask.startService(
      notificationTitle: 'Sensor Collector',
      notificationText: 'Collecting sensor data...',
      callback: startCallback,
    );
    if (!requestResult.success) {
      throw Exception(
          "Couldn't start FlutterForegroundTask: ${requestResult.error}");
    }
    print('${DateTime.now()} started ForegroundTask');
  }

  static Future<void> stopForegroundTask() async {
    print('stopForegroundTask');
    await FlutterForegroundTask.stopService();
  }

  static Future<void> requestPermission() async {
    if (!Platform.isAndroid) {
      return;
    }

    // Android 12 or higher, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }
}
