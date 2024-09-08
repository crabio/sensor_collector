import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';
import 'package:path/path.dart';
import 'package:sensor_collector/models/foreground_service_events.dart';
import 'package:sensor_collector/repositories/data_writer.dart';
import 'package:sensor_collector/repositories/foreground_service.dart';
import 'package:sensor_collector/repositories/wear_os_exporter.dart';

part 'event.dart';
part 'state.dart';

class WearableBloc extends Bloc<WearableEvent, WearableState> {
  final Logger _log = Logger();
  final WearOsExporter _wearOsExporter = WearOsExporter();

  WearableBloc() : super(const WearableState()) {
    on<Init>(_onInit);
    on<PressCollectingButton>(_onPressCollectingButton);
    on<ElapsedTime>(_onElapsedTime);
    on<NewDataFile>(_onNewDataFile);
    on<FileSyncAck>(_onFileSyncAck);
    on<EventFromForegroundService>(_onEventFromForegroundService);

    // Start init
    add(Init());
  }

  void _foregroundServiceOnReceiveDataCallback(dynamic jsonData) {
    add(EventFromForegroundService(ForegroundServiceEvent.fromJson(jsonData)));
  }

  Future<void> _onInit(
    Init event,
    Emitter<WearableState> emit,
  ) async {
    // On wearable device init exporter
    await _wearOsExporter.init();
    // Read existed files
    for (final file in await DataWriterService.listAvailableDataFiles()) {
      add(NewDataFile(file, basename(file.path)));
    }
    ForegroundService.initForegroundTask();
    _wearOsExporter.exportDataItems({});
    _wearOsExporter
        .subscribeOnFileSyncAck()
        .listen((fileName) => add(FileSyncAck(fileName)));
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
    Emitter<WearableState> emit,
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
    Emitter<WearableState> emit,
  ) {
    emit(state.copyWith(elapsed: event.elapsed));
  }

  void _onNewDataFile(
    NewDataFile event,
    Emitter<WearableState> emit,
  ) {
    final Map<String, File> availableFiles = {};
    availableFiles.addAll(state.availableFiles);
    if (!availableFiles.containsKey(event.fileName)) {
      availableFiles[event.fileName] = event.file;
    }
    emit(state.copyWith(availableFiles: availableFiles));
    _wearOsExporter.exportDataItems(availableFiles);
  }

  Future<void> _onFileSyncAck(
    FileSyncAck event,
    Emitter<WearableState> emit,
  ) async {
    final Map<String, File> availableFiles = {};
    availableFiles.addAll(state.availableFiles);
    availableFiles.remove(event.fileName);
    await File(state.availableFiles[event.fileName]!.path).delete();
    emit(state.copyWith(availableFiles: availableFiles));
    _wearOsExporter.exportDataItems(availableFiles);
  }

  Future<void> _onEventFromForegroundService(
    EventFromForegroundService event,
    Emitter<WearableState> emit,
  ) async {
    switch (event.event.type) {
      case ForegroundServiceEventType.elapsedTime:
        final elapsedTimeEvent = event.event.elapsedTime!;
        add(ElapsedTime(elapsedTimeEvent.elapsed));
        break;
      case ForegroundServiceEventType.newDataFile:
        final newDataFileEvent = event.event.newDataFile!;
        add(NewDataFile(
          newDataFileEvent.file,
          basename(newDataFileEvent.file.path),
        ));
        break;
      default:
        throw Exception(
            'Unknown DataFromForegroundService data type: ${event.event.runtimeType}');
    }
  }
}
