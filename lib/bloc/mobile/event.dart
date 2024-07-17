part of 'bloc.dart';

sealed class SensorCollectorMobileEvent extends Equatable {
  const SensorCollectorMobileEvent();

  @override
  List<Object> get props => [];
}

final class Init extends SensorCollectorMobileEvent {}

final class PressCollectingButton extends SensorCollectorMobileEvent {}

final class SyncWearFiles extends SensorCollectorMobileEvent {}

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

final class FileForSyncUpdate extends SensorCollectorMobileEvent {
  final Map<String, File> filesMap;

  const FileForSyncUpdate(this.filesMap);

  @override
  List<Object> get props => [filesMap];
}
