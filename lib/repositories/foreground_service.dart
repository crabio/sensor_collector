import 'dart:async';
import 'dart:io';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:logger/web.dart';
import 'package:sensor_collector/repositories/sensor_collector_foreground_task.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // Init logger for foreground service
  Logger.level = Level.debug;
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
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.once(),
        autoRunOnBoot: true,
      ),
    );
  }

  static Future<bool> isRunningService() async {
    return await FlutterForegroundTask.isRunningService;
  }

  static Future<void> startForegroundTask(
      void Function(dynamic event) onReceiveData) async {
    if (await FlutterForegroundTask.isRunningService) {
      throw Exception('FlutterForegroundTask is already running');
    }

    // Initialize port for communication between TaskHandler and UI.
    FlutterForegroundTask.initCommunicationPort();
    // Register onReceiveData callback
    FlutterForegroundTask.addTaskDataCallback(onReceiveData);

    final requestResult = await FlutterForegroundTask.startService(
      notificationTitle: 'Sensor Collector',
      notificationText: 'Collecting sensor data...',
      callback: startCallback,
    );
    if (!requestResult.success) {
      throw Exception(
          "Couldn't start FlutterForegroundTask: ${requestResult.error}");
    }
  }

  static Future<void> joinForegroundTask(
      void Function(dynamic event) onReceiveData) async {
    if (!await FlutterForegroundTask.isRunningService) {
      throw Exception('FlutterForegroundTask is not running');
    }

    // Initialize port for communication between TaskHandler and UI.
    FlutterForegroundTask.initCommunicationPort();
    // Register onReceiveData callback
    FlutterForegroundTask.addTaskDataCallback(onReceiveData);

    final requestResult =
        await FlutterForegroundTask.updateService(callback: startCallback);
    if (!requestResult.success) {
      throw Exception(
          "Couldn't update FlutterForegroundTask: ${requestResult.error}");
    }
  }

  static Future<void> stopForegroundTask() async {
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
