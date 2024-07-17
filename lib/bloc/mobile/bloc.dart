import 'dart:async';
import 'dart:io';
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:sensor_collector/repositories/data_writer.dart';
import 'package:sensor_collector/repositories/sensor_collector.dart';
import 'package:sensor_collector/repositories/wear_os_importer.dart';

part 'event.dart';
part 'state.dart';

class SensorCollectorMobileBloc
    extends Bloc<SensorCollectorMobileEvent, SensorCollectorMobileState> {
  final Logger _log = Logger('SensorCollectorMobileBloc');
  final DataWriterService dataWriterService = DataWriterService();
  late SensorCollectorService sensorCollectorService;
  late Ticker _ticker;

  final WearOsImporter _wearOsImporter = WearOsImporter();

  StreamSubscription<WearOsDevice>? _connectedDeviceSubscription;
  StreamSubscription<Map<String, File>>? _filesForSyncSubscription;

  SensorCollectorMobileBloc() : super(const SensorCollectorMobileState()) {
    on<Init>(_onInit);
    on<PressCollectingButton>(_onPressCollectingButton);
    on<ElapsedTime>(_onElapsedTime);
    on<WearDeviceConnected>(_onWearDeviceConnected);
    on<NewDataFileForSync>(_onNewDataFileForSync);

    // Init late
    sensorCollectorService = SensorCollectorService(dataWriterService);
    // Start init
    add(Init());
  }

  @override
  Future<void> close() async {
    _stopWaitConnectedDevice();
    return super.close();
  }

  Future<void> _onInit(
    Init event,
    Emitter<SensorCollectorMobileState> emit,
  ) async {
    await _wearOsImporter.init();
    _startWaitConnectedDevice();
  }

  void _onPressCollectingButton(
    PressCollectingButton event,
    Emitter<SensorCollectorMobileState> emit,
  ) {
    if (state.isCollectingData) {
      // Stop collecting data
      _ticker.stop();
      sensorCollectorService.stop();
      emit(state.copyWith(isCollectingData: false));
    } else {
      // Start collecting data
      _ticker = Ticker((elapsed) => add(ElapsedTime(elapsed)));
      _ticker.start();
      sensorCollectorService.start();
      // scs.start(SensorInterval.fastestInterval);
      emit(state.copyWith(isCollectingData: true, elapsed: const Duration()));
    }
  }

  void _onElapsedTime(
    ElapsedTime event,
    Emitter<SensorCollectorMobileState> emit,
  ) {
    emit(state.copyWith(elapsed: event.elapsed));
  }

  Future<void> _onWearDeviceConnected(
    WearDeviceConnected event,
    Emitter<SensorCollectorMobileState> emit,
  ) async {
    _stopWaitConnectedDevice();
    emit(state.copyWith(hasConnectedWearDevice: true));

    await _wearOsImporter.getFilesFromDevice(event.device).then((filesMap) =>
        filesMap.forEach(
            (fileName, file) => add(NewDataFileForSync(file, fileName))));

    _filesForSyncSubscription = _wearOsImporter
        .subscribeOnNewFiles(event.device)
        .listen((filesForSync) => filesForSync.forEach(
            (fileName, file) => add(NewDataFileForSync(file, fileName))));
  }

  void _onNewDataFileForSync(
    NewDataFileForSync event,
    Emitter<SensorCollectorMobileState> emit,
  ) {
    final Map<String, File> filesToSync = {};
    filesToSync.addAll(state.filesToSync);
    if (!filesToSync.containsKey(event.fileName)) {
      filesToSync[event.fileName] = event.file;
    }
    _log.fine('NewDataFileForSync. filesToSync=${filesToSync}');

    emit(state.copyWith(filesToSync: filesToSync));
  }

  void _startWaitConnectedDevice() {
    _connectedDeviceSubscription = _wearOsImporter
        .waitDevice()
        .listen((device) => add(WearDeviceConnected(device)));
  }

  void _stopWaitConnectedDevice() {
    _connectedDeviceSubscription?.cancel();
  }
}
