import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:background_location/background_location_channels.dart';

void main() {
  MethodChannelBackgroundLocation platform = MethodChannelBackgroundLocation();
  const MethodChannel channel = MethodChannel('background_location');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
