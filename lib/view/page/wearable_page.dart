import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensor_collector/bloc/wearable/bloc.dart';
import 'package:sensor_collector/view/widget/elapsed_timer.dart';
import 'package:sensor_collector/view/widget/start_collect_btn.dart';
import 'package:wear_plus/wear_plus.dart';

class WearablePage extends StatelessWidget {
  const WearablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WearableBloc, WearableState>(
      builder: (context, state) {
        return WatchShape(
          builder: (BuildContext context, WearShape shape, Widget? child) {
            return AmbientMode(
              builder: (context, mode, child) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElapsedTimerWidget(state.elapsed),
                      const SizedBox(height: 20),
                      StartCollectButton(
                        () => context
                            .read<WearableBloc>()
                            .add(PressCollectingButton()),
                        state.isCollectingData,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
