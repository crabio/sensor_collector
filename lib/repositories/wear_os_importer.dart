import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:logger/web.dart';
import 'package:sensor_collector/repositories/wear_os_service.dart';

// Class for importing files from remote wearable device
class WearOsImporter extends WearOsService {
  final Logger _log = Logger();

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
      _log.d('No connected devices');
      return null;
    } else {
      for (var device in connectedDevices) {
        _log.d(
            'Check connected device: ${device.id} ${device.name} ${device.isNearby}');
        // Check that connected device has required DataItem
        if (await _deviceHasDataItem(device)) {
          _log.d(
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

  Stream<Map<String, File>> subscribeOnFilesUpdates(final WearOsDevice device) {
    final StreamController<Map<String, File>> streamController =
        StreamController(
      onCancel: () async => await flutterWearOsConnectivity.removeDataListener(
          pathURI: _dataItemUri(device)),
    );
    flutterWearOsConnectivity
        .dataChanged(pathURI: _dataItemUri(device))
        .listen((dataEvents) {
      for (final dataEvent in dataEvents) {
        streamController.add(dataEvent.dataItem.files);
      }
    });
    return streamController.stream;
  }

  Future<void> ackFileSynced(
      final WearOsDevice device, final String fileName) async {
    await flutterWearOsConnectivity.sendMessage(
      Uint8List.fromList(fileName.codeUnits),
      deviceId: device.id,
      path: "/sensor-collector-synced-file",
      priority: MessagePriority.low,
    );
    _log.d('Sent ack on synced file $fileName to device ${device.name}');
  }

  Uri _dataItemUri(final WearOsDevice device) {
    return Uri(
      scheme: "wear",
      host: device.id,
      path: "/sensor-collector",
    );
  }
}
