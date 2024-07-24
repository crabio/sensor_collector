import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:logging/logging.dart';
import 'package:sensor_collector/repositories/data_writer.dart';
import 'package:sensor_collector/repositories/sensor_collector.dart';
import 'package:sensor_collector/repositories/foreground_service.dart';
import 'package:sensor_collector/repositories/wear_os_importer.dart';

part 'event.dart';
part 'state.dart';

class SensorCollectorMobileBloc
    extends Bloc<SensorCollectorMobileEvent, SensorCollectorMobileState> {
  final Logger _log = Logger('SensorCollectorMobileBloc');
  late Ticker _ticker;

  final WearOsImporter _wearOsImporter = WearOsImporter();

  StreamSubscription<WearOsDevice>? _connectedDeviceSubscription;

  SensorCollectorMobileBloc() : super(const SensorCollectorMobileState()) {
    on<Init>(_onInit);
    on<PressCollectingButton>(_onPressCollectingButton);
    on<SyncWearFiles>(_onSyncWearFiles);
    on<ElapsedTime>(_onElapsedTime);
    on<WearDeviceConnected>(_onWearDeviceConnected);
    on<FileForSyncUpdate>(_onFileForSyncUpdate);

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
    ForegroundService.initForegroundTask();
    _startWaitConnectedDevice();
  }

  Future<void> _onPressCollectingButton(
    PressCollectingButton event,
    Emitter<SensorCollectorMobileState> emit,
  ) async {
    if (state.isCollectingData) {
      // Stop collecting data
      await ForegroundService.stopForegroundTask();
      _ticker.stop();
      emit(state.copyWith(isCollectingData: false));
    } else {
      // Start collecting data
      await ForegroundService.startForegroundTask((event) => add(event));
      _ticker = Ticker((elapsed) => add(ElapsedTime(elapsed)));
      _ticker.start();
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
    emit(
        state.copyWith(hasConnectedWearDevice: true, wearDevice: event.device));

    await _wearOsImporter
        .getFilesFromDevice(event.device)
        .then((filesMap) => add(FileForSyncUpdate(filesMap)));

    _wearOsImporter
        .subscribeOnFilesUpdates(event.device)
        .listen((filesMap) => add(FileForSyncUpdate(filesMap)));
  }

  void _onFileForSyncUpdate(
    FileForSyncUpdate event,
    Emitter<SensorCollectorMobileState> emit,
  ) {
    emit(state.copyWith(filesToSync: event.filesMap));
  }

  Future<void> _onSyncWearFiles(
    SyncWearFiles event,
    Emitter<SensorCollectorMobileState> emit,
  ) async {
    emit(state.copyWith(isSynInProgress: true));

    state.filesToSync.forEach((fileName, file) {
      DataWriterService.saveFileBytes(fileName, file);
      _wearOsImporter.ackFileSynced(state.wearDevice!, fileName);
    });

    emit(state.copyWith(isSynInProgress: false));
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
