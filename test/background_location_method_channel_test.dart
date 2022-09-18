import 'package:background_location/background_location.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:background_location/background_location_channels.dart';

void main() {
  BackgroundLocationChannels platform = BackgroundLocationChannels();
  const MethodChannel methodChannel =
      MethodChannel('at.etrax.background_location/method');
  const MethodChannel eventChannel =
      MethodChannel('at.etrax.background_location/event');

  TestWidgetsFlutterBinding.ensureInitialized();

  final locationData = LocationData.fromMap({
    'latitude': 42.0,
    'longitude': 42.0,
    'accuracy': 1.0,
    'altitude': 0.0,
    'speed': 0.0,
    'speed_accuracy': 0.0,
    'heading': 0.0,
    'time': 0.0
  });

  setUp(() {
    methodChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case "getLocations":
          return [locationData];
      }
      throw UnimplementedError(
          "The mocked method call '${methodCall.method}' has not yet been implemented.");
    });

    eventChannel.setMockMethodCallHandler((call) => null);
  });

  tearDown(() {
    methodChannel.setMockMethodCallHandler(null);
    eventChannel.setMethodCallHandler(null);
  });

  test('getLocations', () async {
    expect(await platform.getLocations(["test"]), [locationData]);
  });
}
