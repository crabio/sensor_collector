# Sensor Collector

This app is created for collecting sensors data on mobile and smart watches.
Collected data will be stored locally as a `.csv.gz`.
Files from Smart Watches will be synced to the smartphone.

## Features

- app can collect data from accelerometer, magnetometer, gyroscope
- app saves data to the `.csv.gz` file
- mobile app scans periodically connected smart watch with same app
- if app on mobile app detects files for sync on smart watches they can be synced
- after sync to mobile device, files on smart watch will be deleted

## Development

### Add/update icon

1. Update icon in `assets/icon.png`
2. Run command `dart run flutter_launcher_icons`

### Add/update splash screen

1. Configure splash screen via `flutter_native_splash.yaml` config file
2. Run command `dart run flutter_native_splash:create`
