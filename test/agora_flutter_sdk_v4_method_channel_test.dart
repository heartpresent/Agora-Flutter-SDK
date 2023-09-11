import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agora_flutter_sdk_v4/agora_flutter_sdk_v4_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAgoraFlutterSdkV4 platform = MethodChannelAgoraFlutterSdkV4();
  const MethodChannel channel = MethodChannel('agora_flutter_sdk_v4');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
