import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/service/sensor_collector.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Timer App',
      home: TimerApp(),
    );
  }
}

class TimerApp extends StatefulWidget {
  const TimerApp({super.key});

  @override
  _TimerAppState createState() => _TimerAppState();
}

class _TimerAppState extends State<TimerApp> {
  bool isRunning = false;
  Stopwatch stopwatch = Stopwatch();
  late Timer _timer;
  final SensorCollectorService scs = SensorCollectorService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              stopwatch.elapsed.toString(),
              style: const TextStyle(fontSize: 48.0),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isRunning ? _stopCollect() : _startCollect();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isRunning ? Colors.red : Colors.green,
              ),
              child: Text(isRunning ? 'Stop' : 'Start'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (isRunning) {
      stopwatch.stop();
    }
  }

  void _startCollect() {
    isRunning = true;
    stopwatch.reset();
    stopwatch.start();
    scs.start(SensorInterval.fastestInterval);
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      setState(() {});
    });
  }

  void _stopCollect() {
    isRunning = false;
    stopwatch.stop();
    scs.stop();
    _timer.cancel();
  }
}
