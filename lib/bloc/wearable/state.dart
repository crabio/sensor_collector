part of 'bloc.dart';

final class WearableState extends Equatable {
  final bool isCollectingData;
  final Duration elapsed;
  final Map<String, File> availableFiles;

  const WearableState({
    this.isCollectingData = false,
    this.elapsed = const Duration(),
    this.availableFiles = const {},
  });

  WearableState copyWith({
    bool? isCollectingData,
    Duration? elapsed,
    Map<String, File>? availableFiles,
  }) {
    return WearableState(
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
