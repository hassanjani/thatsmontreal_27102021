import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_downloader/image_downloader.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import './Home/view_station_video.dart';
import './SignUp.dart';
import './api_url.dart';
import './bottom_sheet.dart';
import './helper/locolizations.dart';
import './model/video_data_entity.dart';
import './utilities.dart';
import 'providers/checked_icons_provider.dart';

class MediaDisplayPage extends StatefulWidget {
  @override
  _MediaDisplayPageState createState() => _MediaDisplayPageState();
}

class _MediaDisplayPageState extends State<MediaDisplayPage> {
  final String myMetroName = 'Search Results';
  bool isLoging;
  YoutubePlayerController _controller;
  Map data;
  List<VideoDataEntity> stationData;
  Map dataComment;
  List commentData;
  String image;
  bool isImageLoading;
  String _message = "";
  String _path = "";
  String _size = "";
  String _mimeType = "";
  File _imageFile;
  int _progress = 0;

  Future<List<VideoDataEntity>> getData(String stationId) async {
    http.Response _response = await http.get(Uri.parse(ApiUrl.web_api_url + "api/spot-it?types=$stationId"));
    List<VideoDataEntity> videoList = new List();
    if (_response.statusCode == 200) {
      List lst = jsonDecode(_response.body)['data'];
      lst.forEach((e) {
        videoList.add(VideoDataEntity().fromJson(e));
      });
    }
    return videoList;
  }

  Future getGift(String videoId) async {
    print(videoId);
    http.Response response = await http.get(Uri.parse(ApiUrl.web_api_url + "api/get_gift/$videoId"));
    data = json.decode(response.body);
    print("dfsd" + response.body);
    if (data["data"]['gift_image'] != null) {
      image = data["data"]['gift_image'];
      setState(() {
        isImageLoading = false;
        image = data["data"]['gift_image'];
      });
    }
  }

  Future<void> _downloadImage(String url,
      {AndroidDestinationType destination, bool whenError = false, String outputMimeType}) async {
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
        imageId = await ImageDownloader.downloadImage(url, outputMimeType: outputMimeType).catchError((error) {
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

  @override
  void initState() {
    super.initState();
    if (!Utilities.isGuest) {
      isLoging = true;
    } else {
      isLoging = false;
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CheckedIconsProvider provider = Provider.of<CheckedIconsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          myMetroName ?? "",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
        child: SingleChildScrollView(
          child: FutureBuilder(
              future: getData(provider.list),
              builder: (context, AsyncSnapshot<List<VideoDataEntity>> snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data);
                  return snapshot.data.isEmpty
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context).trans('no_video_available'),
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
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
                            SizedBox(
                              height: 20.0,
                            ),
                            Container(
                              height: 1.0,
                              decoration: BoxDecoration(
                                color: Color(0xFFC2C2C2),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Center(
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
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                VideoDataEntity stationData = snapshot.data[index];
                                print(stationData.videoUrl);
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ViewStationVideo(stationData, index)));
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: YoutubePlayer(
                                          onReady: () {
                                            setState(() {
                                              print('Video Ready');
                                            });
                                          },
                                          controller: _controller = YoutubePlayerController(
                                            initialVideoId: YoutubePlayer.convertUrlToId(stationData.videoUrl),
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
                                              stationData.title,
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
                                            onTap: () {
                                              isLoging == true
                                                  ? showModalBottomSheet(
                                                          context: context,
                                                          builder: (context) => ConfirmCard(id: stationData.id))
                                                      .then((snack) => Scaffold.of(context).showSnackBar(snack))
                                                  : Navigator.push(
                                                      context, MaterialPageRoute(builder: (context) => SignUp()));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(3.0),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.2),
                                                  spreadRadius: 3,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                )
                                              ], color: Colors.white),
                                              child: Image.asset(
                                                'assets/comment_icon.png',
                                                width: 20.0,
                                                height: 20.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Share.share(stationData.videoUrl);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(3.0),
                                              decoration: BoxDecoration(boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.2),
                                                  spreadRadius: 3,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3), // changes position of shadow
                                                )
                                              ], color: Colors.white),
                                              child: Image.asset(
                                                'assets/share_icon.png',
                                                width: 20.0,
                                                height: 20.0,
                                              ),
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
                                      Divider(color: Colors.grey,thickness: 1.0,),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: InkWell(
                                          onTap: () {
                                            print(stationData.giftImage);
                                            isImageLoading = true;
                                            showImageDialouge(stationData.giftImage.toString());
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(3.0),
                                                decoration: BoxDecoration(boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.2),
                                                    spreadRadius: 3,
                                                    blurRadius: 7,
                                                    offset: Offset(0, 3), // changes position of shadow
                                                  )
                                                ], color: Colors.white),
                                                child: Image.asset(
                                                  'assets/gift_icon.png',
                                                  width: 25.0,
                                                  height: 25.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 7.0,
                                              ),
                                              Text(
                                                AppLocalizations.of(context).trans('free_gifts'),
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
                          ],
                        );
                }
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                );
              }),
        ),
      ),
    );
  }

  showImageDialouge(String id) {
//    getGift(id.toString());
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return Dialog(
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
                                image: NetworkImage("https://www.thatsmontreal.com/media-images/$id"),
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
                                child: Text(
                                  AppLocalizations.of(context).trans('cancel'),
                                  style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: "Gotham"),
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
                                  style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: "Gotham"),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )));
          });
        });
  }

  imageWidget(String id) async {
    http.Response response = await http.get(Uri.parse(ApiUrl.web_api_url + "api/get_gift/$id"));
    data = json.decode(response.body);
    print("dfsd" + response.body);
    if (data["data"]['gift_image'] != null) {
      image = data["data"]['gift_image'];
      image = data["data"]['gift_image'];
      return "https://thatsmontreal2.a2ztech.org/media-images/$image";
    }
  }
}
