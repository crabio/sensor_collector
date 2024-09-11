import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensor_collector/bloc/mobile/bloc.dart';
import 'package:sensor_collector/models/sample_rate.dart';

class MobileSettingsPage extends StatelessWidget {
  final MobileState state;

  const MobileSettingsPage(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('Collecting settings'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sample Rate:'),
            const SizedBox(width: 10),
            SampleRateDropDown(state.sampleRate),
          ],
        ),
      ],
    );
  }
}

class SampleRateDropDown extends StatelessWidget {
  final Duration sampleRate;

  const SampleRateDropDown(this.sampleRate, {super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: sampleRateToString[sampleRate],
      onChanged: (sampleRateName) => context
          .read<MobileBloc>()
          .add(ChangeSampleRate(sampleRateFromString[sampleRateName]!)),
      items: const [
        DropdownMenuItem<String>(
          value: 'normal',
          child: Text('Normal (200ms)'),
        ),
        DropdownMenuItem<String>(
          value: 'ui',
          child: Text('UI (66.66ms)'),
        ),
        DropdownMenuItem<String>(
          value: 'game',
          child: Text('Game (20ms)'),
        ),
        DropdownMenuItem<String>(
          value: 'fastest',
          child: Text('Fastest (0ms)'),
        ),
      ],
    );
  }
}
