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

// Event will be sent, when supported device observed
final class WearDeviceConnected extends SensorCollectorMobileEvent {
  final WearOsDevice device;

  const WearDeviceConnected(this.device);

  @override
  List<Object> get props => [device];
}

final class NewDataFileForSync extends SensorCollectorMobileEvent {
  final File file;
  final String fileName;

  const NewDataFileForSync(this.file, this.fileName);

  @override
  List<Object> get props => [file, fileName];
}
