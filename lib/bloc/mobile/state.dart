part of 'bloc.dart';

final class SensorCollectorMobileState extends Equatable {
  final bool isWeareable;
  final bool isCollectingData;
  final Duration elapsed;
  final bool hasConnectedWearDevice;
  final Map<String, File> filesToSync;

  const SensorCollectorMobileState({
    this.isWeareable = false,
    this.isCollectingData = false,
    this.elapsed = const Duration(),
    this.hasConnectedWearDevice = false,
    this.filesToSync = const {},
  });

  SensorCollectorMobileState copyWith({
    bool? isWeareable,
    bool? isCollectingData,
    Duration? elapsed,
    bool? hasConnectedWearDevice,
    Map<String, File>? filesToSync,
  }) {
    return SensorCollectorMobileState(
      isWeareable: isWeareable ?? this.isWeareable,
      isCollectingData: isCollectingData ?? this.isCollectingData,
      elapsed: elapsed ?? this.elapsed,
      hasConnectedWearDevice:
          hasConnectedWearDevice ?? this.hasConnectedWearDevice,
      filesToSync: filesToSync ?? this.filesToSync,
    );
  }

  @override
  List<Object> get props => [
        isWeareable,
        isCollectingData,
        elapsed,
        hasConnectedWearDevice,
        filesToSync,
      ];
}
