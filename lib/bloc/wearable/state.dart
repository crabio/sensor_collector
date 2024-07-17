part of 'bloc.dart';

final class SensorCollectorWearableState extends Equatable {
  final bool isCollectingData;
  final Duration elapsed;
  final Map<String, File> availableFiles;

  const SensorCollectorWearableState({
    this.isCollectingData = false,
    this.elapsed = const Duration(),
    this.availableFiles = const {},
  });

  SensorCollectorWearableState copyWith({
    bool? isCollectingData,
    Duration? elapsed,
    Map<String, File>? availableFiles,
  }) {
    return SensorCollectorWearableState(
      isCollectingData: isCollectingData ?? this.isCollectingData,
      elapsed: elapsed ?? this.elapsed,
      availableFiles: availableFiles ?? this.availableFiles,
    );
  }

  @override
  List<Object> get props => [
        isCollectingData,
        elapsed,
        availableFiles,
      ];
}
