import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/bloc/mobile/bloc.dart';
import 'package:sensor_collector/bloc/wearable/bloc.dart';
import 'package:sensor_collector/utils/platform.dart';
import 'package:sensor_collector/view/page/mobile_page.dart';
import 'package:sensor_collector/view/page/wearable_page.dart';

Future<void> main() async {
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  runApp(SensorCollectorApp(await isWearable()));
}

class SensorCollectorApp extends StatelessWidget {
  final Logger _log = Logger('SensorCollectorApp');
  final bool isWearable;

  SensorCollectorApp(this.isWearable, {super.key});

  @override
  Widget build(BuildContext context) {
    if (isWearable) {
      _log.info('Run wearable app');
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => SensorCollectorWearableBloc(),
            child: const SensorCollectorWearablePage(),
          ),
        ),
      );
    } else {
      _log.info('Run mobile app');
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create: (_) => SensorCollectorMobileBloc(),
            child: const SensorCollectorMobilePage(),
          ),
        ),
      );
    }
  }
}
