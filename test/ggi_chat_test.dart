import 'package:flutter_test/flutter_test.dart';
import 'package:ggi_chat/ggi_chat.dart';
import 'package:ggi_chat/ggi_chat_platform_interface.dart';
import 'package:ggi_chat/ggi_chat_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGgiChatPlatform 
    with MockPlatformInterfaceMixin
    implements GgiChatPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final GgiChatPlatform initialPlatform = GgiChatPlatform.instance;

  test('$MethodChannelGgiChat is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelGgiChat>());
  });

  test('getPlatformVersion', () async {
    GgiChat ggiChatPlugin = GgiChat();
    MockGgiChatPlatform fakePlatform = MockGgiChatPlatform();
    GgiChatPlatform.instance = fakePlatform;
  
    expect(await ggiChatPlugin.getPlatformVersion(), '42');
  });
}
