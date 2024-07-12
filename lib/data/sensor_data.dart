import 'package:sensors_plus/sensors_plus.dart';

class SensorData {
  DateTime dt;
  UserAccelerometerEvent? userAccelerometerEvent;
  AccelerometerEvent? accelerometerEvent;
  GyroscopeEvent? gyroscopeEvent;
  MagnetometerEvent? magnetometerEvent;

  SensorData(
    this.dt, {
    this.userAccelerometerEvent,
    this.accelerometerEvent,
    this.gyroscopeEvent,
    this.magnetometerEvent,
  });

  static String csvHeader() {
    return 'dt,user_acc_x,user_acc_y,user_acc_z,acc_x,acc_y,acc_z,gyr_x,gyr_y,gyr_z,mag_x,mag_y,mag_z';
  }

  String toCsv() {
    return '${dt.millisecondsSinceEpoch.toString()}'
        ',${userAccelerometerEvent != null ? userAccelerometerEvent!.x.toString() : "null"}'
        ',${userAccelerometerEvent != null ? userAccelerometerEvent!.y.toString() : "null"}'
        ',${userAccelerometerEvent != null ? userAccelerometerEvent!.z.toString() : "null"}'
        ',${accelerometerEvent != null ? accelerometerEvent!.x.toString() : "null"}'
        ',${accelerometerEvent != null ? accelerometerEvent!.y.toString() : "null"}'
        ',${accelerometerEvent != null ? accelerometerEvent!.z.toString() : "null"}'
        ',${gyroscopeEvent != null ? gyroscopeEvent!.x.toString() : "null"}'
        ',${gyroscopeEvent != null ? gyroscopeEvent!.y.toString() : "null"}'
        ',${gyroscopeEvent != null ? gyroscopeEvent!.z.toString() : "null"}'
        ',${magnetometerEvent != null ? magnetometerEvent!.x.toString() : "null"}'
        ',${magnetometerEvent != null ? magnetometerEvent!.y.toString() : "null"}'
        ',${magnetometerEvent != null ? magnetometerEvent!.z.toString() : "null"}';
  }
}
