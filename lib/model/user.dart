class User {
  Data? data;

  User({data});

  User.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Token? token;
  int? id;
  String? username;
  String? email;
  int? role;
  int? userVerified;
  String? name;
  String? image;
  String? address;
  String? phone;
  String? areaCode;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  int? updatedBy;
  int? groupId;
  String? chatToken;
  String? chatId;
  UserInfo? userInfo;

  Data(
      {token,
        id,
        username,
        email,
        role,
        userVerified,
        name,
        image,
        address,
        phone,
        areaCode,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        groupId,
        chatToken,
        chatId,
        userInfo});

  Data.fromJson(Map<String, dynamic> json) {
    token = json['token'] != null ? Token.fromJson(json['token']) : null;
    id = json['id'];
    username = json['username'];
    email = json['email'];
    role = json['role'];
    userVerified = json['user_verified'];
    name = json['name'];
    image = json['image'];
    address = json['address'];
    phone = json['phone'];
    areaCode = json['area_code'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    groupId = json['group_id'];
    chatToken = json['chat_token'];
    chatId = json['chat_id'];
    userInfo = json['user_info'] != null
        ? UserInfo.fromJson(json['user_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (token != null) {
      data['token'] = token!.toJson();
    }
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['role'] = role;
    data['user_verified'] = userVerified;
    data['name'] = name;
    data['image'] = image;
    data['address'] = address;
    data['phone'] = phone;
    data['area_code'] = areaCode;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['group_id'] = groupId;
    data['chat_token'] = chatToken;
    data['chat_id'] = chatId;
    if (userInfo != null) {
      data['user_info'] = userInfo!.toJson();
    }
    return data;
  }
}

class Token {
  String? accessToken;
  String? tokenType;
  String? expiredAt;
  String? refreshToken;

  Token({accessToken, tokenType, expiredAt, refreshToken});

  Token.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    tokenType = json['token_type'];
    expiredAt = json['expired_at'];
    refreshToken = json['refresh_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access_token'] = accessToken;
    data['token_type'] = tokenType;
    data['expired_at'] = expiredAt;
    data['refresh_token'] = refreshToken;
    return data;
  }
}

class UserInfo {
  int? id;
  int? userId;
  int? provinceId;
  int? districtId;
  int? wardId;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? updatedBy;
  String? childrenCode;

  UserInfo(
      {id,
        userId,
        provinceId,
        districtId,
        wardId,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
        childrenCode});

  UserInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    provinceId = json['province_id'];
    districtId = json['district_id'];
    wardId = json['ward_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    childrenCode = json['children_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['province_id'] = provinceId;
    data['district_id'] = districtId;
    data['ward_id'] = wardId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['children_code'] = childrenCode;
    return data;
  }
}