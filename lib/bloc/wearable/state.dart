part of 'bloc.dart';

final class SensorCollectorWearableState extends Equatable {
  final bool isCollectingData;
  final Duration elapsed;

  const SensorCollectorWearableState({
    this.isCollectingData = false,
    this.elapsed = const Duration(),
  });

  SensorCollectorWearableState copyWith({
    bool? isCollectingData,
    Duration? elapsed,
    bool? hasConnectedWearDevice,
    int? filesToSync,
  }) {
    return SensorCollectorWearableState(
      isCollectingData: isCollectingData ?? this.isCollectingData,
      elapsed: elapsed ?? this.elapsed,
    );
  }

  @override
  List<Object> get props => [
        isCollectingData,
        elapsed,
      ];
}
