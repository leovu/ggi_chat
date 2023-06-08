import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ggi_chat/connection/chat_connection.dart';
import 'package:ggi_chat/connection/http_connection.dart';
import 'package:ggi_chat/connection/socket.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ggi_chat/model/message.dart' as c;
import 'chat/home_screen.dart';
import 'ggi_chat_platform_interface.dart';

class GgiChat {
  static BuildContext? context;
  static HTTPConnection connection = HTTPConnection();
  static StreamSocket streamSocket = StreamSocket();

  Future<String?> getPlatformVersion() {
    return GgiChatPlatform.instance.getPlatformVersion();
  }
  static Future<bool>connectSocket(BuildContext context,
      String phone, String password, String role,
      String appIcon,Locale locale,
      { String? domain,
        String? chatDomain,
        Map<String,dynamic>? data}) async {
    ChatConnection.buildContext = context;
    ChatConnection.appIcon = appIcon;
    bool result = await ChatConnection.init(phone, password, role, data: data);
    return result;
  }
  static disconnectSocket() {
    ChatConnection.dispose(isDispose: true);
  }

  static Future<c.ChatMessage?>joinRoom(String id ,{bool refresh = false}) async {
    ResponseData responseData = await connection.get('api/chat/room/$id?limit=15&page=0');
    if(responseData.isSuccess) {
      if(!refresh) {
        streamSocket.joinRoom(id);
      }
      return c.ChatMessage.fromJson(responseData.data);
    }
    return null;
  }
  static void open(BuildContext context, String phone, String password, String role,
      String appIcon,Locale locale,
      { String? domain,
        String? chatDomain,
        Map<String,dynamic>? data}) async {
    GgiChat.context = context;
    showLoading(GgiChat.context!);
    await initializeDateFormatting();
    if(domain != null) {
      HTTPConnection.domain = domain;
    }
    if(chatDomain != null) {
      HTTPConnection.chatDomain = chatDomain;
    }
    ChatConnection.locale = locale;
    ChatConnection.buildContext = context;
    ChatConnection.appIcon = appIcon;
    bool result = await connectSocket(GgiChat.context!,phone,password,role,appIcon,locale,domain:domain,data: data);
    Navigator.of(GgiChat.context!).pop();
    if(result) {
      await Navigator.of(GgiChat.context!,rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => const HomeScreen(),settings: const RouteSettings(name: 'home_screen')));
    }
  }
  static Future showLoading(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator(),
              )
            ],
          );
        });
  }
}