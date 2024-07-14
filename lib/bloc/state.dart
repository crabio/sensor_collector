part of 'bloc.dart';

final class SensorCollectorState extends Equatable {
  final bool isWeareable;
  final bool isCollectingData;
  final Duration elapsed;
  final bool hasConnectedWearDevice;
  final bool hasWearDeviceFilesforSync;

  const SensorCollectorState({
    this.isWeareable = false,
    this.isCollectingData = false,
    this.elapsed = const Duration(),
    this.hasConnectedWearDevice = false,
    this.hasWearDeviceFilesforSync = false,
  });

  SensorCollectorState copyWith({
    bool? isWeareable,
    bool? isCollectingData,
    Duration? elapsed,
    bool? hasConnectedWearDevice,
    bool? hasWearDeviceFilesforSync,
  }) {
    return SensorCollectorState(
      isWeareable: isWeareable ?? this.isWeareable,
      isCollectingData: isCollectingData ?? this.isCollectingData,
      elapsed: elapsed ?? this.elapsed,
      hasConnectedWearDevice:
          hasConnectedWearDevice ?? this.hasConnectedWearDevice,
      hasWearDeviceFilesforSync:
          hasWearDeviceFilesforSync ?? this.hasWearDeviceFilesforSync,
    );
  }

  @override
  List<Object> get props => [
        isWeareable,
        isCollectingData,
        elapsed,
        hasConnectedWearDevice,
        hasWearDeviceFilesforSync,
      ];
}
