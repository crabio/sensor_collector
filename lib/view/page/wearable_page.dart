import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensor_collector/bloc/wearable/bloc.dart';
import 'package:sensor_collector/view/page/wear/main_page.dart';
import 'package:sensor_collector/view/page/wear/settings_page.dart';
import 'package:wear_plus/wear_plus.dart';

class WearablePage extends StatelessWidget {
  final PageController _verticalPageViewController = PageController();

  WearablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WearableBloc, WearableState>(
      builder: (context, state) {
        return WatchShape(
          builder: (BuildContext context, WearShape shape, Widget? child) {
            return AmbientMode(
              builder: (context, mode, child) {
                return PageView(
                  scrollDirection: Axis.vertical,
                  controller: _verticalPageViewController,
                  children: <Widget>[
                    WearableMainPage(state),
                    WearableSettingsPage(state),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
