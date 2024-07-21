import 'dart:async';
import 'package:logging/logging.dart';
import 'package:sensor_collector/repositories/data_writer.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ForegroundService {
  final Logger _log = Logger('ForegroundService');

  ForegroundService();

  static void _initForegroundTask() {
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
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  void startForegroundTask() {
    FlutterForegroundTask.startService(
      notificationTitle: 'Sensor Collector',
      notificationText: 'Collecting sensor data...',
      callback: start,
    );
  }

  void stopForegroundTask() {
    FlutterForegroundTask.stopService();
  }

  Future<void> requestPermissionForAndroid() async {
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

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SensorCollectorServiceTaskHandler());
}