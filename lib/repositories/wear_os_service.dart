import 'dart:async';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';

class WearOsService {
  final FlutterWearOsConnectivity flutterWearOsConnectivity =
      FlutterWearOsConnectivity();

  Future<void> init() async {
    await flutterWearOsConnectivity.configureWearableAPI();
  }
}
