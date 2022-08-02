import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ggi_chat/chat/chat_screen.dart';
import 'package:ggi_chat/connection/chat_connection.dart';
import 'package:ggi_chat/model/room.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool isInitScreen = true;
  Room? roomListData;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _getRooms();
  }

  void _onRefresh() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await _getRooms();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await _getRooms();
    _refreshController.loadComplete();
  }

  _getRooms() async {
    if(mounted) {
      roomListData = await ChatConnection.roomList();
      isInitScreen = false;
      setState(() {});
    }
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        roomListData = await ChatConnection.roomList();
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
                      child: Text('Chats',style: TextStyle(fontSize: 25.0,color: Colors.black)),
                    ),
                    Expanded(child: Container()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(width:30.0,height: 30.0,
                          child: InkWell(onTap: () async {
                          },
                            child: const Icon(Icons.group_add,color: Colors.blue,),)),
                    )
                  ],
                ),
              ],
            ),
            Expanded(
              child:
              isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) :
              roomListData?.rooms != null ? SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                header: const WaterDropHeader(),
                child: ListView.builder(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: roomListData!.rooms?.length,
                    itemBuilder: (BuildContext context, int position) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: InkWell(
                            onTap: () async {
                              await Navigator.of(context,rootNavigator: true).push(
                                MaterialPageRoute(builder: (context) => ChatScreen(data: roomListData!.rooms![position],)),
                              );
                              setState(() {});
                              _getRooms();
                            },
                            child: _room(roomListData!.rooms![position], position == roomListData!.rooms!.length-1)));
                    }),
              ) : Container(),
            )
          ],),
        ),
      ),
    );
  }
  Widget _room(Rooms data, bool isLast) {
    People info = getPeople(data.roomInfo);
    bool isGroup = data.roomInfo!.length > 2;
    String? author = findAuthor(data.roomInfo,data.postedByUser?.sId);
    return Column(
      children: [
        SizedBox(
          child: SizedBox(
            height: 50.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  !isGroup ? CircleAvatar(
                    radius: 25.0,
                    child: AutoSizeText(
                      info.getAvatarName(),
                      style: const TextStyle(color: Colors.white),),
                  ) : const CircleAvatar(
                    radius: 25.0,
                    child: AutoSizeText(
                      'GROUP',
                      style: TextStyle(color: Colors.white),),
                  ),
                  Expanded(child: Container(
                    padding: const EdgeInsets.only(top: 5.0,bottom: 5.0,left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Row(
                              children: [
                                Expanded(child: AutoSizeText(!isGroup ?
                                '${info.firstName} ${info.lastName}' : 'Group with ${info.firstName} ${info.lastName}',
                                    overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: !isRead(data.readByRecipients) ? FontWeight.bold : FontWeight.normal),
                                  ),
                                ),
                                AutoSizeText(
                                  formatDate(data.postedByUser?.updatedAt ?? data.createdAt ?? ""),style:
                                const TextStyle(fontSize: 11,color: Colors.grey),),
                              ],
                            )
                        ),
                        Container(height: 5.0,),
                        Expanded(child:
                        AutoSizeText(
                          data.message?.messageText ?? "",
                          textScaleFactor: 0.8,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: !isRead(data.readByRecipients) ? FontWeight.bold : FontWeight.normal),
                        )),
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
  String? findAuthor(List<People>? people, String? author,{bool isGroupOwner = false}) {
    People? p;
    try {
      p = people?.firstWhere((element) => element.sId == author);
      return (p!.sId != ChatConnection.user!.data!.chatId ? ('${(p.firstName ?? '').trim()} ${(p.lastName ?? '').trim()}').trim() : 'You') + (isGroupOwner ? ' ' : ': ');
    }catch(_){
      return '';
    }
  }
  bool isRead(List<ReadByRecipients>? messagesRecived) {
    try {
      final m = messagesRecived?.firstWhere((e) => e.readByUserId == ChatConnection.user?.data?.chatId);
      if(m != null) {
        return true;
      }
      return false;
    }catch(_) {
      return false;
    }
  }
  People getPeople(List<People>? people) {
    return people!.first.sId != ChatConnection.user!.data!.chatId ? people.first : people.last;
  }
  String formatDate(String date) {
    String formattedDate = date;
    try {
      final format1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
      final format2 = DateFormat("dd/MM/yyyy");
      final dt = format1.parse(date, true).toLocal();
      formattedDate = format2.format(dt);
    }catch(_) {}
    return formattedDate;
  }
}