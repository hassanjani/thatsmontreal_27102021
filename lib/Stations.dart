import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_downloader/image_downloader.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thats_montreal/Home/view_station_video.dart';
import 'package:thats_montreal/api_url.dart';
import 'package:thats_montreal/bottom_sheet.dart';
import 'package:thats_montreal/globals.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/model/giftModel.dart';
import 'package:thats_montreal/utilities.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'SignUp.dart';
import 'model/video_data_entity.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
class Stations extends StatefulWidget {
  final Color stationsColor;
  final String strMetroName;
  final int stationCount;

  Stations({this.stationsColor, this.strMetroName, this.stationCount});

  @override
  _StationsState createState() =>
      _StationsState(myStationColor: stationsColor, myMetroName: strMetroName);
}

class _StationsState extends State<Stations> {
  _StationsState({this.myStationColor, this.myMetroName});

  final Color myStationColor;
  final String myMetroName;
  bool commentLoading = true;
  bool isLoading = true;

  int SelectedStation = 0;
  bool isLoging;
  String customerName="";
  YoutubePlayerController _controller;
  int UserId;
  String name = "";
  String email = "";
  String profileImage = "";
  getUserId() async {
    name = Utilities.user.name;
    email = Utilities.user.email;
    UserId = Utilities.user.user_id;
    profileImage = Utilities.user.image;
    print(name);
    print(email);
    print(UserId);
    print(profileImage);
  }
  List<String> listStationOrange = [
    "MONTMORENCY",
    "DE LA CONCORDE",
    "CARTIER",
    "HENRI-BOURASSA",
    "SAUVE",
    "CREMAZIE",
    "JARRY",
    "JEAN-TALON",
    "BEAUBIEN",
    "ROSEMONT",
    "LAURIER",
    "MONT-ROYAL",
    "SHERBROOKE",
    "BERRI-UQAM",
    "CHAMP-DE-MARS",
    "PLACE-D'ARMES",
    "SQUARE-VICTORIA-OACI",
    "BONAVENTURE",
    "LUCIEN-L'ALLIER",
    "GEORGES-VANIER",
    "LIONEL-GROULX",
    "PLACE-SAINT-HENRI",
    "VENDOME",
    "VILLA-MARIA",
//    "SNOWDON",
    "COTE-SAINTE-CATHERINE",
    "PLAMONDON",
    "NAMUR",
    "DELA SAVANE",
    "DU COLLEGE",
    "COTE-VERTU",
  ];
  List<String> listStationBlue = [
    "SAINT-MICHEL",
    "D'IBERVILLE",
    "FABRE",
    "JEAN-TALON",
    "DE CASTELNAU",
    "PARC",
    "ACADIE",
    "OUTREMONT",
    "EDOUARD-MONTPETIT",
    "UNIVERSITE-DE-MONTREAL",
    "COTE-DES-NEIGES",
    "SNOWDON",
  ];
  List<String> listStationGreen = [
    "HONORE-BEAUGRAND",
    "RADISSON",
    "LANGELIER",
    "CADILLAC",
    "ASSOMPTION",
    "VIAU",
    "PIE-IX",
    "JOLIETTE",
    "PREFONTAINE",
    "FRONTENAC",
    "PAPINEAU",
    "BEAUDRY",
    "SAINT-LAURENT",
    "PLACE-DES-ARTS",
    "McGILL",
    "PEEL",
    "GUY-CONCORDIA",
    "ATWATER",
    "CHARLEVOIX",
    "LASSALLE",
    "DE LEGLISE",
    "VERDUN",
    "JOLICOEUR",
    "MONK",
    "ANGRIGNON"
  ];
  List<String> listStationYellow = [
    "JEAN-DRAPEAU",
    "LONGUEUIL-UNIVERSITE-DE-SHERBROOKE"
  ];
  Map data;
  List<VideoDataEntity> stationData;
  String stationName='';
  Map dataComment;
  List CommentData;
  int giftPrize=0;
  List<GiftM> giftList = [];
  Future getData(int stationId) async {
    if(_controller !=null){
      // _controller.dispose();
    }

    print('-----------------Get data Params---------------------');
    print(ApiUrl.web_api_url+"api/get_dot_detail/$stationId");
    print('-----------------Get data Params---------------------');
//    http.Response response = await http
//        .get(ApiUrl.web_api_url+"api/get_dot_detail/$stationId");
//    data = json.decode(response.body);

    http.get(Uri.parse(ApiUrl.web_api_url+"api/get_dot_detail/$stationId")).then((response){
      Map mappedResponse = jsonDecode(response.body);
      print('-----------------Get data Response786---------------------');
      print(mappedResponse);
      print('-----------------Get data Response---------------------');
      if(mappedResponse['status']){
        stationData = <VideoDataEntity>[];
        (mappedResponse['data']['media'] as List).forEach((e) {
          giftList.add(GiftM(e["gift_price"],e["invoice_link"]));
          stationData.add(VideoDataEntity().fromJson(e));
        });
        isLoading = false;
      }else{
        isLoading = false;
      }
      setState(() {});

      // Timer(Duration(seconds: 7), (){
      //   setState(() {
      //
      //   });
      // });
    });
  }

