import 'dart:async';
import 'dart:io';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/repositories/wear_os_service.dart';

// Class for importing files from remote wearable device
class WearOsImporter extends WearOsService {
  final Logger _log = Logger('WearOsConnectorImporter');
  late Timer _scanTimer;
  final StreamController<List<WearOsDevice>> _connectedDevicesStreamController =
      StreamController();
  Stream<List<WearOsDevice>> get connectedDevicesStream =>
      _connectedDevicesStreamController.stream;
  final StreamController<File> _availableDownstreamFileController =
      StreamController();
  Stream<File> get availableDownstreamFileStream =>
      _availableDownstreamFileController.stream;
  final Map<String, File> availableFilesForSync = {};

  void startScan() => _scanTimer =
      Timer.periodic(const Duration(seconds: 5), (timer) => scan());
  void stopScan() => _scanTimer.cancel();

  Future<void> scan() async {
    List<WearOsDevice> connectedDevices =
        await flutterWearOsConnectivity.getConnectedDevices();
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
        _scanDataItems(device);
      }
    }
  }

  Future<void> _scanDataItems(final WearOsDevice device) async {
    _log.fine('Scan DataItems from device ${device.id} ${device.name}');
    final Uri dataItemWildcard = Uri(
      scheme: "wear",
      host: device.id,
      path: "/sensor-collector",
    );
    List<DataItem> dataItems = await flutterWearOsConnectivity
        .findDataItemsOnURIPath(pathURI: dataItemWildcard);
    if (dataItems.isEmpty) {
      _log.fine('No avaialble data items');
    } else {
      for (final file in dataItems[0].files.values) {
        _availableDownstreamFileController.add(file);
      }
      for (var dataItem in dataItems) {
        _log.fine(
            'Data item: ${dataItem.pathURI} ${dataItem.mapData} ${dataItem.files}');
      }
    }
  }
}
