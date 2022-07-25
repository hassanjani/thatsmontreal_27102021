import 'package:thats_montreal/model/md_announcement.dart';

class MDNotification{
  String id;
  String type;
  String notifiable_type;
  String notifiable_id;
  MDAnnouncement announement;
  String read_at;
  String created_at;
  String updated_at;
  
  MDNotification.fromJson(Map json) : 
      id = json['id'] == null ? '' : json['id'],
      type = json['type'] == null ? '' : json['type'],
        notifiable_type = json['notifiable_type'] == null ? '' : json['notifiable_type'],
        notifiable_id = json['notifiable_id'] == null ? '' : json['notifiable_id'],
        read_at = json['read_at'] == null ? null : json['read_at'],
        created_at = json['created_at'] == null ? '' : json['created_at'],
        updated_at = json['updated_at'] == null ? '' : json['updated_at'],
        announement = json['data']['announement'] == null ? null : MDAnnouncement.fromJson(json['data']['announement']);
}