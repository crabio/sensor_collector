import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensor_collector/bloc/wearable/bloc.dart';
import 'package:sensor_collector/view/widget/elapsed_timer.dart';
import 'package:sensor_collector/view/widget/start_collect_btn.dart';

class WearableMainPage extends StatelessWidget {
  final WearableState state;

  const WearableMainPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElapsedTimerWidget(state.elapsed),
          const SizedBox(height: 20),
          StartCollectButton(
            () => context.read<WearableBloc>().add(PressCollectingButton()),
            state.isCollectingData,
          ),
        ],
      ),
    );
  }
}
