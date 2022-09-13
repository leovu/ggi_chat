import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ggi_chat/chat/chat_screen.dart';
import 'package:ggi_chat/connection/chat_connection.dart';
import 'package:ggi_chat/model/contact.dart';
import 'package:ggi_chat/model/room.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  bool isInitScreen = true;
  Contact? contactListData;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _getContact();
  }

  void _onRefresh() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await _getContact();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await _getContact();
    _refreshController.loadComplete();
  }

  _getContact() async {
    if(mounted) {
      contactListData = await ChatConnection.contactList();
      isInitScreen = false;
      setState(() {});
    }
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        contactListData = await ChatConnection.contactList();
        isInitScreen = false;
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 30.0,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(ChatConnection.buildContext).pop();
                        },
                        child: SizedBox(
                            width:30.0,
                            child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.black)),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 3.0,left: 10.0,right: 10.0),
                      child: Text('Contacts',style: TextStyle(fontSize: 25.0,color: Colors.black)),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ],
            ),
            Expanded(
              child:
              isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) :
              contactListData?.data != null ? SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                header: const WaterDropHeader(),
                child: ListView.builder(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: contactListData!.data?.length,
                    itemBuilder: (BuildContext context, int position) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: InkWell(
                              onTap: () async {
                                print(contactListData!.data![position].chatId);
                                Rooms? rooms = await ChatConnection.initiate([contactListData!.data![position].chatId!.toString()]);
                                print(rooms);
                                if (!mounted) return;
                                if(rooms!=null) {
                                  await Navigator.of(context,rootNavigator: true).push(
                                    MaterialPageRoute(builder: (context) => ChatScreen(data: rooms,)),
                                  );
                                  setState(() {});
                                  _getContact();
                                }
                              },
                              child: _contact(contactListData!.data![position], position == contactListData!.data!.length-1)));
                    }),
              ) : Container(),
            )
          ],),
        ),
      ),
    );
  }
  Widget _contact(Data data, bool isLast) {
    return Column(
      children: [
        SizedBox(
          child: SizedBox(
            height: 60.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25.0,
                    child: AutoSizeText(
                      data.getAvatarName(),
                      style: const TextStyle(color: Colors.white),),
                  ),
                  Expanded(child: Container(
                    padding: const EdgeInsets.only(top: 5.0,bottom: 5.0,left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(data.name ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: AutoSizeText(data.email ?? "",
                            overflow: TextOverflow.ellipsis,
                            textScaleFactor: 0.9,
                          ),
                        )
                      ],
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
        !isLast ? Container(height: 5.0,) : Container(),
        !isLast ?  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(height: 1.0,color: Colors.grey.shade300,),
        ) : Container()
      ],
    );
  }
}