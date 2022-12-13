import 'dart:async';
import 'dart:io';
import 'package:ggi_chat/connection/http_connection.dart';
import 'package:ggi_chat/model/user.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class StreamSocket {
  final _socketResponse = StreamController<String>();
  void Function(String) get addResponse => _socketResponse.sink.add;
  Stream<String> get getResponse => _socketResponse.stream;
  io.Socket? socket;
  void dispose() {
    _socketResponse.close();
  }
  String? id () {return socket!.id;}
  void connectAndListen(StreamSocket streamSocket, User user) {
    socket = io.io(HTTPConnection.chatDomain,
        io.OptionBuilder().setTransports(['websocket']).build());
    socket!.onConnectError((data) {
      print(data);
    });
    socket!.on('identity_success', (data) {
      streamSocket.addResponse;
    });

    connectSocket(user);
    socket!.onDisconnect((_) => connectSocket(user));
  }
  void connectSocket(User user) {
    socket!.onConnect((_) {
      print("connectSocket");
      socket!.emit('identity', user.data?.id);
    });
  }
  void sendMessage(String? message, String roomId){
    socket!.emit('new message',{'status': 200, 'message':message, 'room':roomId});
  }
  void joinRoom(String? roomId) {
    socket!.emit('subscribe', roomId);
    socket!.on('subscribe_success', (data) {});
  }
  void unsubscribe(String? roomId) {
    socket!.emit('unsubscribe', roomId);
    socket!.on('unsubscribe_success', (data) {});
  }
  void listenChat(Function callback) {
    socket!.on('new message', (data) {
      callback(data);
    });
  }
  bool checkConnected() {
    return socket!.connected;
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
