part of 'bloc.dart';

final class WearableState extends Equatable {
  final bool isCollectingData;
  final Duration elapsed;
  final Map<String, File> availableFiles;
  final Duration sampleRate;

  const WearableState({
    this.isCollectingData = false,
    this.elapsed = const Duration(),
    this.availableFiles = const {},
    this.sampleRate = SensorInterval.normalInterval,
  });

  WearableState copyWith({
    bool? isCollectingData,
    Duration? elapsed,
    Map<String, File>? availableFiles,
    Duration? sampleRate,
  }) {
    return WearableState(
      isCollectingData: isCollectingData ?? this.isCollectingData,
      elapsed: elapsed ?? this.elapsed,
      availableFiles: availableFiles ?? this.availableFiles,
      sampleRate: sampleRate ?? this.sampleRate,
    );
  }

  @override
  List<Object> get props => [
        isCollectingData,
        elapsed,
        availableFiles,
        sampleRate,
      ];
}
