part of 'bloc.dart';

final class SensorCollectorMobileState extends Equatable {
  final bool isWeareable;
  final bool isCollectingData;
  final Duration elapsed;
  final bool hasConnectedWearDevice;
  final WearOsDevice? wearDevice;
  final Map<String, File> filesToSync;
  final bool isSynInProgress;

  const SensorCollectorMobileState({
    this.isWeareable = false,
    this.isCollectingData = false,
    this.elapsed = const Duration(),
    this.hasConnectedWearDevice = false,
    this.wearDevice,
    this.filesToSync = const {},
    this.isSynInProgress = false,
  });

  SensorCollectorMobileState copyWith({
    bool? isWeareable,
    bool? isCollectingData,
    Duration? elapsed,
    bool? hasConnectedWearDevice,
    WearOsDevice? wearDevice,
    Map<String, File>? filesToSync,
    bool? isSynInProgress,
  }) {
    return SensorCollectorMobileState(
      isWeareable: isWeareable ?? this.isWeareable,
      isCollectingData: isCollectingData ?? this.isCollectingData,
      elapsed: elapsed ?? this.elapsed,
      hasConnectedWearDevice:
          hasConnectedWearDevice ?? this.hasConnectedWearDevice,
      wearDevice: wearDevice ?? this.wearDevice,
      filesToSync: filesToSync ?? this.filesToSync,
      isSynInProgress: isSynInProgress ?? this.isSynInProgress,
    );
  }

  @override
  List<Object> get props => [
        isWeareable,
        isCollectingData,
        elapsed,
        hasConnectedWearDevice,
        filesToSync,
        isSynInProgress,
      ];
}
