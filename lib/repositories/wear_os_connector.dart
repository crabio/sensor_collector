import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:logging/logging.dart';

class WearOsConnector {
  final Logger _log = Logger('WearOsConnector');
  final FlutterWearOsConnectivity _flutterWearOsConnectivity =
      FlutterWearOsConnectivity();
  late Timer _scanTimer;
  final StreamController<List<WearOsDevice>> _connectedDevicesStreamController =
      StreamController();
  Stream<List<WearOsDevice>> get connectedDevicesStream =>
      _connectedDevicesStreamController.stream;
  final StreamController<List<DataItem>> _availableDataItemsStreamController =
      StreamController();
  Stream<List<DataItem>> get availableDataItemsStream =>
      _availableDataItemsStreamController.stream;

  Future<void> init() async {
    await _flutterWearOsConnectivity.configureWearableAPI();
  }

  void startScan() => _scanTimer =
      Timer.periodic(const Duration(seconds: 5), (timer) => scan());
  void stopScan() => _scanTimer.cancel();

  Future<void> scan() async {
    List<WearOsDevice> connectedDevices =
        await _flutterWearOsConnectivity.getConnectedDevices();
    _connectedDevicesStreamController.add(connectedDevices);
    if (connectedDevices.isEmpty) {
      _log.fine('No connected devices');
    } else {
      for (var device in connectedDevices) {
        _log.fine(
            'Connected device: ${device.id} ${device.name} ${device.isNearby}');
      }
    }

    if (connectedDevices.isNotEmpty) {
      for (var device in connectedDevices) {
        _log.fine('Scan DataItems from device ${device.id} ${device.name}');
        final Uri dataItemWildcard = Uri(
          scheme: "wear",
          host: device.id,
          path: "/sensor-collector",
        );
        List<DataItem> dataItems = await _flutterWearOsConnectivity
            .findDataItemsOnURIPath(pathURI: dataItemWildcard);
        _availableDataItemsStreamController.add(dataItems);
        if (dataItems.isEmpty) {
          _log.fine('No avaialble data items');
        } else {
          for (var dataItem in dataItems) {
            _log.fine(
                'Data item: ${dataItem.pathURI} ${dataItem.mapData} ${dataItem.files}');
          }
        }
      }
    }
  }

  Future<void> startExportDataItems() async {
    DataItem? dataItem = await _flutterWearOsConnectivity.syncData(
      path: "/sensor-collector",
      data: {
        "message":
            "Data sync by AndroidOS app on /data-path at ${DateTime.now().millisecondsSinceEpoch}"
      },
      isUrgent: false,
    );
    _log.fine(
        'Export data item: ${dataItem!.pathURI} ${dataItem.mapData} ${dataItem.files}');
  }
}
