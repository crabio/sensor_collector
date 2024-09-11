part of 'bloc.dart';

sealed class WearableEvent extends Equatable {
  const WearableEvent();

  @override
  List<Object> get props => [];
}

final class Init extends WearableEvent {}

final class PressCollectingButton extends WearableEvent {}

final class ElapsedTime extends WearableEvent {
  final Duration elapsed;

  const ElapsedTime(this.elapsed);

  @override
  List<Object> get props => [elapsed];
}

final class NewDataFile extends WearableEvent {
  final File file;
  final String fileName;

  const NewDataFile(this.file, this.fileName);

  @override
  List<Object> get props => [file, fileName];
}

final class FileSyncAck extends WearableEvent {
  final String fileName;

  const FileSyncAck(this.fileName);

  @override
  List<Object> get props => [fileName];
}

final class EventFromForegroundService extends WearableEvent {
  final ForegroundServiceEvent event;

  const EventFromForegroundService(this.event);

  @override
  List<Object> get props => [event];
}

final class ChangeSampleRate extends WearableEvent {
  final Duration sampleRate;

  const ChangeSampleRate(this.sampleRate);

  @override
  List<Object> get props => [sampleRate];
}
