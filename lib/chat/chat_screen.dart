import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ggi_chat/connection/chat_connection.dart';
import 'package:ggi_chat/model/message.dart' as c;
import 'package:ggi_chat/model/room.dart';
import 'package:ggi_chat/src/widgets/chat.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final Rooms data;
  const ChatScreen({super.key, required this.data});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<types.Message> _messages = [];
  bool isInitScreen = true;
  c.ChatMessage? data;
  bool newMessage = false;
  double progress = 0;
  int currentIndex = 1;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final _user = types.User(id: ChatConnection.user!.data!.chatId!);

  @override
  void initState() {
    super.initState();
    _loadMessages();
    ChatConnection.listenChat(_refreshMessage);
  }

  @override
  void dispose() {
    super.dispose();
    itemPositionsListener.itemPositions.removeListener(() {});
    ChatConnection.unsubscribe();
    ChatConnection.isLoadMore = false;
    ChatConnection.roomId = null;
  }

  _refreshMessage(dynamic cData) async {
    if (mounted) {
      data = await ChatConnection.joinRoom(widget.data.chatRoomId!, refresh: true);
      isInitScreen = false;
      if (data != null) {
        currentIndex = 1;
        List<c.Messages>? messages = data?.message;
        if (messages != null) {
          List<types.Message> values = [];
          for (var e in messages) {
            Map<String, dynamic> result = await e.toMessageJson();
            values.add(types.Message.fromJson(result));
          }
          if (mounted) {
            setState(() {
              _messages = values;
            });
          }
        }
      }
      if (mounted) {
        if (progress >= 0.15) {
          newMessage = true;
        }
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isGroup = widget.data.roomInfo!.length > 2;
    People info = getPeople(widget.data.roomInfo);
    return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
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
                          !isGroup ? CircleAvatar(
                            radius: 12.0,
                            child: AutoSizeText(
                              info.getAvatarName(),
                              style: const TextStyle(color: Colors.white,fontSize: 9),),
                          ) : const CircleAvatar(
                            radius: 12.0,
                            child: AutoSizeText(
                              'GROUP',
                              style: TextStyle(color: Colors.white),),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 3.0,left: 10.0,right: 10.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(!isGroup ?
                                '${info.firstName}' : 'Group with ${info.firstName}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 15.0,color: Colors.black)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) :
                  Chat(
                    messages: _messages,
                    onAttachmentPressed: _handleAtachmentPressed,
                    onMessageTap: _handleMessageTap,
                    onPreviewDataFetched: _handlePreviewDataFetched,
                    onSendPressed: _handleSendPressed,
                    showUserAvatars: true,
                    showUserNames: true,
                    user: _user,
                    scrollPhysics: const ClampingScrollPhysics(),
                    onStickerPressed: _onStickerPressed,
                    itemPositionsListener: itemPositionsListener,
                    itemScrollController: itemScrollController,
                    loadMore: loadMore,
                    progressUpdate: (value) {
                      progress = value;
                      if(progress < 0.1 && newMessage) {
                        setState(() {
                          newMessage = false;
                        });
                      }
                    },
                  ),
                )
              ],
            ),
          ),
    );
  }

  void _onStickerPressed(File result) async {
    final bytes = await result.readAsBytes();
    final image = await decodeImageFromList(bytes);
    final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: 'Sticker',
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
        status: types.Status.sending
    );
    _addMessage(message,file: result);
  }


  void loadMore() async {
    List<c.Messages>? value = await ChatConnection.loadMoreMessageRoom(ChatConnection.roomId!,currentIndex);
    if(value != null) {
      List<c.Messages>? messages = value;
      if(messages.isNotEmpty) {
        currentIndex++;
        data?.message?.addAll(messages);
        List<types.Message> values = [];
        for(var e in messages) {
          Map<String, dynamic> result = await e.toMessageJson();
          values.add(types.Message.fromJson(result));
        }
        if(mounted) {
          setState(() {
            _messages.addAll(values);
            Future.delayed(const Duration(seconds: 2)).then((value) => ChatConnection.isLoadMore = false);
          });
        }
      }
      else {
        ChatConnection.isLoadMore = false;
      }
    }
    else {
      ChatConnection.isLoadMore = false;
    }
  }

  People getPeople(List<People>? people) {
    return people!.first.sId != ChatConnection.user!.data!.chatId ? people.first : people.last;
  }

  void _addMessage(types.Message message, {File? file}) async {
    if(mounted) {
      setState(() {
        _messages.insert(0, message);
      });
    }
    if(message.type.name == 'text') {
      String? id = await ChatConnection.sendChat(ChatConnection.roomId!, 'text', (message as types.TextMessage).text);
      int index = _messages.indexWhere((element) => element.id == message.id);
      types.TextMessage resultMessage;
      if(id == null) {
        resultMessage = types.TextMessage(
          author: message.author,
          createdAt: message.createdAt,
          id: message.id,
          text: message.text,
          status: types.Status.error,
        );
      }
      else {
        resultMessage = types.TextMessage(
          author: message.author,
          createdAt: message.createdAt,
          id: id,
          text: message.text,
          status: types.Status.sent,
        );
      }
      if(mounted) {
        _messages[index] = resultMessage;
        setState(() {});
      }
    }
    else if(message.type.name == 'image') {
      try {
        String? url = await ChatConnection.upload(file!);
        types.ImageMessage resultMessage;
        if(url != null) {
          String? id = await ChatConnection.sendChat(ChatConnection.roomId!, 'image', url);
          if(id != null) {
            resultMessage = types.ImageMessage(
                author: message.author,
                createdAt: message.createdAt,
                height: (message as types.ImageMessage).height,
                id: id,
                name: (message).name,
                size: (message).size,
                uri: url,
                width: (message).width,
                status: types.Status.sent
            );
          }
          else {
            resultMessage = types.ImageMessage(
                author: message.author,
                createdAt: message.createdAt,
                height: (message as types.ImageMessage).height,
                id: (message).id,
                name: (message).name,
                size: (message).size,
                uri: (message).uri,
                width: (message).width,
                status: types.Status.error
            );
          }
        }
        else {
          resultMessage = types.ImageMessage(
              author: message.author,
              createdAt: message.createdAt,
              height: (message as types.ImageMessage).height,
              id: (message).id,
              name: (message).name,
              size: (message).size,
              uri: (message).uri,
              width: (message).width,
              status: types.Status.error
          );
        }
        int index = _messages.indexWhere((element) => element.id == message.id);
        if(mounted) {
          _messages[index] = resultMessage;
          setState(() {});
        }
      }catch(_) {}
    }
    else if(message.type.name == 'file') {
      try {
        String? url = await ChatConnection.upload(file!);
        types.FileMessage resultMessage;
        if(url != null) {
          String? id = await ChatConnection.sendChat(ChatConnection.roomId!, 'file', url);
          if(id != null) {
            resultMessage = types.FileMessage(
              author: message.author,
              createdAt: message.createdAt,
              id: id,
              mimeType: (message as types.FileMessage).mimeType,
              name: (message).name,
              size: (message).size,
              uri: (message).uri,
              status: types.Status.sent,
            );
          }
          else {
            resultMessage = types.FileMessage(
              author: message.author,
              createdAt: message.createdAt,
              id: (message).id,
              mimeType: (message as types.FileMessage).mimeType,
              name: (message).name,
              size: (message).size,
              uri: (message).uri,
              status: types.Status.error,
            );
          }
        }
        else {
          resultMessage = types.FileMessage(
            author: message.author,
            createdAt: message.createdAt,
            id: (message).id,
            mimeType: (message as types.FileMessage).mimeType,
            name: (message).name,
            size: (message).size,
            uri: (message).uri,
            status: types.Status.error,
          );
        }
        int index = _messages.indexWhere((element) => element.id == message.id);
        if(mounted) {
          _messages[index] = resultMessage;
          setState(() {});
        }
      }catch(_) {}
    }
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          // height: 124,
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    bool permission = await PermissionRequest.request(PermissionRequestType.STORAGE, (){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('App needs permission to access storage'),
          content: const Text('Accept the storage permission to use select file'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  PermissionRequest.openSetting();
                },
                child: const Text('Open setting')),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
          ],
        ),
      );
    });
    if(!permission) {
      return;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowCompression: false,
        withData: false,
      );
      if (result != null && result.files.single.path != null) {
        String id = const Uuid().v4();
        final message = types.FileMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: id,
          mimeType: lookupMimeType(result.files.single.path!),
          name: result.files.single.name,
          size: result.files.single.size,
          uri: result.files.single.path!,
          showStatus: true,
          status: types.Status.sending,
        );
        File file = File(result.files.single.path!);
        _addMessage(message,file: file);
      }
    }catch(_){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('You need to accept the permission to select file'),
          content: const Text('Accept'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Accept'))
          ],
        ),
      );
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );
    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
        status: types.Status.sending
      );
      _addMessage(message,file: ChatConnection.convertToFile(result));
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFile.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
      status: types.Status.sending,
    );

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    ChatConnection.roomId = widget.data.chatRoomId!;
    data = await ChatConnection.joinRoom(widget.data.chatRoomId!);
    isInitScreen = false;
    if(data != null) {
      List<c.Messages>? messages = data?.message;
      if (messages != null) {
        List<types.Message> values = [];
        for (var e in messages) {
          Map<String, dynamic> result = await e.toMessageJson();
          values.add(types.Message.fromJson(result));
        }
        _messages = values;
      }
    }
    if(mounted) {
      setState(() {});
    }
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if(mounted) {
          setState(() {});
        }
      });
    }
  }
}
