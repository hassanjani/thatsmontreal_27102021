import 'package:thats_montreal/model/video_data_entity.dart';

videoDataEntityFromJson(VideoDataEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id'] is String
				? int.tryParse(json['id'])
				: json['id'].toInt();
	}
	if (json['dot_id'] != null) {
		data.dotId = json['dot_id'].toString();
	}
	if (json['video_url'] != null) {
		data.videoUrl = json['video_url'].toString();
	}
	if (json['title'] != null) {
		data.title = json['title'].toString();
	}
	if (json['description'] != null) {
		data.description = json['description'].toString();
	}
	if (json['gift_image'] != null) {
		data.giftImage = json['gift_image'].toString();
	}
	if (json['created_at'] != null) {
		data.createdAt = json['created_at'].toString();
	}
	if (json['updated_at'] != null) {
		data.updatedAt = json['updated_at'].toString();
	}
	if (json['video_id'] != null) {
		data.videoId = json['video_id'].toString();
	}
	return data;
}

Map<String, dynamic> videoDataEntityToJson(VideoDataEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['dot_id'] = entity.dotId;
	data['video_url'] = entity.videoUrl;
	data['title'] = entity.title;
	data['description'] = entity.description;
	data['gift_image'] = entity.giftImage;
	data['created_at'] = entity.createdAt;
	data['updated_at'] = entity.updatedAt;
	data['video_id'] = entity.videoId;
	return data;
}