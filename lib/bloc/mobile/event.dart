part of 'bloc.dart';

sealed class SensorCollectorMobileEvent extends Equatable {
  const SensorCollectorMobileEvent();

  @override
  List<Object> get props => [];
}

final class Init extends SensorCollectorMobileEvent {}

final class PressCollectingButton extends SensorCollectorMobileEvent {}

final class ElapsedTime extends SensorCollectorMobileEvent {
  final Duration elapsed;

  const ElapsedTime(this.elapsed);

  @override
  List<Object> get props => [elapsed];
}

final class NewConnectedDevice extends SensorCollectorMobileEvent {
  final List<WearOsDevice> devices;

  const NewConnectedDevice(this.devices);

  @override
  List<Object> get props => [devices];
}

final class NewDataFileForSync extends SensorCollectorMobileEvent {
  final File file;

  const NewDataFileForSync(this.file);

  @override
  List<Object> get props => [file];
}
