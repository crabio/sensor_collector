part of 'bloc.dart';

sealed class MobileEvent extends Equatable {
  const MobileEvent();

  @override
  List<Object> get props => [];
}

final class Init extends MobileEvent {}

final class PressCollectingButton extends MobileEvent {}

final class PressSettingsButton extends MobileEvent {}

final class SyncWearFiles extends MobileEvent {}

final class ElapsedTime extends MobileEvent {
  final Duration elapsed;

  const ElapsedTime(this.elapsed);

  @override
  List<Object> get props => [elapsed];
}

// Event will be sent, when supported device observed
final class WearDeviceConnected extends MobileEvent {
  final WearOsDevice device;

  const WearDeviceConnected(this.device);

  @override
  List<Object> get props => [device];
}

final class FileForSyncUpdate extends MobileEvent {
  final Map<String, File> filesMap;

  const FileForSyncUpdate(this.filesMap);

  @override
  List<Object> get props => [filesMap];
}

final class EventFromForegroundService extends MobileEvent {
  final ForegroundServiceEvent event;

  const EventFromForegroundService(this.event);

  @override
  List<Object> get props => [event];
}

final class ChangeSampleRate extends MobileEvent {
  final Duration sampleRate;

  const ChangeSampleRate(this.sampleRate);

  @override
  List<Object> get props => [sampleRate];
}
