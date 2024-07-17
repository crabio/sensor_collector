import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensor_collector/bloc/wearable/bloc.dart';
import 'package:sensor_collector/view/widget/elapsed_timer.dart';
import 'package:sensor_collector/view/widget/start_collect_btn.dart';

class SensorCollectorWearablePage extends StatefulWidget {
  const SensorCollectorWearablePage({super.key});

  @override
  State<SensorCollectorWearablePage> createState() =>
      _SensorCollectorWearablePageState();
}

class _SensorCollectorWearablePageState
    extends State<SensorCollectorWearablePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorCollectorWearableBloc,
        SensorCollectorWearableState>(
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElapsedTimerWidget(state.elapsed),
              const SizedBox(height: 20),
              StartCollectButton(
                () => context
                    .read<SensorCollectorWearableBloc>()
                    .add(PressCollectingButton()),
                state.isCollectingData,
              ),
            ],
          ),
        );
      },
    );
  }
}
