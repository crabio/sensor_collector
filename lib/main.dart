import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/bloc/mobile/bloc.dart';
import 'package:sensor_collector/bloc/wearable/bloc.dart';
import 'package:sensor_collector/repositories/foreground_service.dart';
import 'package:sensor_collector/utils/log.dart';
import 'package:sensor_collector/utils/platform.dart';
import 'package:sensor_collector/view/page/mobile_page.dart';
import 'package:sensor_collector/view/page/wearable_page.dart';

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
        child: Scaffold(
          body: SensorCollectorBlocProvider(isWearable),
        ),
      ),
    );
  }
}

class SensorCollectorBlocProvider extends StatelessWidget {
  final Logger _log = Logger('SensorCollectorBlocProvider');
  final bool isWearable;

  SensorCollectorBlocProvider(this.isWearable, {super.key});

  @override
  Widget build(BuildContext context) {
    if (isWearable) {
      _log.info('Run wearable app');
      return BlocProvider(
        create: (_) => SensorCollectorWearableBloc(),
        child: const SensorCollectorWearablePage(),
      );
    } else {
      _log.info('Run mobile app');
      return BlocProvider(
        create: (_) => SensorCollectorMobileBloc(),
        child: const SensorCollectorMobilePage(),
      );
    }
  }
}
