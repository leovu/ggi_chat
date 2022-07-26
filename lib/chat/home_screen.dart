import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ggi_chat/chat/room_screen.dart';
import 'package:ggi_chat/connection/chat_connection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ChatConnection.dispose(isDispose: true);
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        activeColor: const Color(0xff9012FE),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.chat),
            label: 'Chat'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.contact_mail),
              label: 'Contact'
          ),
        ],
      ),
      tabBuilder: (context, index) {
        if (index == 0) {
          return CupertinoTabView(
            builder: (BuildContext context) =>  const RoomScreen(),
          );
        }
        else {
          return CupertinoTabView(
              builder: (BuildContext context) =>  Container());
        }
      },
    );
  }
}