  String image;

  bool isImageLoading;

  Future getGift(String videoId) async {
//    Fluttertoast.showToast(
//        msg: "Your Gift Is Downloading",
//        toastLength: Toast.LENGTH_SHORT,
//        gravity: ToastGravity.CENTER,
//        timeInSecForIosWeb: 2,
//        backgroundColor: Colors.black,
//        textColor: Colors.white,
//        fontSize: 16.0);
    print(videoId);
    http.Response response = await http
        .get(Uri.parse(ApiUrl.web_api_url+"api/get_gift/$videoId"));
    data = json.decode(response.body);
    print("dfsd" + response.body);
    if (data["data"]['gift_image'] != null) {
      image = data["data"]['gift_image'];
      setState(() {
        isImageLoading = false;
        image = data["data"]['gift_image'];
      });

      print(image);
      print("mygift");
      print(data["data"]['title']);

      // click on notification to open downloaded file (for Android)
//      _downloadImage(
//        "https://thatsmontreal2.a2ztech.org/media-images/$image",
//        outputMimeType: "image/png",
//      );
    }
  }

  String _message = "";
  String _path = "";
  String _size = "";
  String _mimeType = "";
  File _imageFile;
  int _progress = 0;

  Future<void> _downloadImage(String url,
      {AndroidDestinationType destination,
        bool whenError = false,
        String outputMimeType}) async {
    Fluttertoast.showToast(
        msg: AppLocalizations.of(context).trans('your_gift_is_downloading'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);

    String fileName;
    String path;
    int size;
    String mimeType;
    try {
      String imageId;

      if (whenError) {
        imageId = await ImageDownloader.downloadImage(url,
            outputMimeType: outputMimeType)
            .catchError((error) {
          if (error is PlatformException) {
            var path = "";
            if (error.code == "404") {
              print("Not Found Error.");
            } else if (error.code == "unsupported_file") {
              print("UnSupported FIle Error.");
              path = error.details["unsupported_file_path"];
            }
            setState(() {
              _message = error.toString();
              _path = path;
            });
          }

          print(error);
        }).timeout(Duration(seconds: 10), onTimeout: () {
          print("timeout");
          return;
        });
      } else {
        if (destination == null) {
          imageId = await ImageDownloader.downloadImage(
            url,
            outputMimeType: outputMimeType,
          );
        } else {
          imageId = await ImageDownloader.downloadImage(
            url,
            destination: destination,
            outputMimeType: outputMimeType,
          );
        }
      }

      if (imageId == null) {
        return;
      }
      fileName = await ImageDownloader.findName(imageId);
      path = await ImageDownloader.findPath(imageId);
      size = await ImageDownloader.findByteSize(imageId);
      mimeType = await ImageDownloader.findMimeType(imageId);
    } on PlatformException catch (error) {
      setState(() {
        _message = error.message;
      });
      return;
    }

    if (!mounted) return;
    Fluttertoast.showToast(
        msg: AppLocalizations.of(context).trans('your_gift_saved_to_gallery'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
    setState(() {
      var location = Platform.isAndroid ? "Directory" : "Photo Library";
      _message = 'Saved as "$fileName" in $location.\n';
      _size = 'size:     $size';
      _mimeType = 'mimeType: $mimeType';
      _path = path;

      if (!_mimeType.contains("video")) {
        _imageFile = File(path);
      }
      return;
    });
  }

//  Future getComments(int videoId) async {
//    http.Response response = await http.get(
//        "https://thatsmontreal.aliyousafzulpich.com/api/get_comments/$videoId");
//    if (response.statusCode == 200) {
//      dataComment = json.decode(response.body);
//      CommentData = dataComment["data"];
//      print(CommentData);
//      print(CommentData[0]['name']);
//      commentLoading = false;
//      getBottomSheet(0);
//    } else {
//      print(response.body);
//    }
//  }

  checkLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool('isLoggedIn') == true) {
      print("loging status $isLoging");
      isLoging = true;
    } else {
      isLoging = false;
      print("loging status $isLoging");
    }
  }

//  Widget getBottomSheet(int videoId) {
//
//
//    }
//
//    if (commentLoading == true) {
//      getComments(videoId);
//    } else {
//      return ListView.builder(
//          itemCount: 1,
//          itemBuilder: (BuildContext context, int index) {
//            return Text(CommentData[0]['name']);
//          });
//    }
//  }

  @override
  void initState() {
    super.initState();
    getUserId();
    getStringName();
    getNewVideosCount();


    print('----------------Previous Values---------------');
    print(widget.stationCount);
    print(widget.stationsColor);
    print(widget.strMetroName);
    print('----------------Previous Values---------------');
    if (widget.stationCount == 30) {
      getData(1);
    }

    if (widget.stationCount == 12) {
      getData(31 + 1);
    }

    if (widget.stationCount == 25) {
      getData(41 + 1);
    }
    if (widget.stationCount == 2) {
      getData(66 + 1);
    }

//    checkLogin();
    if(!Utilities.isGuest){
      isLoging = true;
    }else{
      isLoging = false;
    }
    if (myStationColor == Colors.orange) {
      stationName = listStationOrange[0];
    }else if(myStationColor == Colors.blue){
      stationName = listStationBlue[0];
    }else if(myStationColor == Colors.green){
      stationName = listStationGreen[0];
    }else if(myStationColor == Colors.yellow){
      stationName = listStationYellow[0];
    }else{
      stationName = "";
    }
  }

  Map coutData;
  List countList, dotsList;
  Map myMap = Map();
  bool isLoading2 = true;

  //https://thatsmontreal.a2ztech.org

  Future getNewVideosCount() async {
    http.Response response =
    await http.get(Uri.parse(ApiUrl.web_api_url+"api/get_dots"));
    coutData = json.decode(response.body);
    print(coutData.toString());
    countList = coutData['count'];
    dotsList = coutData['data'];
    print(countList);
    for (int i = 0; i < countList.length; i++) {
      myMap[countList[i]['dot_id']] = countList[i]['count'].toString();
    }
    print(myMap.containsKey("12"));
    print(myMap.toString());

    setState(() {
      isLoading2 = false;
    });
  }

//  @override
//  void deactivate() {
//    // Pauses video while navigating to next page.
//    _controller.pause();
//    super.deactivate();
//  }
  @override
  void dispose() {
    if(_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> myStationsList = new List();

    if (myStationColor == Colors.orange) {
      myStationsList.addAll(listStationOrange);
    }
    if (myStationColor == Colors.blue) {
      myStationsList.addAll(listStationBlue);
    }
    if (myStationColor == Colors.green) {
      myStationsList.addAll(listStationGreen);
    }
    if (myStationColor == Colors.yellow) {
      myStationsList.addAll(listStationYellow);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme:IconThemeData(
          color: Colors.black
        ),
        // title: Text(
        //   AppLocalizations.of(context).trans('${widget.strMetroName}'),
        //   style: TextStyle(color: Colors.white),
        // ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ProgressHUD(
        child: Builder(
          builder: (context) {
            final progress = ProgressHUD.of(context);
            return Column(
              children: <Widget>[
                Container(
                  height: 170.0,
                  child: isLoading2 == true
                      ? Text(AppLocalizations.of(context).trans('loading'),)
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.stationCount,
                    itemBuilder: (BuildContext, int index) {
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 4.0, top: 20.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  stationData = null;
                                  isLoading = true;
                                  SelectedStation = index;
                                  stationName = myStationsList[index];
                                  print('Value of inDex '+index.toString());

                                  if (widget.stationCount == 30) {
                                    if(index >= 24){
                                      getData(1 + index+1);
                                    }else{
                                      getData(1 + index);
                                    }

                                    print('------------Inside 31----------');
                                    print((1+index).toString());
                                    print('------------Inside 31----------');
                                  }

                                  if (widget.stationCount == 12) {
                                    print('------------Inside 10----------');
                                    print((31+1+index).toString());
                                    if(widget.stationCount == index+1){
                                      getData(25);
                                    }else{
                                      getData(31 + 1 + index);
                                    }
                                    print('------------Inside 10----------');
                                  }

                                  if (widget.stationCount == 25) {
                                    getData(41 + 1 + index);
                                    print('------------Inside 25----------');
                                    print((41+1+index).toString());
                                    print('------------Inside 25----------');
                                  }
                                  if (widget.stationCount == 2) {
                                    getData(66 + 1 + index);
                                    print('------------Inside 2----------');
                                    print((66+1+index).toString());
                                    print('------------Inside 2----------');
                                  }
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10.0),
                                height:
                                MediaQuery.of(context).size.height * 0.11,
                                width: MediaQuery.of(context).size.width * 0.28,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7.0),
//                                  color: Color(0xFFF94E0D),
                                    color  : myStationColor,
//                                  shape: BoxShape.circle,
                                    boxShadow: [
                                      SelectedStation == index
                                          ? BoxShadow(
//                                        color: Color(0xFFF94E0D).withOpacity(0.9),
                                        color: myStationColor.withOpacity(0.9),
                                        spreadRadius: 3,
                                        blurRadius: 8,
                                        offset: Offset(1.0,1.0), // changes position of shadow
                                      ) : BoxShadow(),
                                    ]
                                ),
                                child: Container(
                                  child: Center(
                                    child:  Text(
                                      myStationsList[index],
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.w700),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
//                                  child: Align(
//                                    alignment: Alignment.centerRight,
//                                    child: myMap.containsKey(
//                                            dotsList[index]['id'].toString())
//                                        ? Container(
//                                            padding: EdgeInsets.all(10),
//                                            decoration: BoxDecoration(
//                                              shape: BoxShape.circle,
//                                              color: Colors.black,
//                                            ),
//                                            child: Text(
//                                              myMap.containsKey(dotsList[index]
//                                                          ['id']
//                                                      .toString())
//                                                  ? myMap[dotsList[index]['id']
//                                                      .toString()]
//                                                  : " ",
//                                              style: TextStyle(
//                                                  fontSize: 20,
//                                                  color: Colors.white),
//                                            ),
//                                          )
//                                        : null,
//                                  ),
                                ),
                              ),
                            ),
                          ),
//                          Container(
//                            height: 40,
//                            width: 70,
//                            child: Text(
//                              myStationsList[index],
//                              style: TextStyle(fontFamily: 'Poppins'),
//                              textAlign: TextAlign.center,
//                            ),
//                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  //margin: EdgeInsets.only(top: 10),
                  //height: MediaQuery.of(context).size.height * 1 ,
                  child: Container(
                      height: MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top +MediaQuery.of(context).padding.bottom+170+50+20 ),
                      padding: EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: Offset(3.0, 0), // changes position of shadow
                            )
                          ]
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 10.0,
                            ),
                            Center(
                              child: Text(
                                stationName != '' ? stationName : '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(0xFFF94E0D),
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w900
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            stationData == null ? Container() : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context).trans('click'),
                                  style: TextStyle(
                                    color: Color(0xFF151515),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  width: 3.0,
                                ),
                                Text(
                                  AppLocalizations.of(context).trans('a_clip'),
                                  style: TextStyle(
                                    color: Color(0xFF151515),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(
                                  width: 3.0,
                                ),
                                Text(
                                  AppLocalizations.of(context).trans('enjoy'),
                                  style: TextStyle(
                                    color: Color(0xFF151515),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(
                                  width: 3.0,
                                ),
                                Text(
                                  AppLocalizations.of(context).trans('the_free_gifts'),
                                  style: TextStyle(
                                    color: Color(0xFF151515),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            stationData == null ? Container() : SizedBox(
                              height: 20.0,
                            ),
                            stationData == null ? Container() : Container(
                              height: 1.0,
                              decoration: BoxDecoration(
                                color: Color(0xFFC2C2C2),
                              ),
                            ),
                            stationData == null ? Container() : SizedBox(
                              height: 25.0,
                            ),
                            stationData == null ? Container() : Center(
                              child: Text(
                                AppLocalizations.of(context).trans('all_clips'),
                                style: TextStyle(
                                  color: Color(0xFF151515),
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Flexible(
                              fit: FlexFit.loose,
                              child: isLoading
                                  ? Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                                  : stationData.isEmpty
                                  ? Container(
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context).trans('no_video_available'),
                                    style: TextStyle(fontSize: 30),
                                  ),
                                ),
                              )
                                  : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: stationData == null ? 0 : stationData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: (){
                                      Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => ViewStationVideo(stationData[index], index)));
                                              },
                                    child: Column(
                                      children: <Widget>[
//                        Container(
//                          height: 100,
//                          child:   FlutterYoutube.playYoutubeVideoByUrl(
//                            apiKey: "AIzaSyDkqz9Qsrng2zgMcm3R1SDzEmQOYG2juRw",
//                            videoUrl: stationData[index]['video_url'],
//                            //default false
//                          ),
//                        ),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10.0),
                                          child: YoutubePlayer(
                                            onReady: (){
                                              setState(() {
                                                print('Video Ready');
                                              });
                                            },
                                            controller: _controller =
                                                YoutubePlayerController(
                                                  initialVideoId: YoutubePlayer.convertUrlToId(
                                                      stationData[index].videoUrl),
                                                  flags: YoutubePlayerFlags(
                                                    autoPlay: false,
                                                  ),
                                                ),
                                            showVideoProgressIndicator: true,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15.0,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                stationData[index].title,
                                                style: TextStyle(
                                                  color: Color(0xFF151515),
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 3.0,
                                            ),
                                            InkWell(
                                              onTap: (){
                                                isLoging == true
                                                    ? showModalBottomSheet(
                                                    context: context,
                                                    builder: (context) => ConfirmCard(
                                                        id: stationData[index]
                                                            .id)).then((snack) =>
                                                    Scaffold.of(context)
                                                        .showSnackBar(snack))
                                                    : Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            SignUp()));
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(3.0),
                                                decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.2),
                                                        spreadRadius: 3,
                                                        blurRadius: 7,
                                                        offset: Offset(0, 3), // changes position of shadow
                                                      )
                                                    ],
                                                    color: Colors.white
                                                ),
                                                child: Image.asset('assets/comment_icon.png', width: 20.0, height: 20.0,),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            InkWell(
                                              onTap: (){
                                                Share.share(
                                                    stationData[index].videoUrl);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(3.0),
                                                decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.2),
                                                        spreadRadius: 3,
                                                        blurRadius: 7,
                                                        offset: Offset(0, 3), // changes position of shadow
                                                      )
                                                    ],
                                                    color: Colors.white
                                                ),
                                                child: Image.asset('assets/share_icon.png', width: 20.0, height: 20.0,),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          child: InkWell(
                                            onTap: (){
                                              print(stationData[index].giftImage);
                                              isImageLoading = true;
                                              showImageDialouge(stationData[index].giftImage.toString(), giftList[index].giftPrize, giftList[index].invoiceUrl,stationData[index].id.toString(), progress);
                                              //showConfirmDialouge(stationData[index].giftImage.toString());
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(3.0),
                                                  decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey.withOpacity(0.2),
                                                          spreadRadius: 3,
                                                          blurRadius: 7,
                                                          offset: Offset(0, 3), // changes position of shadow
                                                        )
                                                      ],
                                                      color: Colors.white
                                                  ),
                                                  child: Image.asset('assets/gift_icon.png', width: 25.0, height: 25.0,),
                                                ),
                                                SizedBox(
                                                  width: 7.0,
                                                ),
                                                Text(
                                                  Globals.textData["pay_and_get_the_gifts"],
                                                  style: TextStyle(
                                                    color: Color(0xFFFF4E00),
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
  TextEditingController emailController = new TextEditingController();
  TextEditingController invoiceController = new TextEditingController();
  showImageDialouge(String id, String giftPrize, String invoiceUrl, String mediaId, progress) {
//    getGift(id.toString());
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                  insetPadding: EdgeInsets.all(0),
                       shape: RoundedRectangleBorder(
                           borderRadius:
                           BorderRadius.circular(20.0)), //this right here
                    child: Container(
                        height: 500,
                        width: MediaQuery.of(context).size.width*0.9,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20,bottom: 20,left: 10, right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "Make payment & Copy Invoice No. and Put below for Payment Confirmation. and you will get Gift Download option.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: "Gotham",fontWeight: FontWeight.w700),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Divider(),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Gift Prize: ",
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.black,
                                          fontFamily: "Gotham",fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      "\$"+giftPrize,
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.orange,
                                          fontFamily: "Gotham",fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "Invoice Link: ",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontFamily: "Gotham",fontWeight: FontWeight.w700),
                                    ),
                                    InkWell(
                                      onTap: (){
                                        _launchURL(invoiceUrl);
                                      },
                                      child: Text(
                                        "Click to view",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.lightBlueAccent,
                                            fontFamily: "Gotham",fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Divider(),
                              Center(
                                child: Text(
                                  "Your Email",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontFamily: "Gotham",fontWeight: FontWeight.w700),
                                ),
                              ),
                              showTextField(emailController, "Your Email"),
                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: Text(
                                  "Your Invoice No.",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontFamily: "Gotham",fontWeight: FontWeight.w700),
                                ),
                              ),
                              showTextField(invoiceController, "Your Invoice No."),
                              SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: SizedBox(
                                  height: 50,
                                  width:  MediaQuery.of(context).size.width*0.5,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if(emailController.text.isEmpty){
                                        showErrorToast("Enter Email!");
                                      }
                                      else if(!isValidEmail(emailController.text)){
                                        showErrorToast("Enter Valid Email!");
                                      }
                                      else if(invoiceController.text.isEmpty){
                                        showErrorToast("Enter Invoice No!");
                                      }else{
                                        Navigator.pop(context);
                                        progress.showWithText('Sending...');
                                        sendGiftData(invoiceController.text, mediaId, emailController.text, id, progress);
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.lightGreen),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18.0),
                                            )
                                        )
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context).trans('confirmation'),
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontFamily: "Gotham"),
                                    ),
                                  ),
                                ),
                              ),
                              Divider(),
                              // Center(
                              //   child: Container(
                              //     height: 200,
                              //     child: Image(
                              //       image: NetworkImage(
                              //           "https://www.thatsmontreal.com/media-images/$id"),
                              //       fit: BoxFit.contain,
                              //     ),
                              //   ),
                              // ),
                              //
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //   children: <Widget>[
                              //     FlatButton(
                              //       child: Text(
                              //         AppLocalizations.of(context).trans('cancel'),
                              //         style: TextStyle(
                              //             fontSize: 20,
                              //             color: Colors.black,
                              //             fontFamily: "Gotham"),
                              //       ),
                              //       onPressed: () {
                              //         Navigator.pop(context);
                              //       },
                              //     ),
                              //     FlatButton(
                              //       onPressed: () {
                              //         Navigator.pop(context);
                              //         // click on notification to open downloaded file (for Android)
                              //         _downloadImage(
                              //           "https://thatsmontreal2.a2ztech.org/media-images/$id",
                              //           outputMimeType: "image/png",
                              //         );
                              //       },
                              //       child: Text(
                              //         AppLocalizations.of(context).trans('download'),
                              //         style: TextStyle(
                              //             fontSize: 20,
                              //             color: Colors.black,
                              //             fontFamily: "Gotham"),
                              //       ),
                              //     ),
                              //   ],
                              // )
                            ],
                          ),
                        )));
              });
