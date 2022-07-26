import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ggi_chat_platform_interface.dart';

/// An implementation of [GgiChatPlatform] that uses method channels.
class MethodChannelGgiChat extends GgiChatPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ggi_chat');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
