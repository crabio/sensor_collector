import 'package:sensors_plus/sensors_plus.dart';

final Map<Duration, String> sampleRateToString = {
  SensorInterval.normalInterval: 'normal',
  SensorInterval.uiInterval: 'ui',
  SensorInterval.gameInterval: 'game',
  SensorInterval.fastestInterval: 'fastest',
};

final Map<String, Duration> sampleRateFromString = {
  'normal': SensorInterval.normalInterval,
  'ui': SensorInterval.uiInterval,
  'game': SensorInterval.gameInterval,
  'fastest': SensorInterval.fastestInterval,
};