//
        });
  }
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url).then((value) {

      });
    } else {
      throw 'Could not launch $url';
    }
  }
  bool isValidEmail(String email) {
    return RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(email);
  }
  void showErrorToast(Message) {
    Fluttertoast.showToast(
        msg: Message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        //timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }
  Widget showTextField(TextEditingController controller, String hint){
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width*0.6,
        height: 50,
        child: TextField(
          style: TextStyle(
            fontSize: 16,
          ),
          maxLines: 1,
          controller: controller,
          cursorColor: Colors.black,

          decoration: InputDecoration(
            hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 0.5),
              borderRadius: const BorderRadius.all(
                const Radius.circular(5.0),
              ),
            ),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),

          ),
        ),
      ),
    );
  }
  showConfirmDialouge(String id) {
//    getGift(id.toString());
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                    shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20.0)), //this right here
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
                                    image: NetworkImage(
                                        "https://www.thatsmontreal.com/media-images/$id"),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      AppLocalizations.of(context).trans('cancel'),
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontFamily: "Gotham"),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      // click on notification to open downloaded file (for Android)
                                      _downloadImage(
                                        "https://thatsmontreal2.a2ztech.org/media-images/$id",
                                        outputMimeType: "image/png",
                                      );
                                    },
                                    child: Text(
                                      AppLocalizations.of(context).trans('download'),
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontFamily: "Gotham"),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )));
              });
