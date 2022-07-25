class MDUser{
  int user_id;
  String email;
  bool status;
  int status_code;
  String message;
  String name;
  String image;
  String data;

  MDUser.fromJson(Map json) :
      user_id = json['user_id'] == null ? 0 : json['user_id'],
        email = json['email'] == null ? '' : json['email'],
        status = json['status'] == null ? false : json['status'],
        name = json['name'] == null ? '' : json['name'],
        image = json['image'] == null ? '' : json['image'],
        status_code = json['status_code'] == null ? 0 : json['status_code'],
        message = json['message'] == null ? '' : json['message'],
        data = json['data'] == null ? '' : json['data'];
}