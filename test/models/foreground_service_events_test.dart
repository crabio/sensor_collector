import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensor_collector/models/foreground_service_events.dart';

class MockFile extends Mock implements File {
  @override
  String get path => '/a/b/cfile_name.txt';
}

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
      final event = ForegroundServiceEvent.newDataFile(file);
      expect(event.type, ForegroundServiceEventType.newDataFile);
      expect(event.newDataFile, isInstanceOf<NewDataFile>());
    });

    test('ElapsedTime fromJson', () {
      Map<String, dynamic> jsonMap = {
        'type': 'ForegroundServiceEventType.elapsedTime',
        'elapsedSeconds': const Duration(minutes: 1).inSeconds,
      };
      ForegroundServiceEvent event = ForegroundServiceEvent.fromJson(jsonMap);
      expect(event.type, ForegroundServiceEventType.elapsedTime);
      expect(event.newDataFile, isNull);
      expect(event.elapsedTime, isNotNull);
      expect(event.elapsedTime!.elapsed, const Duration(minutes: 1));
    });

    test('NewDataFile fromJson', () {
      Map<String, dynamic> jsonMap = {
        'type': 'ForegroundServiceEventType.newDataFile',
        'filePath': '/a/b/cfile_name.txt',
      };
      ForegroundServiceEvent event = ForegroundServiceEvent.fromJson(jsonMap);
      expect(event.type, ForegroundServiceEventType.newDataFile);
      expect(event.elapsedTime, isNull);
      expect(event.newDataFile, isNotNull);
      expect(event.newDataFile!.file.path, '/a/b/cfile_name.txt');
    });

    test('ElapsedTime toJson', () {
      ForegroundServiceEvent event =
          ForegroundServiceEvent.elapsedTime(const Duration(minutes: 1));
      Map<String, dynamic> jsonMap = event.toJson();
      expect(jsonMap['type'], 'ForegroundServiceEventType.elapsedTime');
      expect(jsonMap['elapsedSeconds'], const Duration(minutes: 1).inSeconds);
    });

    test('NewDataFile toJson', () {
      final file = MockFile();
      ForegroundServiceEvent event = ForegroundServiceEvent.newDataFile(file);
      Map<String, dynamic> jsonMap = event.toJson();
      expect(jsonMap['type'], 'ForegroundServiceEventType.newDataFile');
      expect(jsonMap['filePath'], '/a/b/cfile_name.txt');
    });
  });
}
