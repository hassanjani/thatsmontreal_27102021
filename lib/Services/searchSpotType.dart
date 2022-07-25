import 'package:dio/dio.dart';
import 'package:thats_montreal/model/spot_types_entity.dart';


class SpotAPI{
  
  static Future<List<SpotTypesData>> getData() async{
    Dio dio = Dio();
    Response res =await dio.get("https://apis.thatsmontreal.com/api/spot/types");

    List<SpotTypesData> spot = List();
    List<dynamic> listData = res.data["data"];
    if(res.statusCode == 200){
      listData.forEach((e) {
        spot.add(SpotTypesData().fromJson(e));
      });
    }
    print("data");
     print(res.data);
    return spot;
    
  }
  
}