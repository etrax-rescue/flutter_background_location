import 'dart:async';

import 'package:background_location/background_location_platform_interface.dart';

import 'types/location_data.dart';
import 'types/location_accuracy.dart';
import 'types/location_permission_status.dart';

export 'types/location_data.dart';
export 'types/location_accuracy.dart';
export 'types/location_permission_status.dart';

class BackgroundLocation {
  Future<List<LocationData>> getLocations(List<String> labels, {int n = -1}) {
    return BackgroundLocationPlatform.instance.getLocations(labels);
  }

  Future<LocationData> getLastLocation() {
    return BackgroundLocationPlatform.instance.getLastLocation();
  }

  Future<bool> deleteLocations(List<String> labels) {
    return BackgroundLocationPlatform.instance.deleteLocations(labels);
  }

  Future<bool> clearLocationCache() {
    return BackgroundLocationPlatform.instance.clearLocationCache();
  }

  /// Checks if the location service is enabled.
  ///
  /// On Android this call explicitly checks if the location service fullfills
  /// the requirements for the given settings. The settings are comprised of the
  /// [accuracy] argument, which controls the precision of the
  /// [LocationData], as well as [interval] and [distanceFilter] which are
  /// controlling how often the location is updated.
  Future<bool> serviceEnabled({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int interval = 1000,
    double distanceFilter = 0,
  }) {
    return BackgroundLocationPlatform.instance.serviceEnabled(
        accuracy: accuracy, interval: interval, distanceFilter: distanceFilter);
  }

  /// Requests activation of the location services.
  ///
  /// On Android this call explicitly requests that the location service
  /// fullfills the requirements for the given settings. The settings are
  /// comprised of the [accuracy] argument, which controls the precision of the
  /// [LocationData], as well as [interval] and [distanceFilter] which are
  /// controlling how often the location is updated.
  Future<bool> requestService({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int interval = 1000,
    double distanceFilter = 0,
  }) {
    return BackgroundLocationPlatform.instance.requestService(
        accuracy: accuracy, interval: interval, distanceFilter: distanceFilter);
  }

  /// Checks if the app has permission to access location.
  ///
  /// If the result is [PermissionStatus.deniedForever], no dialog will be
  /// shown on [requestPermission].
  /// Returns a [PermissionStatus] object.
  Future<PermissionStatus> hasPermission() {
    return BackgroundLocationPlatform.instance.hasPermission();
  }

  /// Requests permission to access location.
  ///
  /// If the result is [PermissionStatus.deniedForever], no dialog will be
  /// shown on [requestPermission].
  /// Returns a [PermissionStatus] object.
  Future<PermissionStatus> requestPermission() {
    return BackgroundLocationPlatform.instance.requestPermission();
  }

  /// Checks if location updates are active
  Future<bool> updatesActive() {
    return BackgroundLocationPlatform.instance.updatesActive();
  }

  /// Starts location updates
  ///
  /// The [accuracy] argument is controlling the precision of the
  /// [LocationData]. The [interval] and [distanceFilter] are controlling how
  /// often the location is updated. [notificationTitle] and [notificationBody]
  /// can be used to customize the persistent notification on Android. When
  /// [notificationClickable] is true, tapping the notification on Android
  /// will open the app. The [label] is stored in the location cache alongside
  /// each recorded location and will be used to identify the locations which
  /// were captured during this run. When the locations should be sent to a
  /// server, the label is used to retrieve those locations of this run which
  /// are not yet uploaded. If either the appropriate permissions are not
  /// granted or the location services are disabled, the function returns
  /// [false]. If the location updates were started sucessfully [true] is
  /// returned.
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
    return BackgroundLocationPlatform.instance.startUpdates(
        accuracy: accuracy,
        interval: interval,
        distanceFilter: distanceFilter,
        notificationTitle: notificationTitle,
        notificationBody: notificationBody,
        notificationClickable: notificationClickable,
        url: url,
        header: header,
        label: label);
  }

  /// Stops location updates
  Future<bool> stopUpdates() {
    return BackgroundLocationPlatform.instance.stopUpdates();
  }

  /// Returns a stream of [LocationData] objects. The frequency and accuracy of
  /// this stream are determined by the settings which were passed to
  /// [startUpdates].
  Stream<LocationData> get onLocationChanged {
    return BackgroundLocationPlatform.instance.onLocationChanged;
  }

  Stream<LocationData> getLocationUpdateStream(String label) {
    return BackgroundLocationPlatform.instance.getLocationUpdateStream(label);
  }
}
