import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/bloc/bloc.dart';

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

class SensorCollectorPage extends StatefulWidget {
  const SensorCollectorPage({super.key});

  @override
  State<SensorCollectorPage> createState() => _SensorCollectorPageState();
}

class _SensorCollectorPageState extends State<SensorCollectorPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorCollectorBloc, SensorCollectorState>(
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                state.elapsed.toString(),
                style: const TextStyle(fontSize: 48.0),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => context
                    .read<SensorCollectorBloc>()
                    .add(PressCollectingButton()),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      state.isCollectingData ? Colors.red : Colors.green,
                ),
                child: Text(state.isCollectingData ? 'Stop' : 'Start'),
              ),
            ],
          ),
        );
      },
    );
  }
}
