import 'package:flutter_test/flutter_test.dart';
import 'package:background_location/background_location.dart';
import 'package:background_location/background_location_platform_interface.dart';
import 'package:background_location/background_location_channels.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBackgroundLocationPlatform
    with MockPlatformInterfaceMixin
    implements BackgroundLocationPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BackgroundLocationPlatform initialPlatform =
      BackgroundLocationPlatform.instance;

  test('$MethodChannelBackgroundLocation is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBackgroundLocation>());
  });

  test('getPlatformVersion', () async {
    BackgroundLocation backgroundLocationPlugin = BackgroundLocation();
    MockBackgroundLocationPlatform fakePlatform =
        MockBackgroundLocationPlatform();
    BackgroundLocationPlatform.instance = fakePlatform;

    expect(await backgroundLocationPlugin.getPlatformVersion(), '42');
  });
}
