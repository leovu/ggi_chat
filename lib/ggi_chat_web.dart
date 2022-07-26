// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'ggi_chat_platform_interface.dart';

/// A web implementation of the GgiChatPlatform of the GgiChat plugin.
class GgiChatWeb extends GgiChatPlatform {
  /// Constructs a GgiChatWeb
  GgiChatWeb();

  static void registerWith(Registrar registrar) {
    GgiChatPlatform.instance = GgiChatWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }
}
