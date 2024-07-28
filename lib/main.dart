import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/repositories/foreground_service.dart';
import 'package:sensor_collector/utils/log.dart';
import 'package:sensor_collector/utils/platform.dart';
import 'package:sensor_collector/view/page/main_page.dart';

Future<void> main() async {
  initLogger(level: Level.FINE);

  WidgetsFlutterBinding.ensureInitialized();

  // Request required permissions
  await ForegroundService.requestPermission();

  runApp(SensorCollectorApp(await isWearable()));
}

class SensorCollectorApp extends StatelessWidget {
  final bool isWearable;

  const SensorCollectorApp(this.isWearable, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WithForegroundTask(
        child: MainPage(isWearable),
      ),
    );
  }
}
