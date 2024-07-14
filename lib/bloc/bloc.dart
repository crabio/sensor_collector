import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';
import 'package:sensor_collector/repositories/sensor_collector.dart';
import 'package:sensor_collector/repositories/wear_os_connector.dart';

part 'event.dart';
part 'state.dart';

class SensorCollectorBloc
    extends Bloc<SensorCollectorEvent, SensorCollectorState> {
  final SensorCollectorService sensorCollectorService =
      SensorCollectorService();
  final WearOsConnector wearOsConnector = WearOsConnector();
  late Ticker _ticker;

  SensorCollectorBloc() : super(const SensorCollectorState()) {
    on<Init>(_onInit);
    on<PressCollectingButton>(_onPressCollectingButton);
    on<ElapsedTime>(_onElapsedTime);
    on<UpdateConnectedDevices>(_onUpdateConnectedDevices);
    on<UpdateAvailableDataItems>(_onUpdateAvailableDataItems);

    wearOsConnector.connectedDevicesStream
        .listen((devices) => add(UpdateConnectedDevices(devices)));
    wearOsConnector.availableDataItemsStream
        .listen((dataItems) => add(UpdateAvailableDataItems(dataItems)));

    add(Init());
  }

  @override
  Future<void> close() async {
    wearOsConnector.stopScan();
    return super.close();
  }

  Future<void> _onInit(
    Init event,
    Emitter<SensorCollectorState> emit,
  ) async {
    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
    final bool isWeareable =
        androidInfo.systemFeatures.contains('android.hardware.type.watch');
    emit(state.copyWith(isWeareable: isWeareable));

    await wearOsConnector.init();
    if (isWeareable) {
      wearOsConnector.startExportDataItems();
    } else {
      wearOsConnector.startScan();
    }
  }

  void _onPressCollectingButton(
    PressCollectingButton event,
    Emitter<SensorCollectorState> emit,
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
    Emitter<SensorCollectorState> emit,
  ) {
    emit(state.copyWith(elapsed: event.elapsed));
  }

  void _onUpdateConnectedDevices(
    UpdateConnectedDevices event,
    Emitter<SensorCollectorState> emit,
  ) {
    emit(state.copyWith(hasConnectedWearDevice: event.devices.isNotEmpty));
  }

  void _onUpdateAvailableDataItems(
    UpdateAvailableDataItems event,
    Emitter<SensorCollectorState> emit,
  ) {
    emit(state.copyWith(hasWearDeviceFilesforSync: event.dataItems.isNotEmpty));
  }
}
