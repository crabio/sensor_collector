
class SensorCollectorServiceTaskHandler extends TaskHandler {
  StreamSubscription<Location>? _streamSubscription;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    print('onStart');
    // TODO Start streams subsctiptions
    _streamSubscription = FlLocation.getLocationStream().listen((location) {
      FlutterForegroundTask.updateService(
        notificationTitle: 'My Location',
        notificationText: '${location.latitude}, ${location.longitude}',
      );

      // Send data to the main isolate.
      final String locationJson = jsonEncode(location.toJson());
      sendPort?.send(locationJson);
    });
  }

  // Called when the task is destroyed.
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('onDestroy');
    // TODO Stop streams subsctiptions
    await _streamSubscription?.cancel();
  }
}