import 'dart:typed_data';

import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:logging/logging.dart';

class WearOsConnector {
  final Logger _log = Logger('WearOsConnector');
  final FlutterWearOsConnectivity _flutterWearOsConnectivity =
      FlutterWearOsConnectivity();

  WearOsConnector() {
    _log.fine('Start');
    _flutterWearOsConnectivity.configureWearableAPI();
    Future.delayed(Duration.zero, () async {
      _flutterWearOsConnectivity.messageReceived().listen((message) {
        _log.fine(
            'New message from watch: ${String.fromCharCodes(message.data)}  ${message.path}');
      });

      List<WearOsDevice> connectedDevices =
          await _flutterWearOsConnectivity.getConnectedDevices();
      if (connectedDevices.isEmpty) {
        _log.fine('No connected smart watches');
      }
      for (WearOsDevice device in connectedDevices) {
        _log.fine(
            'Connected device: ${device.id} ${device.name} ${device.isNearby}');
        await _flutterWearOsConnectivity.sendMessage(
            Uint8List.fromList('Hello'.codeUnits),
            deviceId: device.id,
            path: "/test-message",
            priority: MessagePriority.low);
        _log.fine(
            'Sent message to connected device: ${device.id} ${device.name} ${device.isNearby}');
      }
      WearOsDevice localDevice =
          await _flutterWearOsConnectivity.getLocalDevice();
      _log.fine(
          'Local device: ${localDevice.id} ${localDevice.name} ${localDevice.isNearby}');

      List<DataItem> allDataItems =
          await _flutterWearOsConnectivity.getAllDataItems();
      if (allDataItems.isEmpty) {
        _log.fine('No available dataItems on smart watch');
      }
      for (DataItem datItem in allDataItems) {
        _log.fine('Available dataItem on smart watch: ${datItem.pathURI}');
      }
    });
  }
}
