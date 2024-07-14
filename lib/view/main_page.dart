import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensor_collector/bloc/bloc.dart';

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
                state.elapsed.toString().split(".")[0],
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
              state.isWeareable
                  ? Container()
                  : IconButton(
                      onPressed: !state.hasConnectedWearDevice &&
                              !state.hasWearDeviceFilesforSync
                          ? null
                          : () => print('Sync'),
                      icon: Icon(
                        state.hasConnectedWearDevice
                            ? state.hasWearDeviceFilesforSync
                                ? Icons.sync
                                : Icons.watch
                            : Icons.watch_off,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
