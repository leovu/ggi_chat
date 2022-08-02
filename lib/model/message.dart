import 'package:intl/intl.dart';

class ChatMessage {
  List<Messages>? message;

  ChatMessage({data});

  ChatMessage.fromJson(Map<String, dynamic> json, {bool isReversed = false}) {
    if (json['data'] != null) {
      message = <Messages>[];
      json['data'].forEach((v) {
        message!.add(Messages.fromJson(v));
      });
      message = message?.reversed.toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (message != null) {
      data['data'] = message!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Messages {
  String? sId;
  String? chatRoomId;
  Content? content;
  String? type;
  PostedByUser? postedByUser;
  List<ReadByRecipients>? readByRecipients;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Messages(
      {sId,
        chatRoomId,
        message,
        type,
        postedByUser,
        readByRecipients,
        createdAt,
        updatedAt,
        iV});

  Messages.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    chatRoomId = json['chatRoomId'];
    content =
    json['message'] != null ? Content.fromJson(json['message']) : null;
    type = json['type'];
    postedByUser = json['postedByUser'] != null
        ? PostedByUser.fromJson(json['postedByUser'])
        : null;
    if (json['readByRecipients'] != null) {
      readByRecipients = <ReadByRecipients>[];
      json['readByRecipients'].forEach((v) {
        readByRecipients!.add(ReadByRecipients.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['chatRoomId'] = chatRoomId;
    if (content != null) {
      data['message'] = content!.toJson();
    }
    data['type'] = type;
    if (postedByUser != null) {
      data['postedByUser'] = postedByUser!.toJson();
    }
    if (readByRecipients != null) {
      data['readByRecipients'] =
          readByRecipients!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
  Map<String, dynamic> toMessageJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (postedByUser != null) {
      data['author'] = {
        'firstName': postedByUser!.firstName,
        'lastName': postedByUser!.lastName,
        'id':postedByUser!.sId,
        'imageUrl':null,
      };
    }
    if(createdAt != null) {
      final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
      final dt = format.parse(updatedAt!, true);
      data['createdAt'] = dt.toUtc().millisecondsSinceEpoch;
    }
    data['id'] = sId;
    data['type'] = 'text';
    data['text'] = content?.messageText ?? '';
    return data;
  }
}

class Content {
  String? messageText;

  Content({messageText});

  Content.fromJson(Map<String, dynamic> json) {
    messageText = json['messageText'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageText'] = messageText;
    return data;
  }
}

class PostedByUser {
  String? sId;
  String? firstName;
  String? lastName;
  String? type;
  String? createdAt;
  String? updatedAt;
  int? iV;

  PostedByUser(
      {sId,
        firstName,
        lastName,
        type,
        createdAt,
        updatedAt,
        iV});

  PostedByUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    type = json['type'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['type'] = type;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class ReadByRecipients {
  String? readByUserId;
  String? readAt;

  ReadByRecipients({readByUserId, readAt});

  ReadByRecipients.fromJson(Map<String, dynamic> json) {
    readByUserId = json['readByUserId'];
    readAt = json['readAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['readByUserId'] = readByUserId;
    data['readAt'] = readAt;
    return data;
  }
}