import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:sensor_collector/repositories/data_writer.dart';
import 'package:sensor_collector/repositories/sensor_collector.dart';
import 'package:sensor_collector/repositories/wear_os_exporter.dart';

part 'event.dart';
part 'state.dart';

class SensorCollectorWearableBloc
    extends Bloc<SensorCollectorWearableEvent, SensorCollectorWearableState> {
  final DataWriterService dataWriterService = DataWriterService();
  late SensorCollectorService sensorCollectorService;
  late Ticker _ticker;

  final WearOsExporter _wearOsExporter = WearOsExporter();

  SensorCollectorWearableBloc() : super(const SensorCollectorWearableState()) {
    on<Init>(_onInit);
    on<PressCollectingButton>(_onPressCollectingButton);
    on<ElapsedTime>(_onElapsedTime);
    on<NewDataFile>(_onNewDataFile);

    dataWriterService.dataFilesStream.listen((file) => add(NewDataFile(file)));

    // Init late
    sensorCollectorService = SensorCollectorService(dataWriterService);
    // Start init
    add(Init());
  }

  Future<void> _onInit(
    Init event,
    Emitter<SensorCollectorWearableState> emit,
  ) async {
    // On wearable device init exporter
    await _wearOsExporter.init();
    await dataWriterService.init();
    _wearOsExporter.exportDataItems();
  }

  void _onPressCollectingButton(
    PressCollectingButton event,
    Emitter<SensorCollectorWearableState> emit,
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
    Emitter<SensorCollectorWearableState> emit,
  ) {
    emit(state.copyWith(elapsed: event.elapsed));
  }

  void _onNewDataFile(
    NewDataFile event,
    Emitter<SensorCollectorWearableState> emit,
  ) {
    _wearOsExporter.availableFiles[basename(event.file.path)] = event.file;
    _wearOsExporter.exportDataItems();
  }
}
