import 'package:flutter/material.dart';

class ElapsedTimerWidget extends StatelessWidget {
  final Duration elapsed;

  const ElapsedTimerWidget(this.elapsed, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      elapsed.toString().split(".")[0],
      style: const TextStyle(fontSize: 48.0),
    );
  }
}
