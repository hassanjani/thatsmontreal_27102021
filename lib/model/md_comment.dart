class MDComment{
  String name;
  dynamic user_id;
  dynamic video_id;
  String comment;
  String created_at;
  String updated_at;

  MDComment.fromJson(Map json) :
        name = json['name'] ==null ? '' : json['name'],
        user_id = json['user_id'] ==null ? '' : json['user_id'],
        video_id = json['video_id'] ==null ? '' : json['video_id'],
        comment = json['comment'] ==null ? '' : json['comment'],
        created_at = json['created_at'] ==null ? '' : json['created_at'],
        updated_at = json['updated_at'] ==null ? '' : json['updated_at'];
}