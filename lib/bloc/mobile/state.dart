part of 'bloc.dart';

final class MobileState extends Equatable {
  final bool isWeareable;
  final bool isCollectingData;
  final bool isSettingsOpen;
  final Duration elapsed;
  final bool hasConnectedWearDevice;
  final WearOsDevice? wearDevice;
  final Map<String, File> filesToSync;
  final bool isSynInProgress;
  final Duration sampleRate;

  const MobileState({
    this.isWeareable = false,
    this.isCollectingData = false,
    this.isSettingsOpen = false,
    this.elapsed = const Duration(),
    this.hasConnectedWearDevice = false,
    this.wearDevice,
    this.filesToSync = const {},
    this.isSynInProgress = false,
    this.sampleRate = SensorInterval.normalInterval,
  });

  MobileState copyWith({
    bool? isWeareable,
    bool? isCollectingData,
    bool? isSettingsOpen,
    Duration? elapsed,
    bool? hasConnectedWearDevice,
    WearOsDevice? wearDevice,
    Map<String, File>? filesToSync,
    bool? isSynInProgress,
    Duration? sampleRate,
  }) {
    return MobileState(
      isWeareable: isWeareable ?? this.isWeareable,
      isCollectingData: isCollectingData ?? this.isCollectingData,
      isSettingsOpen: isSettingsOpen ?? this.isSettingsOpen,
      elapsed: elapsed ?? this.elapsed,
      hasConnectedWearDevice:
          hasConnectedWearDevice ?? this.hasConnectedWearDevice,
      wearDevice: wearDevice ?? this.wearDevice,
      filesToSync: filesToSync ?? this.filesToSync,
      isSynInProgress: isSynInProgress ?? this.isSynInProgress,
      sampleRate: sampleRate ?? this.sampleRate,
    );
  }

  @override
  List<Object> get props => [
        isWeareable,
        isCollectingData,
        isSettingsOpen,
        elapsed,
        hasConnectedWearDevice,
        filesToSync,
        isSynInProgress,
        sampleRate,
      ];
}
