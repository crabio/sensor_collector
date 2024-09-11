import 'dart:async';
import 'package:logger/web.dart';
import 'package:sensor_collector/repositories/data_writer.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorCollectorService {
  final Logger _log = Logger();

  final DataWriterService dataWriterService;

  late StreamSubscription<UserAccelerometerEvent> _userAccelerometerStream;
  late StreamSubscription<AccelerometerEvent> _accelerometerStream;
  late StreamSubscription<GyroscopeEvent> _gyroscopeStream;
  late StreamSubscription<MagnetometerEvent> _magnetometerStream;

  SensorCollectorService(this.dataWriterService);

  void start([Duration sensorInterval = SensorInterval.normalInterval]) {
    _log.i('Start. sensorInterval=$sensorInterval');
    _userAccelerometerStream =
        userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
      _userAccelerometerEventHandler,
      onError: _userAccelerometerErrorHandler,
      cancelOnError: true,
    );
    _accelerometerStream =
        accelerometerEventStream(samplingPeriod: sensorInterval).listen(
      _accelerometerEventHandler,
      onError: _accelerometerErrorHandler,
      cancelOnError: true,
    );
    _gyroscopeStream =
        gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
      _gyroscopeEventHandler,
      onError: _gyroscopeErrorHandler,
      cancelOnError: true,
    );
    _magnetometerStream =
        magnetometerEventStream(samplingPeriod: sensorInterval).listen(
      _magnetometerEventHandler,
      onError: _magnetometerErrorHandler,
      cancelOnError: true,
    );
    dataWriterService.start();
  }

  Future<void> stop() async {
    _log.i('Stop');
    await _userAccelerometerStream.cancel();
    await _accelerometerStream.cancel();
    await _gyroscopeStream.cancel();
    await _magnetometerStream.cancel();
    await dataWriterService.stop();
  }

  void _userAccelerometerEventHandler(UserAccelerometerEvent event) {
    dataWriterService.addUserAccelerometerEvent(DateTime.now(), event);
  }

  void _userAccelerometerErrorHandler(Object err) {
    _log.e("ERROR - User Accelerometer Error: ${err.toString()}");
  }

  void _accelerometerEventHandler(AccelerometerEvent event) {
    dataWriterService.addAccelerometerEvent(DateTime.now(), event);
  }

  void _accelerometerErrorHandler(Object err) {
    _log.e("ERROR - Accelerometer Error: ${err.toString()}");
  }

  void _gyroscopeEventHandler(GyroscopeEvent event) {
    dataWriterService.addGyroscopeEvent(DateTime.now(), event);
  }

  void _gyroscopeErrorHandler(Object err) {
    _log.e("ERROR - Gyroscope Error: ${err.toString()}");
  }

  void _magnetometerEventHandler(MagnetometerEvent event) {
    dataWriterService.addMagnetometerEvent(DateTime.now(), event);
  }

  void _magnetometerErrorHandler(Object err) {
    _log.e("ERROR - Magnetometer Error: ${err.toString()}");
  }
}
