import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensor_collector/bloc/mobile/bloc.dart';
import 'package:sensor_collector/view/page/mobile/main_page.dart';
import 'package:sensor_collector/view/page/mobile/settings_page.dart';

class MobilePage extends StatefulWidget {
  const MobilePage({super.key});

  @override
  State<MobilePage> createState() => _MobilePageState();
}

class _MobilePageState extends State<MobilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MobileBloc, MobileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: state.isCollectingData
                    ? null
                    : () =>
                        context.read<MobileBloc>().add(PressSettingsButton()),
              ),
            ],
          ),
          body: state.isSettingsOpen
              ? MobileSettingsPage(state)
              : MobileMainPage(state),
        );
      },
    );
  }
}
