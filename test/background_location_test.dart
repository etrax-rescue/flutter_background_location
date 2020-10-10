import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:background_location/background_location.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('at.etrax.background_location/method');

  BackgroundLocation backgroundLocation;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'checkPermission':
          return 1;
        default:
          throw PlatformException(code: null);
      }
    });

    backgroundLocation = BackgroundLocation();
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('hasPermission', () async {
    expect(await backgroundLocation.hasPermission(), PermissionStatus.granted);
  });
}