//
        });
  }
  imageWidget(String id) async {
    http.Response response =
    await http.get(Uri.parse(ApiUrl.web_api_url+"api/get_gift/$id"));
    data = json.decode(response.body);
    print("dfsd" + response.body);
    if (data["data"]['gift_image'] != null) {
      image = data["data"]['gift_image'];
//      setState(() {
//        isImageLoading = false;
      image = data["data"]['gift_image'];
      return "https://thatsmontreal2.a2ztech.org/media-images/$image";

//      });

    }
  }
  sendGiftData(String InvoiceId, String MediaId, String CustomerEmail, String imageId, progress)async{
    Map data = {
      'invoice_id': InvoiceId,
      'media_id': MediaId,
      'customer_email': CustomerEmail
    };
    var jsonContent = await http.post(Uri.parse("https://thatsmontreal.com/api/gift-email"), body: data);
    print(jsonContent.body);
    var response = json.decode(jsonContent.body);
    if(response["success"]){
        showConfirmDialouge(imageId);
        progress.dismiss();
        setState(() {
          invoiceController.text = "";
          emailController.text = "";
        });
    }else{
      progress.dismiss();
      showErrorToast("Trancastion Error:\nPlease do transaction first!");
    }
  }
    getStringName()async{
    if(Utilities.language=="en"){
      String jsonContent = await rootBundle.loadString("assets/lang/en.json");
      var data = json.decode(jsonContent);
      setState(() {
        customerName = data["customer_name"];
      });
    }else{
      String jsonContent = await rootBundle.loadString("assets/lang/fr.json");
      var data = json.decode(jsonContent);
      setState(() {
        customerName = data["customer_name"];
      });
    }
  }
}
