import 'dart:async';
import 'dart:io';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/repositories/wear_os_service.dart';

// Class for importing files from remote wearable device
class WearOsImporter extends WearOsService {
  final Logger _log = Logger('WearOsConnectorImporter');

  Stream<WearOsDevice> waitDevice() {
    late Timer scanTimer;
    final StreamController<WearOsDevice> streamController = StreamController(
      onCancel: () => scanTimer.cancel(),
    );
    scanTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final device = await _scan();
      if (device != null) {
        streamController.add(device);
        timer.cancel();
      }
    });

    return streamController.stream;
  }

  Future<WearOsDevice?> _scan() async {
    List<WearOsDevice> connectedDevices =
        await flutterWearOsConnectivity.getConnectedDevices();
    if (connectedDevices.isEmpty) {
      _log.fine('No connected devices');
      return null;
    } else {
      for (var device in connectedDevices) {
        _log.fine(
            'Check connected device: ${device.id} ${device.name} ${device.isNearby}');
        // Check that connected device has required DataItem
        if (await _deviceHasDataItem(device)) {
          _log.fine(
              'Found supported device: ${device.id} ${device.name} ${device.isNearby}');
          return device;
        }
      }
    }
    return null;
  }

  Future<bool> _deviceHasDataItem(final WearOsDevice device) async {
    List<DataItem> dataItems = await flutterWearOsConnectivity
        .findDataItemsOnURIPath(pathURI: _dataItemUri(device));
    return dataItems.isNotEmpty;
  }

  Future<Map<String, File>> getFilesFromDevice(
      final WearOsDevice device) async {
    List<DataItem> dataItems = await flutterWearOsConnectivity
        .findDataItemsOnURIPath(pathURI: _dataItemUri(device));
    return dataItems.first.files;
  }

  Stream<Map<String, File>> subscribeOnNewFiles(final WearOsDevice device) {
    final StreamController<Map<String, File>> streamController =
        StreamController(
      onCancel: () async => await flutterWearOsConnectivity.removeDataListener(
          pathURI: _dataItemUri(device)),
    );
    flutterWearOsConnectivity.dataChanged(pathURI: _dataItemUri(device)).listen(
        (dataEvents) => dataEvents.forEach(
            (dataEvent) => streamController.add(dataEvent.dataItem.files)));
    return streamController.stream;
  }

  Uri _dataItemUri(final WearOsDevice device) {
    return Uri(
      scheme: "wear",
      host: device.id,
      path: "/sensor-collector",
    );
  }
}
