import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensor_collector/bloc/mobile/bloc.dart';
import 'package:sensor_collector/view/widget/elapsed_timer.dart';
import 'package:sensor_collector/view/widget/start_collect_btn.dart';

class SensorCollectorMobilePage extends StatefulWidget {
  const SensorCollectorMobilePage({super.key});

  @override
  State<SensorCollectorMobilePage> createState() =>
      _SensorCollectorMobilePageState();
}

class _SensorCollectorMobilePageState extends State<SensorCollectorMobilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorCollectorMobileBloc, SensorCollectorMobileState>(
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElapsedTimerWidget(state.elapsed),
              const SizedBox(height: 20),
              StartCollectButton(
                () => context
                    .read<SensorCollectorMobileBloc>()
                    .add(PressCollectingButton()),
                state.isCollectingData,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: !state.hasConnectedWearDevice &&
                            state.filesToSync.isEmpty
                        ? null
                        : () => print('Sync'),
                    // TODO Implement sync
                    icon: Icon(
                      state.hasConnectedWearDevice
                          ? state.filesToSync.isNotEmpty
                              ? Icons.sync
                              : Icons.watch
                          : Icons.watch_off,
                    ),
                  ),
                  Text(state.filesToSync.length.toString()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
