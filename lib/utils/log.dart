import 'package:logging/logging.dart';

void initLogger({final Level level = Level.FINE}) {
  Logger.root.level = level;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}
