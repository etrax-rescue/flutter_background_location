import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'background_location_platform_interface.dart';
import 'types/location_accuracy.dart';
import 'types/location_data.dart';
import 'types/location_permission_status.dart';

/// An implementation of [BackgroundLocationPlatform] that uses method and event channels.
class BackgroundLocationChannels extends BackgroundLocationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('at.etrax.background_location/method');

  /// The event channel used to interact with the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('at.etrax.background_location/event');

  Future<List<LocationData>> getLocations(List<String> labels,
      {int n = -1}) async {
    final result = await methodChannel.invokeMethod(
      'getLocations',
      <String, dynamic>{
        'labels': labels,
        'n': n,
      },
    );
    List<LocationData> locationList = [];
    result.forEach((element) {
      locationList
          .add(LocationData.fromMap(Map<String, dynamic>.from(element)));
    });
    return locationList;
  }

  Future<LocationData> getLastLocation() async {
    final result = await methodChannel.invokeMethod('getLastLocation');
    return LocationData.fromMap(Map<String, dynamic>.from(result));
  }

  Future<bool> deleteLocations(List<String> labels) async {
    final result = await methodChannel.invokeMethod<int>(
      'deleteLocations',
      <String, dynamic>{
        'labels': labels,
      },
    );
    return result == 1;
  }

  Future<bool> clearLocationCache() async {
    final result = await methodChannel.invokeMethod<int>('clearCache');
    return result == 1;
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
  }) async {
    final result = await methodChannel.invokeMethod<int>(
      'serviceEnabled',
      <String, dynamic>{
        'accuracy': accuracy.index,
        'interval': interval,
        'distanceFilter': distanceFilter,
      },
    );
    return result == 1;
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
  }) async {
    final result = await methodChannel.invokeMethod<int>(
      'requestService',
      <String, dynamic>{
        'accuracy': accuracy.index,
        'interval': interval,
        'distanceFilter': distanceFilter,
      },
    );
    return result == 1;
  }

  /// Checks if the app has permission to access location.
  ///
  /// If the result is [PermissionStatus.deniedForever], no dialog will be
  /// shown on [requestPermission].
  /// Returns a [PermissionStatus] object.
  Future<PermissionStatus> hasPermission() async {
    final result = await methodChannel.invokeMethod<int>('hasPermission');
    switch (result) {
      case 0:
        return PermissionStatus.denied;
      case 1:
        return PermissionStatus.granted;
      case 2:
        return PermissionStatus.deniedForever;
      default:
        throw PlatformException(code: 'UNKNOWN_NATIVE_MESSAGE');
    }
  }

  /// Requests permission to access location.
  ///
  /// If the result is [PermissionStatus.deniedForever], no dialog will be
  /// shown on [requestPermission].
  /// Returns a [PermissionStatus] object.
  Future<PermissionStatus> requestPermission() async {
    final result = await methodChannel.invokeMethod<int>('requestPermission');

    switch (result) {
      case 0:
        return PermissionStatus.denied;
      case 1:
        return PermissionStatus.granted;
      case 2:
        return PermissionStatus.deniedForever;
      default:
        throw PlatformException(code: 'UNKNOWN_NATIVE_MESSAGE');
    }
  }

  /// Checks if location updates are active
  Future<bool> updatesActive() async {
    final int result = await methodChannel.invokeMethod('updatesActive');
    return result == 1;
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
  }) async {
    final result = await methodChannel.invokeMethod<int>(
      'startUpdates',
      <String, dynamic>{
        'accuracy': accuracy.index,
        'interval': interval,
        'distanceFilter': distanceFilter,
        'notificationTitle': notificationTitle,
        'notificationBody': notificationBody,
        'notificationClickable': notificationClickable,
        'url': url,
        'header': header,
        'label': label,
      },
    );
    return result == 1;
  }

  /// Stops location updates
  Future<bool> stopUpdates() async {
    final result = await methodChannel.invokeMethod<int>('stopUpdates');
    return result == 1;
  }

  /// Returns a stream of [LocationData] objects. The frequency and accuracy of
  /// this stream are determined by the settings which were passed to
  /// [startUpdates].
  Stream<LocationData> get onLocationChanged {
    return getLocationUpdateStream('');
  }

  Stream<LocationData> getLocationUpdateStream(String label) {
    return eventChannel.receiveBroadcastStream(label).map<LocationData>(
        (dynamic element) =>
            LocationData.fromMap(Map<String, dynamic>.from(element)));
  }
}
