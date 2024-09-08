import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensor_collector/bloc/mobile/bloc.dart';
import 'package:sensor_collector/view/widget/elapsed_timer.dart';
import 'package:sensor_collector/view/widget/start_collect_btn.dart';

class MobileMainPage extends StatelessWidget {
  final MobileState state;

  const MobileMainPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElapsedTimerWidget(state.elapsed),
          const SizedBox(height: 20),
          StartCollectButton(
            () => context.read<MobileBloc>().add(PressCollectingButton()),
            state.isCollectingData,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              state.isSynInProgress
                  ? const CircularProgressIndicator()
                  : IconButton(
                      onPressed: !state.hasConnectedWearDevice &&
                              state.filesToSync.isEmpty
                          ? null
                          : () =>
                              context.read<MobileBloc>().add(SyncWearFiles()),
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
  }
}
