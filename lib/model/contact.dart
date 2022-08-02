class Contact {
  List<Data>? data;

  Contact({data});

  Contact.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? username;
  String? email;
  int? role;
  int? userVerified;
  String? password;
  String? name;
  String? image;
  String? address;
  String? phone;
  String? birthday;
  String? areaCode;
  String? rememberToken;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;
  int? groupId;
  String? chatToken;
  String? chatId;
  List<Children>? children;

  Data(
      {id,
        username,
        email,
        role,
        userVerified,
        password,
        name,
        image,
        address,
        phone,
        birthday,
        areaCode,
        rememberToken,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        groupId,
        chatToken,
        chatId,
        children});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    role = json['role'];
    userVerified = json['user_verified'];
    password = json['password'];
    name = json['name'];
    image = json['image'];
    address = json['address'];
    phone = json['phone'];
    birthday = json['birthday'];
    areaCode = json['area_code'];
    rememberToken = json['remember_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    groupId = json['group_id'];
    chatToken = json['chat_token'];
    chatId = json['chat_id'];
    if (json['children'] != null) {
      children = <Children>[];
      json['children'].forEach((v) {
        children!.add(Children.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['role'] = role;
    data['user_verified'] = userVerified;
    data['password'] = password;
    data['name'] = name;
    data['image'] = image;
    data['address'] = address;
    data['phone'] = phone;
    data['birthday'] = birthday;
    data['area_code'] = areaCode;
    data['remember_token'] = rememberToken;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['group_id'] = groupId;
    data['chat_token'] = chatToken;
    data['chat_id'] = chatId;
    if (children != null) {
      data['children'] = children!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  String getAvatarName() {
    String avatarName = '';
    if(name != '' && name != null) {
      avatarName += name![0];
    }
    return avatarName;
  }
}

class Children {
  int? id;
  String? username;
  String? email;
  int? role;
  int? userVerified;
  String? password;
  String? name;
  String? image;
  String? address;
  String? phone;
  String? birthday;
  String? areaCode;
  String? rememberToken;
  String? createdAt;
  String? updatedAt;
  int? createdBy;
  int? updatedBy;
  int? groupId;
  String? chatToken;
  int? chatId;
  String? lat;
  String? lng;

  Children(
      {id,
        username,
        email,
        role,
        userVerified,
        password,
        name,
        image,
        address,
        phone,
        birthday,
        areaCode,
        rememberToken,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        groupId,
        chatToken,
        chatId,
        lat,
        lng});

  Children.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    role = json['role'];
    userVerified = json['user_verified'];
    password = json['password'];
    name = json['name'];
    image = json['image'];
    address = json['address'];
    phone = json['phone'];
    birthday = json['birthday'];
    areaCode = json['area_code'];
    rememberToken = json['remember_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    groupId = json['group_id'];
    chatToken = json['chat_token'];
    chatId = json['chat_id'];
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['role'] = role;
    data['user_verified'] = userVerified;
    data['password'] = password;
    data['name'] = name;
    data['image'] = image;
    data['address'] = address;
    data['phone'] = phone;
    data['birthday'] = birthday;
    data['area_code'] = areaCode;
    data['remember_token'] = rememberToken;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['group_id'] = groupId;
    data['chat_token'] = chatToken;
    data['chat_id'] = chatId;
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}