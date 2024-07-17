part of 'bloc.dart';

sealed class SensorCollectorWearableEvent extends Equatable {
  const SensorCollectorWearableEvent();

  @override
  List<Object> get props => [];
}

final class Init extends SensorCollectorWearableEvent {}

final class PressCollectingButton extends SensorCollectorWearableEvent {}

final class ElapsedTime extends SensorCollectorWearableEvent {
  final Duration elapsed;

  const ElapsedTime(this.elapsed);

  @override
  List<Object> get props => [elapsed];
}

final class NewDataFile extends SensorCollectorWearableEvent {
  final File file;
  final String fileName;

  const NewDataFile(this.file, this.fileName);

  @override
  List<Object> get props => [file, fileName];
}

final class FileSyncAck extends SensorCollectorWearableEvent {
  final String fileName;

  const FileSyncAck(this.fileName);

  @override
  List<Object> get props => [fileName];
}
