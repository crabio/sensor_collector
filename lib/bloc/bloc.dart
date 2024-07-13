import 'package:equatable/equatable.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensor_collector/repositories/sensor_collector.dart';
import 'package:sensor_collector/repositories/wear_os_connector.dart';

part 'event.dart';
part 'state.dart';

class SensorCollectorBloc
    extends Bloc<SensorCollectorEvent, SensorCollectorState> {
  SensorCollectorBloc() : super(const SensorCollectorState()) {
    on<PressCollectingButton>(_onPressCollectingButton);
    on<ElapsedTime>(_onElapsedTime);
  }

  final SensorCollectorService sensorCollectorService =
      SensorCollectorService();

  final WearOsConnector_wearOsConnector = WearOsConnector();

  late Ticker _ticker;

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
}
