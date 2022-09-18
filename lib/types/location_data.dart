/// The response object of [Location.getLocation] and [Location.onLocationChanged]
class LocationData {
  /// Latitude in degrees
  final double latitude;

  /// Longitude, in degrees
  final double longitude;

  /// Estimated horizontal accuracy of this location, radial, in meters
  final double accuracy;

  /// In meters above the WGS 84 reference ellipsoid
  final double altitude;

  /// In meters/second
  final double speed;

  /// In meters/second
  ///
  /// Always 0 on iOS
  final double speedAccuracy;

  /// Heading is the horizontal direction of travel of this device, in degrees
  final double heading;

  /// timestamp of the LocationData
  final double time;

  /// Optional label of the LocationData - used to mark elements in LocationCache
  String label = '';

  /// Optional id of the LocationData - used by LocationCache
  int id = -1;

  LocationData._(
    this.latitude,
    this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.speedAccuracy,
    this.heading,
    this.time,
  );

  factory LocationData.fromMap(Map<String, dynamic> dataMap) {
    LocationData locationData = LocationData._(
      dataMap['latitude'],
      dataMap['longitude'],
      dataMap['accuracy'],
      dataMap['altitude'],
      dataMap['speed'],
      dataMap['speed_accuracy'],
      dataMap['heading'],
      dataMap['time'],
    );
    if (dataMap.containsKey('label')) {
      locationData.label = dataMap['label'];
    }
    if (dataMap.containsKey('id')) {
      locationData.id = dataMap['id'];
    }
    return locationData;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'speed_accuracy': speedAccuracy,
      'heading': heading,
      'time': time,
    };
    if (label != '') {
      map['label'] = label;
    }
    if (id >= 0) {
      map['id'] = id;
    }
    return map;
  }

  @override
  String toString() => 'LocationData<lat: $latitude, long: $longitude>';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationData &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          accuracy == other.accuracy &&
          altitude == other.altitude &&
          speed == other.speed &&
          speedAccuracy == other.speedAccuracy &&
          heading == other.heading &&
          time == other.time &&
          label == other.label;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      accuracy.hashCode ^
      altitude.hashCode ^
      speed.hashCode ^
      speedAccuracy.hashCode ^
      heading.hashCode ^
      time.hashCode ^
      label.hashCode;
}
