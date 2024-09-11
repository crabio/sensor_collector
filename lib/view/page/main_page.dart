import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';
import 'package:sensor_collector/bloc/mobile/bloc.dart';
import 'package:sensor_collector/bloc/wearable/bloc.dart';
import 'package:sensor_collector/view/page/mobile_page.dart';
import 'package:sensor_collector/view/page/wearable_page.dart';

class MainPage extends StatelessWidget {
  final Logger _log = Logger();
  final bool isWearable;

  MainPage(this.isWearable, {super.key});

  @override
  Widget build(BuildContext context) {
    if (isWearable) {
      _log.i('Run wearable app');
      return Scaffold(
        body: BlocProvider(
          create: (_) => WearableBloc(),
          child: WearablePage(),
        ),
      );
    } else {
      _log.i('Run mobile app');
      return BlocProvider(
        create: (_) => MobileBloc(),
        child: const MobilePage(),
      );
    }
  }
}
