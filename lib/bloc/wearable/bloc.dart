import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:sensor_collector/models/foreground_service_events.dart';
import 'package:sensor_collector/repositories/data_writer.dart';
import 'package:sensor_collector/repositories/foreground_service.dart';
import 'package:sensor_collector/repositories/wear_os_exporter.dart';

part 'event.dart';
part 'state.dart';

class SensorCollectorWearableBloc
    extends Bloc<SensorCollectorWearableEvent, SensorCollectorWearableState> {
  final Logger _log = Logger('SensorCollectorWearableBloc');
  final WearOsExporter _wearOsExporter = WearOsExporter();

  SensorCollectorWearableBloc() : super(const SensorCollectorWearableState()) {
    on<Init>(_onInit);
    on<PressCollectingButton>(_onPressCollectingButton);
    on<ElapsedTime>(_onElapsedTime);
    on<NewDataFile>(_onNewDataFile);
    on<FileSyncAck>(_onFileSyncAck);
    on<EventFromForegroundService>(_onEventFromForegroundService);

    // Start init
    add(Init());
  }

  Future<void> _onInit(
    Init event,
    Emitter<SensorCollectorWearableState> emit,
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
    // TODO On running service at start we can;t join to it's channel
    if (await ForegroundService.isRunningService()) {
      _log.info('Foreground service is running');
      emit(state.copyWith(isCollectingData: true));
    }
  }

  Future<void> _onPressCollectingButton(
    PressCollectingButton event,
    Emitter<SensorCollectorWearableState> emit,
  ) async {
    if (state.isCollectingData) {
      // Stop collecting data
      await ForegroundService.stopForegroundTask();
      emit(state.copyWith(isCollectingData: false));
    } else {
      // Start collecting data
      await ForegroundService.startForegroundTask((eventJson) => add(
          EventFromForegroundService(
              ForegroundServiceEvent.fromJson(eventJson))));
      emit(state.copyWith(isCollectingData: true, elapsed: const Duration()));
    }
  }

  void _onElapsedTime(
    ElapsedTime event,
    Emitter<SensorCollectorWearableState> emit,
  ) {
    emit(state.copyWith(elapsed: event.elapsed));
  }

  void _onNewDataFile(
    NewDataFile event,
    Emitter<SensorCollectorWearableState> emit,
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
    Emitter<SensorCollectorWearableState> emit,
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
    Emitter<SensorCollectorWearableState> emit,
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
