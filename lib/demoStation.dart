import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thats_montreal/helper/locolizations.dart';
import 'dart:async';
import 'dart:convert';

import 'api_url.dart';

class demoStation extends StatefulWidget {
  @override
  _demoStationState createState() => _demoStationState();
}

class _demoStationState extends State<demoStation> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewVideosCount();
  }

  Map coutData;
  List countList, dotsList;
  bool isLoading = true;
  Map myMap =Map();

  Future getNewVideosCount() async {
    http.Response response = await http.get(
        Uri.parse(ApiUrl.web_api_url+"api/get_dots"));
    coutData = json.decode(response.body);
    print(coutData.toString());
    countList = coutData['count'];
    dotsList = coutData['data'];
    print(countList);
    for(int i=0;i<countList.length;i++){
      myMap[countList[i]['dot_id']]=countList[i]['count'].toString();
    }
    print(myMap.containsKey("12"));
    print(myMap.toString());
    setState(() {
      isLoading = false;
    });


  }
 getCount(String id){
print(id.toString());
    for(int i=0;i<countList.length;i++)
      {
//        print(id);
//        print(i);
        if(identical(id,countList[i]['dot_id']))
          {
//            setState(() {
        print("found at "+id);
               return countList[i]['count'].toString();
//            });
            print(countList[i]['count'].toString());
          }else{
          print("not found at "+id);
           return " ";
        }
      }

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            height: 170.0,
            child: isLoading == true ? Text(AppLocalizations.of(context).trans('data')) : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 31,
              itemBuilder: (BuildContext context, int index) {

                return Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {

                          });
                        },
                        child: Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.15,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          decoration: BoxDecoration(
                            color:
                            Colors.grey
                            ,
                            shape: BoxShape.circle,

                          ),
                          child: Center(
                            child: Text(myMap.containsKey(dotsList[index]['id'].toString())?myMap[dotsList[index]['id'].toString()]:" ",style: TextStyle(fontSize: 30),),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 70,
                      child: Text(
                        dotsList[index]['name'],
                        style: TextStyle(fontFamily: 'Poppins'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Center(
            child: RaisedButton(
              onPressed: (){
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
//                        shape: RoundedRectangleBorder(
//                            borderRadius:
//                            BorderRadius.circular(20.0)), //this right here
                        child: Container(
                          height: 300,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    height: 200,
                                    child: Image(
                                      image: NetworkImage("https://images.pexels.com/photos/4586258/pexels-photo-4586258.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    FlatButton(
                                      child: Text(AppLocalizations.of(context).trans('cancel'),
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontFamily: "Gotham"
                                        ),
                                      ),
                                      onPressed: (){
                                        Navigator.pop(context);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(AppLocalizations.of(context).trans('download'),
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontFamily: "Gotham"
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        )
                      );
                    });
              },
              child: Text(AppLocalizations.of(context).trans('gift')),
            ),
          )
        ],
      ),
    );
  }
}
