import 'dart:io';

enum ForegroundServiceEventType { elapsedTime, newDataFile }

class ForegroundServiceEvent {
  final ForegroundServiceEventType type;
  final ElapsedTime? elapsedTime;
  final NewDataFile? newDataFile;

  const ForegroundServiceEvent(
    this.type, {
    this.elapsedTime,
    this.newDataFile,
  });

  factory ForegroundServiceEvent.elapsedTime(final Duration elapsed) {
    return ForegroundServiceEvent(
      ForegroundServiceEventType.elapsedTime,
      elapsedTime: ElapsedTime(elapsed),
    );
  }

  factory ForegroundServiceEvent.newDataFile(
    final File file,
    final String fileName,
  ) {
    return ForegroundServiceEvent(
      ForegroundServiceEventType.newDataFile,
      newDataFile: NewDataFile(file, fileName),
    );
  }

  factory ForegroundServiceEvent.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case 'ForegroundServiceEventType.elapsedTime':
        return ForegroundServiceEvent.elapsedTime(
          Duration(seconds: json['elapsedSeconds']),
        );
      case 'ForegroundServiceEventType.newDataFile':
        return ForegroundServiceEvent.newDataFile(
          json['file'],
          json['fileName'],
        );
      default:
        throw Exception('Unknown ForegroundServiceEventType: ${json['type']}');
    }
  }

  Map<String, dynamic> toJson() {
    switch (type) {
      case ForegroundServiceEventType.elapsedTime:
        return {
          'type': type.toString(),
          'elapsedSeconds': elapsedTime!.elapsed.inSeconds,
        };
      case ForegroundServiceEventType.newDataFile:
        return {
          'type': type.toString(),
          'file': newDataFile!.file,
          'fileName': newDataFile!.fileName,
        };
      default:
        throw Exception('Unknown ForegroundServiceEventType: $type');
    }
  }
}

class ElapsedTime {
  final Duration elapsed;

  ElapsedTime(this.elapsed);
}

class NewDataFile {
  final File file;
  final String fileName;

  NewDataFile(this.file, this.fileName);
}
