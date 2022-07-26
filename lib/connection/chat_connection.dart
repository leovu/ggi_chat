import 'package:flutter/material.dart';
import 'package:ggi_chat/connection/http_connection.dart';
import 'package:ggi_chat/connection/socket.dart';
import 'package:ggi_chat/model/room.dart';
import 'package:ggi_chat/model/user.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ChatConnection {
  static late Locale locale;
  static StreamSocket streamSocket = StreamSocket();
  static HTTPConnection connection = HTTPConnection();
  static late String appIcon;
  static String? roomId;
  static User? user;
  static late BuildContext buildContext;
  static bool isLoadMore = false;
  static Future<bool>init(String phone,String password,String role,{Map<String, dynamic>? data}) async {
    HttpOverrides.global = MyHttpOverrides();
    Map<String,dynamic>? result;
    if(data != null) {
      result = data;
    }
    else {
      result = await login(phone, password, role);
    }
    if(result != null) {
      user = User.fromJson(result);
      streamSocket.connectAndListen(streamSocket,user!);
      return true;
    }
    else {
      return false;
    }
  }
  static Future<Map<String,dynamic>?> login(String phone,String password,String role) async {
    ResponseData responseData = await connection.post('api/login', {'phone':phone,'password':password,'role':role});
    if(responseData.isSuccess) {
      if(responseData.data['error_code'] == 0) {
        return responseData.data;
      }
    }
    return null;
  }
  static Future<Room?>roomList() async {
    ResponseData responseData = await connection.get('api/chat/room');
    if(responseData.isSuccess) {
      if(responseData.data['error_code'] == 0) {
        return Room.fromJson(responseData.data);
      }
    }
    return null;
  }
  static bool checkConnected() {
    if(streamSocket.socket == null) {
      return false;
    }
    return streamSocket.checkConnected();
  }
  static File convertToFile(XFile xFile) => File(xFile.path);
  static reconnect() {
    streamSocket.socket!.connect();
  }
  static dispose({bool isDispose = false}) {
    if(!isDispose) {
      streamSocket.socket!.disconnect();
    }
    else {
      streamSocket.socket!.disconnect();
      streamSocket.dispose();
    }
  }
}