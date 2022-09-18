import 'package:background_location/types/location_accuracy.dart';
import 'package:background_location/types/location_data.dart';
import 'package:background_location/types/location_permission_status.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'background_location_channels.dart';

abstract class BackgroundLocationPlatform extends PlatformInterface {
  /// Constructs a BackgroundLocationPlatform.
  BackgroundLocationPlatform() : super(token: _token);

  static final Object _token = Object();

  static BackgroundLocationPlatform _instance = BackgroundLocationChannels();

  /// The default instance of [BackgroundLocationPlatform] to use.
  ///
  /// Defaults to [BackgroundLocationChannels].
  static BackgroundLocationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BackgroundLocationPlatform] when
  /// they register themselves.
  static set instance(BackgroundLocationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<LocationData>> getLocations(List<String> labels, {int n = -1}) {
    throw UnimplementedError('getLocations(...) has not been implemented.');
  }

  Future<LocationData> getLastLocation() {
    throw UnimplementedError('getLastLocation(...) has not been implemented.');
  }

  Future<bool> deleteLocations(List<String> labels) {
    throw UnimplementedError('deleteLocations(...) has not been implemented.');
  }

  Future<bool> clearLocationCache() {
    throw UnimplementedError('clearLocationCache() has not been implemented.');
  }

  Future<bool> serviceEnabled({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int interval = 1000,
    double distanceFilter = 0,
  }) {
    throw UnimplementedError('serviceEnabled(...) has not been implemented.');
  }

  Future<bool> requestService({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int interval = 1000,
    double distanceFilter = 0,
  }) {
    throw UnimplementedError('requestService(...) has not been implemented.');
  }

  Future<PermissionStatus> hasPermission() {
    throw UnimplementedError('hasPermission() has not been implemented.');
  }

  Future<PermissionStatus> requestPermission() {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  Future<bool> updatesActive() {
    throw UnimplementedError('updatesActive() has not been implemented.');
  }

  Future<bool> startUpdates({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int interval = 1000,
    double distanceFilter = 0,
    String notificationTitle = "",
    String notificationBody = "",
    bool notificationClickable = false,
    String url = "",
    Map<String, String> header = const {},
    String label = "",
  }) {
    throw UnimplementedError('startUpdates(...) has not been implemented.');
  }

  Future<bool> stopUpdates() {
    throw UnimplementedError('stopUpdates() has not been implemented.');
  }

  Stream<LocationData> get onLocationChanged {
    throw UnimplementedError('onLocationChanged has not been implemented.');
  }

  Stream<LocationData> getLocationUpdateStream(String label) {
    throw UnimplementedError(
        'getLocationUpdateStream(...) has not been implemented.');
  }
}
