import 'package:thats_montreal/generated/json/base/json_convert_content.dart';
import 'package:thats_montreal/generated/json/base/json_field.dart';


class SpotTypesData with JsonConvert<SpotTypesData> {
	int id;
	String title;
	List<SpotTypesDataType> types;
}

class SpotTypesDataType with JsonConvert<SpotTypesDataType> {
	int id;
	@JSONField(name: "spot_id")
	String spotId;
	String title;
	String icon;
}
