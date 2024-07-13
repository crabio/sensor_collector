part of 'bloc.dart';

sealed class SensorCollectorEvent extends Equatable {
  const SensorCollectorEvent();

  @override
  List<Object> get props => [];
}

final class PressCollectingButton extends SensorCollectorEvent {}

final class ElapsedTime extends SensorCollectorEvent {
  final Duration elapsed;

  const ElapsedTime(this.elapsed);

  @override
  List<Object> get props => [elapsed];
}
