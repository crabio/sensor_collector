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
    return 'dt,user_acc_x,user_acc_y,user_acc_z,acc_x,acc_y,acc_z,gyr_x,gyr_y,gyr_z,mag_x,mag_y,mag_z\n';
  }

  String toCsv() {
    return '${dt.millisecondsSinceEpoch.toString()}'
        ',${userAccelerometerEvent != null ? userAccelerometerEvent!.x.toString() : ""}'
        ',${userAccelerometerEvent != null ? userAccelerometerEvent!.y.toString() : ""}'
        ',${userAccelerometerEvent != null ? userAccelerometerEvent!.z.toString() : ""}'
        ',${accelerometerEvent != null ? accelerometerEvent!.x.toString() : ""}'
        ',${accelerometerEvent != null ? accelerometerEvent!.y.toString() : ""}'
        ',${accelerometerEvent != null ? accelerometerEvent!.z.toString() : ""}'
        ',${gyroscopeEvent != null ? gyroscopeEvent!.x.toString() : ""}'
        ',${gyroscopeEvent != null ? gyroscopeEvent!.y.toString() : ""}'
        ',${gyroscopeEvent != null ? gyroscopeEvent!.z.toString() : ""}'
        ',${magnetometerEvent != null ? magnetometerEvent!.x.toString() : ""}'
        ',${magnetometerEvent != null ? magnetometerEvent!.y.toString() : ""}'
        ',${magnetometerEvent != null ? magnetometerEvent!.z.toString() : ""}\n';
  }
}
