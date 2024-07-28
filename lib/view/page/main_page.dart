import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/bloc/mobile/bloc.dart';
import 'package:sensor_collector/bloc/wearable/bloc.dart';
import 'package:sensor_collector/view/page/mobile_page.dart';
import 'package:sensor_collector/view/page/wearable_page.dart';

class MainPage extends StatelessWidget {
  final Logger _log = Logger('SensorCollectorBlocProvider');
  final bool isWearable;

  MainPage(this.isWearable, {super.key});

  @override
  Widget build(BuildContext context) {
    if (isWearable) {
      _log.info('Run wearable app');
      return Scaffold(
        body: BlocProvider(
          create: (_) => SensorCollectorWearableBloc(),
          child: const SensorCollectorWearablePage(),
        ),
      );
    } else {
      _log.info('Run mobile app');
      return Scaffold(
        body: BlocProvider(
          create: (_) => SensorCollectorMobileBloc(),
          child: const SensorCollectorMobilePage(),
        ),
      );
    }
  }
}
