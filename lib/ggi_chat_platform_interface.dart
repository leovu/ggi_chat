import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ggi_chat_method_channel.dart';

abstract class GgiChatPlatform extends PlatformInterface {
  /// Constructs a GgiChatPlatform.
  GgiChatPlatform() : super(token: _token);

  static final Object _token = Object();

  static GgiChatPlatform _instance = MethodChannelGgiChat();

  /// The default instance of [GgiChatPlatform] to use.
  ///
  /// Defaults to [MethodChannelGgiChat].
  static GgiChatPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GgiChatPlatform] when
  /// they register themselves.
  static set instance(GgiChatPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
