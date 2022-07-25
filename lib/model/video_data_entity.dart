import 'package:thats_montreal/generated/json/base/json_convert_content.dart';
import 'package:thats_montreal/generated/json/base/json_field.dart';

class VideoDataEntity with JsonConvert<VideoDataEntity> {
	int id;
	@JSONField(name: "dot_id")
	String dotId;
	@JSONField(name: "video_url")
	String videoUrl;
	String title;
	String description;
	@JSONField(name: "gift_image")
	String giftImage;
	@JSONField(name: "created_at")
	String createdAt;
	@JSONField(name: "updated_at")
	String updatedAt;
	@JSONField(name: "video_id")
	String videoId;
}
