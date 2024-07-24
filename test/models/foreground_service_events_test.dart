import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensor_collector/models/foreground_service_events.dart';

class MockFile extends Mock implements File {}

void main() {
  group('ForegroundServiceEvent', () {
    test('ElapsedTime factory', () {
      final event =
          ForegroundServiceEvent.elapsedTime(const Duration(minutes: 1));
      expect(event.type, ForegroundServiceEventType.elapsedTime);
      expect(event.elapsedTime, isInstanceOf<ElapsedTime>());
    });

    test('NewDataFile factory', () {
      final file = File('path/to/file');
      const fileName = 'file_name.txt';
      final event = ForegroundServiceEvent.newDataFile(file, fileName);
      expect(event.type, ForegroundServiceEventType.newDataFile);
      expect(event.newDataFile, isInstanceOf<NewDataFile>());
    });

    test('ElapsedTime fromJson', () {
      Map<String, dynamic> jsonMap = {
        'type': ForegroundServiceEventType.elapsedTime,
        'elapsed': const Duration(minutes: 1),
      };
      ForegroundServiceEvent event = ForegroundServiceEvent.fromJson(jsonMap);
      expect(event.type, ForegroundServiceEventType.elapsedTime);
      expect(event.newDataFile, isNull);
      expect(event.elapsedTime, isNotNull);
      expect(event.elapsedTime!.elapsed, const Duration(minutes: 1));
    });

    test('NewDataFile fromJson', () {
      final file = MockFile();
      Map<String, dynamic> jsonMap = {
        'type': ForegroundServiceEventType.newDataFile,
        'file': file,
        'fileName': 'file_name.txt',
      };
      ForegroundServiceEvent event = ForegroundServiceEvent.fromJson(jsonMap);
      expect(event.type, ForegroundServiceEventType.newDataFile);
      expect(event.elapsedTime, isNull);
      expect(event.newDataFile, isNotNull);
      expect(event.newDataFile!.file, file);
      expect(event.newDataFile!.fileName, 'file_name.txt');
    });

    test('ElapsedTime toJson', () {
      ForegroundServiceEvent event =
          ForegroundServiceEvent.elapsedTime(const Duration(minutes: 1));
      Map<String, dynamic> jsonMap = event.toJson();
      expect(jsonMap['type'], ForegroundServiceEventType.elapsedTime);
      expect(jsonMap['elapsed'], const Duration(minutes: 1));
    });

    test('NewDataFile toJson', () {
      final file = MockFile();
      ForegroundServiceEvent event = ForegroundServiceEvent.newDataFile(
        file,
        'file_name.txt',
      );
      Map<String, dynamic> jsonMap = event.toJson();
      expect(jsonMap['type'], ForegroundServiceEventType.newDataFile);
      expect(jsonMap['file'], file);
      expect(jsonMap['fileName'], 'file_name.txt');
    });
  });
}
