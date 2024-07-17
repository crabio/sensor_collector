import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:sensor_collector/repositories/data_writer.dart';
import 'package:sensor_collector/repositories/sensor_collector.dart';
import 'package:sensor_collector/repositories/wear_os_importer.dart';

part 'event.dart';
part 'state.dart';

class SensorCollectorMobileBloc
    extends Bloc<SensorCollectorMobileEvent, SensorCollectorMobileState> {
  final DataWriterService dataWriterService = DataWriterService();
  late SensorCollectorService sensorCollectorService;
  late Ticker _ticker;

  final WearOsImporter _wearOsImporter = WearOsImporter();

  SensorCollectorMobileBloc() : super(const SensorCollectorMobileState()) {
    on<Init>(_onInit);
    on<PressCollectingButton>(_onPressCollectingButton);
    on<ElapsedTime>(_onElapsedTime);
    on<NewConnectedDevice>(_onNewConnectedDevice);
    on<NewDataFileForSync>(_onNewDataFileForSync);

    _wearOsImporter.connectedDevicesStream
        .listen((devices) => add(NewConnectedDevice(devices)));
    _wearOsImporter.availableDownstreamFileStream
        .listen((file) => add(NewDataFileForSync(file)));

    // Init late
    sensorCollectorService = SensorCollectorService(dataWriterService);
    // Start init
    add(Init());
  }

  @override
  Future<void> close() async {
    _wearOsImporter.stopScan();
    return super.close();
  }

  Future<void> _onInit(
    Init event,
    Emitter<SensorCollectorMobileState> emit,
  ) async {
    await _wearOsImporter.init();
    _wearOsImporter.startScan();
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

  void _onNewConnectedDevice(
    NewConnectedDevice event,
    Emitter<SensorCollectorMobileState> emit,
  ) {
    emit(state.copyWith(hasConnectedWearDevice: event.devices.isNotEmpty));
  }

  void _onNewDataFileForSync(
    NewDataFileForSync event,
    Emitter<SensorCollectorMobileState> emit,
  ) {
    emit(state.copyWith(filesToSync: state.filesToSync + 1));
  }
}
