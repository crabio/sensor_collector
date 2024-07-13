part of 'bloc.dart';

final class SensorCollectorState extends Equatable {
  final bool isCollectingData;
  final Duration elapsed;

  const SensorCollectorState({
    this.isCollectingData = false,
    this.elapsed = const Duration(),
  });

  SensorCollectorState copyWith({
    bool? isCollectingData,
    Duration? elapsed,
  }) {
    return SensorCollectorState(
      isCollectingData: isCollectingData ?? this.isCollectingData,
      elapsed: elapsed ?? this.elapsed,
    );
  }

  @override
  List<Object> get props => [isCollectingData, elapsed];
}
