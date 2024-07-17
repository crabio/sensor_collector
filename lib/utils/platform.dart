import 'package:device_info_plus/device_info_plus.dart';

Future<bool> isWearable() async {
  AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
  return androidInfo.systemFeatures.contains('android.hardware.type.watch');
}
