import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/bloc/bloc.dart';
import 'package:sensor_collector/view/main_page.dart';

void main() {
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const SensorCollectorApp());
}

class SensorCollectorApp extends StatelessWidget {
  const SensorCollectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider(
          create: (_) => SensorCollectorBloc(),
          child: const SensorCollectorPage(),
        ),
      ),
    );
  }
}
