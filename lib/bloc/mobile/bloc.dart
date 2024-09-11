import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:logger/web.dart';
import 'package:sensor_collector/models/foreground_service_events.dart';
import 'package:sensor_collector/models/sample_rate.dart';
import 'package:sensor_collector/repositories/data_writer.dart';
import 'package:sensor_collector/repositories/foreground_service.dart';
import 'package:sensor_collector/repositories/wear_os_importer.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'event.dart';
part 'state.dart';

class MobileBloc extends Bloc<MobileEvent, MobileState> {
  final Logger _log = Logger();
  final WearOsImporter _wearOsImporter = WearOsImporter();

  StreamSubscription<WearOsDevice>? _connectedDeviceSubscription;

  MobileBloc() : super(const MobileState()) {
    on<Init>(_onInit);
    on<PressCollectingButton>(_onPressCollectingButton);
    on<SyncWearFiles>(_onSyncWearFiles);
    on<ElapsedTime>(_onElapsedTime);
    on<WearDeviceConnected>(_onWearDeviceConnected);
    on<FileForSyncUpdate>(_onFileForSyncUpdate);
    on<PressSettingsButton>(_onPressSettingsButton);
    on<ChangeSampleRate>(_onChangeSampleRate);
    on<EventFromForegroundService>(_onEventFromForegroundService);

    // Start init
    add(Init());
  }

  @override
  Future<void> close() async {
    _stopWaitConnectedDevice();
    return super.close();
  }

  void _foregroundServiceOnReceiveDataCallback(dynamic jsonData) {
    add(EventFromForegroundService(ForegroundServiceEvent.fromJson(jsonData)));
  }

  Future<void> _onInit(
    Init event,
    Emitter<MobileState> emit,
  ) async {
    await _wearOsImporter.init();
    ForegroundService.initForegroundTask();
    _startWaitConnectedDevice();
    // Check we have already running foreground service
    if (await ForegroundService.isRunningService()) {
      _log.i('Foreground service is running');
      emit(state.copyWith(isCollectingData: true));
      await ForegroundService.joinForegroundTask(
          _foregroundServiceOnReceiveDataCallback);
    }
  }

  Future<void> _onPressCollectingButton(
    PressCollectingButton event,
    Emitter<MobileState> emit,
  ) async {
    if (state.isCollectingData) {
      // Stop collecting data
      await ForegroundService.stopForegroundTask();
      emit(state.copyWith(isCollectingData: false));
    } else {
      // Start collecting data
      await ForegroundService.startForegroundTask(
          _foregroundServiceOnReceiveDataCallback);
      emit(state.copyWith(isCollectingData: true, elapsed: const Duration()));
    }
  }

  void _onElapsedTime(
    ElapsedTime event,
    Emitter<MobileState> emit,
  ) {
    emit(state.copyWith(elapsed: event.elapsed));
  }

  Future<void> _onWearDeviceConnected(
    WearDeviceConnected event,
    Emitter<MobileState> emit,
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
    Emitter<MobileState> emit,
  ) {
    emit(state.copyWith(filesToSync: event.filesMap));
  }

  Future<void> _onSyncWearFiles(
    SyncWearFiles event,
    Emitter<MobileState> emit,
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

  void _onPressSettingsButton(
    PressSettingsButton event,
    Emitter<MobileState> emit,
  ) {
    emit(state.copyWith(isSettingsOpen: !state.isSettingsOpen));
  }

  Future<void> _onChangeSampleRate(
    ChangeSampleRate event,
    Emitter<MobileState> emit,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sampleRate', sampleRateToString[event.sampleRate]!);
    emit(state.copyWith(sampleRate: event.sampleRate));
  }

  Future<void> _onEventFromForegroundService(
    EventFromForegroundService event,
    Emitter<MobileState> emit,
  ) async {
    switch (event.event.type) {
      case ForegroundServiceEventType.elapsedTime:
        final elapsedTimeEvent = event.event.elapsedTime!;
        add(ElapsedTime(elapsedTimeEvent.elapsed));
        break;
      case ForegroundServiceEventType.newDataFile:
        // ignore
        break;
      default:
        throw Exception(
            'Unknown DataFromForegroundService data type: ${event.event.runtimeType}');
    }
  }
}
