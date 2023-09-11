import 'package:flutter_test/flutter_test.dart';
import 'package:agora_flutter_sdk_v4/agora_flutter_sdk_v4.dart';
import 'package:agora_flutter_sdk_v4/agora_flutter_sdk_v4_platform_interface.dart';
import 'package:agora_flutter_sdk_v4/agora_flutter_sdk_v4_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAgoraFlutterSdkV4Platform
    with MockPlatformInterfaceMixin
    implements AgoraFlutterSdkV4Platform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AgoraFlutterSdkV4Platform initialPlatform = AgoraFlutterSdkV4Platform.instance;

  test('$MethodChannelAgoraFlutterSdkV4 is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAgoraFlutterSdkV4>());
  });

  test('getPlatformVersion', () async {
    AgoraFlutterSdkV4 agoraFlutterSdkV4Plugin = AgoraFlutterSdkV4();
    MockAgoraFlutterSdkV4Platform fakePlatform = MockAgoraFlutterSdkV4Platform();
    AgoraFlutterSdkV4Platform.instance = fakePlatform;

    expect(await agoraFlutterSdkV4Plugin.getPlatformVersion(), '42');
  });
}
