import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensor_collector/bloc/mobile/bloc.dart';

class StartCollectButton extends StatelessWidget {
  final bool isCollectingData;

  const StartCollectButton(this.isCollectingData, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context
          .read<SensorCollectorMobileBloc>()
          .add(PressCollectingButton()),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCollectingData ? Colors.red : Colors.green,
      ),
      child: Text(isCollectingData ? 'Stop' : 'Start'),
    );
  }
}
