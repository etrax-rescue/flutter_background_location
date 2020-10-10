# Flutter Background Location Plugin

This plugin brings background location updates to Flutter apps. It is based on the [flutterlocation plugin](https://github.com/Lyokone/flutterlocation), which was extensively modified under the hood to enable background location access on Android and iOS (while retaining some API compatability with the original plugin).

## Getting Started

### Installation

Add the following lines to your app's _pubspec.yaml_ dependencies section and run _flutter pub get_.

```yml
background_location:
  git:
    url: https://github.com/etrax-rescue/flutter_background_location.git
    ref: main
```

### Android

On Android the background service has to be registered. One simply has to add the following lines to the app's AndroidManifest.xml file under the _application_ section.
```xml
<service android:name="at.etrax.background_location.BackgroundService"
         android:foregroundServiceType="location"
         android:exported="false"/>
```
The _uses-permission_ statements are inherited from the plugin's manifest.

### iOS

To use the plugin on iOS, you have to add the following permissions to your app's _Info.plist_ file.
```xml
NSLocationAlwaysAndWhenInUseUsageDescription
NSLocationWhenInUseUsageDescription
```
Additionally the _Location updates_ background mode has to be enabled. When a _url_ is provided during _startUpdates_, the _Background fetch_ background mode is needed as well.

## Public Methods

| Return Type | Description |
| ------ | ----------- |
| Future\<PermissionStatus> | **hasPermission()** <br>Returns a PermissionStatus to know if the backgroud location permission has been granted by the user.|
| Future\<PermissionStatus> | **requestPermission()** <br>Request the background location permission. Returns a PermissionStatus to know if the background location permission has been granted by the user.|
| Future\<bool> | **serviceEnabled(LocationAccuracy accuracy = LocationAccuracy.high, int interval = 1000, double distanceFilter = 0)** <br>Returns a boolean indicating whether the location services are enabled or not. The supplied parameters are only used on Android and offer a more fine-grained control over the requirements for the location services. |
| Future\<bool> | **requestService(LocationAccuracy accuracy = LocationAccuracy.high, int interval = 1000, double distanceFilter = 0)** <br>Shows an alert dialog asking the user to turn on the location services. On Android this dialog directly offers a button to turn on the location services, while on iOS the user is asked to go to the Settings and manually turn on the location services.
| Future\<bool> | **startUpdates(LocationAccuracy accuracy = LocationAccuracy.high, int interval = 1000, double distanceFilter = 0, String notificationTitle = "", String notificationBody = "", bool notificationClickable = false, String url = "", Map\<String, String> header = const {}, String label = "")** <br>Starts the location update service. The _accuracy_ argument is controlling the precision of the _LocationData_. The _interval_ (milliseconds) and _distanceFilter_ (meters) are controlling how often the location is updated. _notificationTitle_ and _notificationBody_ can be used to customize the persistent notification on Android. When _notificationClickable_ is true, tapping the notification on Android will open the app. The _label_ is stored in the location cache alongside each recorded location and will be used to identify the locations which were captured during this run. When the locations should be sent to a server, the label is used to retrieve those locations of this run which are not yet uploaded. If a _url_ is provided, the plugin will try to send the recorded locations as a JSON payload to the given URL. The _header_ property can be used to customize the headers of this request (e.g. for authentication headers). If either the permission has not yet been granted or the location services are disabled, the function returns false. If the location updates were started sucessfully true is returned. |
| Future\<bool> | **stopUpdates()** <br>Stops the location updates.|
| Future\<bool> | **updatesActive()** <br>Returns a boolean to know if the location updates are active.|
| Stream\<LocationData> | **onLocationChanged** <br> Returns a stream of the user's location. |
| Stream\<LocationData> | **getLocationUpdateStream(String label)** <br>Returns a stream of the user's location, but only for updates with the specified label. |
| Future\<LocationData> | **getLastLocation()** <br>Retrieves the last known location from the location cache. |
| Future\<List\<LocationData>> | **getLocations(List\<String> labels, int n = -1)** <br>Returns a list of LocationData corresponding to the given labels from the intenal location cache. The parameter n can be used to limit the number of locations. If n is omitted, all locations matching the given labels are returned. |
| Future\<bool> | **deleteLocations(List\<String> labels)** <br>Deletes the locations with the supplied labels from the location cache. |
| Future\<bool> | **clearLocationCache()** <br>Clears the location cache. |
