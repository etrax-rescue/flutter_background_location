import 'package:flutter_test/flutter_test.dart';
import 'package:background_location/background_location.dart';
import 'package:background_location/background_location_platform_interface.dart';
import 'package:background_location/background_location_channels.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBackgroundLocationPlatform
    with MockPlatformInterfaceMixin
    implements BackgroundLocationPlatform {
  @override
  Future<bool> clearLocationCache() {
    // TODO: implement clearLocationCache
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteLocations(List<String> labels) {
    // TODO: implement deleteLocations
    throw UnimplementedError();
  }

  @override
  Future<LocationData> getLastLocation() {
    // TODO: implement getLastLocation
    throw UnimplementedError();
  }

  @override
  Stream<LocationData> getLocationUpdateStream(String label) {
    // TODO: implement getLocationUpdateStream
    throw UnimplementedError();
  }

  @override
  Future<List<LocationData>> getLocations(List<String> labels, {int n = -1}) {
    // TODO: implement getLocations
    throw UnimplementedError();
  }

  @override
  Future<PermissionStatus> hasPermission() {
    // TODO: implement hasPermission
    throw UnimplementedError();
  }

  @override
  // TODO: implement onLocationChanged
  Stream<LocationData> get onLocationChanged => throw UnimplementedError();

  @override
  Future<PermissionStatus> requestPermission() {
    // TODO: implement requestPermission
    throw UnimplementedError();
  }

  @override
  Future<bool> requestService(
      {LocationAccuracy accuracy = LocationAccuracy.high,
      int interval = 1000,
      double distanceFilter = 0}) {
    // TODO: implement requestService
    throw UnimplementedError();
  }

  @override
  Future<bool> serviceEnabled(
      {LocationAccuracy accuracy = LocationAccuracy.high,
      int interval = 1000,
      double distanceFilter = 0}) {
    // TODO: implement serviceEnabled
    throw UnimplementedError();
  }

  @override
  Future<bool> startUpdates(
      {LocationAccuracy accuracy = LocationAccuracy.high,
      int interval = 1000,
      double distanceFilter = 0,
      String notificationTitle = "",
      String notificationBody = "",
      bool notificationClickable = false,
      String url = "",
      Map<String, String> header = const {},
      String label = ""}) {
    // TODO: implement startUpdates
    throw UnimplementedError();
  }

  @override
  Future<bool> stopUpdates() {
    // TODO: implement stopUpdates
    throw UnimplementedError();
  }

  @override
  Future<bool> updatesActive() {
    // TODO: implement updatesActive
    throw UnimplementedError();
  }
}

void main() {
  final BackgroundLocationPlatform initialPlatform =
      BackgroundLocationPlatform.instance;

  test('$BackgroundLocationChannels is the default instance', () {
    expect(initialPlatform, isInstanceOf<BackgroundLocationChannels>());
  });

  test('getPlatformVersion', () async {
    BackgroundLocation backgroundLocationPlugin = BackgroundLocation();
    MockBackgroundLocationPlatform fakePlatform =
        MockBackgroundLocationPlatform();
    BackgroundLocationPlatform.instance = fakePlatform;

    expect(await backgroundLocationPlugin.getLocations(["test"]), '42');
  });
}
