import 'dart:async';
import 'dart:io';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/repositories/wear_os_service.dart';

// Class for exporting files from remote wearable device
class WearOsExporter extends WearOsService {
  final Logger _log = Logger('WearOsConnectorExporter');
  final Map<String, File> availableFiles = {};

  Future<void> exportDataItems() async {
    DataItem? dataItem = await flutterWearOsConnectivity.syncData(
      path: "/sensor-collector",
      data: {
        "filesToSync": availableFiles.length,
      },
      isUrgent: false,
      files: availableFiles,
    );
    _log.fine(
        'Export data item: ${dataItem!.pathURI} ${dataItem.mapData} ${dataItem.files}');
  }
}
