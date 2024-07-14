part of 'bloc.dart';

sealed class SensorCollectorEvent extends Equatable {
  const SensorCollectorEvent();

  @override
  List<Object> get props => [];
}

final class Init extends SensorCollectorEvent {}

final class PressCollectingButton extends SensorCollectorEvent {}

final class ElapsedTime extends SensorCollectorEvent {
  final Duration elapsed;

  const ElapsedTime(this.elapsed);

  @override
  List<Object> get props => [elapsed];
}

final class UpdateConnectedDevices extends SensorCollectorEvent {
  final List<WearOsDevice> devices;

  const UpdateConnectedDevices(this.devices);

  @override
  List<Object> get props => [devices];
}

final class UpdateAvailableDataItems extends SensorCollectorEvent {
  final List<DataItem> dataItems;

  const UpdateAvailableDataItems(this.dataItems);

  @override
  List<Object> get props => [dataItems];
}
