import 'md_announcement_gallery.dart';

class MDAnnouncement{
  int id;
  String user_id;
  String title;
  String google_location;
  String lat;
  String lng;
  String postal_code;
  String metro_station;
  String category;
  String product_purchase_link;
  String payment_detail;
  String duration;
  String languages;
  String body;
  String email;
  String contact_name;
  String phone;
  String extension;
  String contact_by_phone;
  String contact_by_text;
  String street;
  String cross_street;
  String city;
  String created_at;
  String updated_at;
  List<MDAnnouncementGallery> announcement_gallery;

  MDAnnouncement.fromJson(Map json) :
      id = json['id'] == null ? 0 : json['id'],
        user_id = json['user_id'] == null ? '0' : json['user_id'],
        title = json['title'] == null ? '' : json['title'],
        google_location = json['google_location'] == null ? '' : json['google_location'],
        lat = json['lat'] == null ? '' : json['lat'],
        lng = json['lng'] == null ? '' : json['lng'],
        postal_code = json['postal_code'] == null ? '' : json['postal_code'],
        metro_station = json['metro_station'] == null ? '' : json['metro_station'],
        category = json['category'] == null ? '' : json['category'],
        product_purchase_link = json['product_purchase_link'] == null ? '' : json['product_purchase_link'],
        payment_detail = json['payment_detail'] == null ? '' : json['payment_detail'],
        duration = json['duration'] == null ? '' : json['duration'],
        languages = json['languages'] == null ? '' : json['languages'],
        body = json['body'] == null ? '' : json['body'],
        email = json['email'] == null ? '' : json['email'],
        contact_name = json['contact_name'] == null ? '' : json['contact_name'],
        phone = json['phone'] == null ? '' : json['phone'],
        extension = json['extension'] == null ? '' : json['extension'],
        contact_by_phone = json['contact_by_phone'] == null ? '' : json['contact_by_phone'],
        contact_by_text = json['contact_by_text'] == null ? '' : json['contact_by_text'],
        street = json['street'] == null ? '' : json['street'],
        cross_street = json['cross_street'] == null ? '' : json['cross_street'],
        city = json['city'] == null ? '' : json['city'],
        created_at = json['created_at'] == null ? '' : json['created_at'],
        updated_at = json['updated_at'] == null ? '' : json['updated_at'],
        announcement_gallery = json['announcement_gallery'] == null ? [] : (json['announcement_gallery'] as List).map((e) => MDAnnouncementGallery.fromJson(e)).toList();
}