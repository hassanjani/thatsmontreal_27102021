import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_downloader/image_downloader.dart';
import 'package:intl/intl.dart' as intl;
import 'package:progress_hud/progress_hud.dart';
import 'package:share/share.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../api_url.dart';
import '../helper/locolizations.dart';
import '../model/md_comment.dart';
import '../model/video_data_entity.dart';
import '../utilities.dart';

class ViewStationVideo extends StatefulWidget {
  final VideoDataEntity stationData;
  final int index;

  ViewStationVideo(this.stationData, this.index);

  @override
  _ViewStationVideoState createState() => _ViewStationVideoState();
}

class _ViewStationVideoState extends State<ViewStationVideo> {
  ProgressHUD progressHUD;
  Helper helper;
  @override
  Widget build(BuildContext context) {
    if(helper == null){
      helper = Helper(context, showProgressDialog, updateState, widget.stationData, widget.index);
      progressHUD = new ProgressHUD(
        backgroundColor: Colors.black12,
        color: Theme.of(context).accentColor,//Colors.white,
        containerColor: Colors.transparent, //Color(0xFF591758),
        borderRadius: 5.0,
        text: '',//Utilities.language == 'en' ? Utilities.pleaseWaitEn : Utilities.pleaseWaitAr,
        loading: true,
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              helper.buildStatusBar(),
              helper.buildActionBar(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  children: <Widget>[
                    helper.buildTitleHeading(),
                    helper.buildPostCard(),
                    SizedBox(
                      height: 15.0,
                    ),
                    helper.buildCommentList(),
                  ],
                ),
              ),
              helper.buildSafeArea(),
            ],
          ),
          progressHUD,
        ],
      ),
    );
  }

  void showProgressDialog(bool value) {
    setState(() {
      if (value) {
        progressHUD.state.show();
      } else {
        progressHUD.state.dismiss();
      }
    });
  }

  void updateState(){
    setState(() {

    });
  }
}

class Helper {
  BuildContext context;
  Function showProgressDialog, updateState;
  VideoDataEntity stationData;
  int index;
  bool isImageLoading;
  String _message = "";
  String _path = "";
  String _size = "";
  String _mimeType = "";
  File _imageFile;
  int _progress = 0;
  FocusNode commentNode;
  String comment;
  TextEditingController commentController = TextEditingController();
  bool isApiLoaded = false;

  List<MDComment> commentList = [];

  YoutubePlayerController _controller;

  Helper(this.context, this.showProgressDialog, this.updateState, this.stationData, this.index){
    print('video Id' + stationData.id.toString());
    apiGetComments();
    if (_controller != null) {
      _controller.dispose();
    }
  }

  Widget buildStatusBar() {
    return Container(
      height: MediaQuery
          .of(context)
          .padding
          .top,
      color: Color(0xFF222222),
    );
  }

  Widget buildSafeArea() {
    return Container(
      height: MediaQuery
          .of(context)
          .padding
          .bottom,
      color: Color(0xFF222222),
    );
  }

  Widget buildActionBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 60.0,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 20,
            ),
            Navigator.canPop(context) ? InkWell(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context, true);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF151515),
                ),
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.arrow_back,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ) : Container(width: 15,),
          ],
        ),
      ],
    );
  }

  Widget buildTitleHeading(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 35.0,
        ),
        Text(
          stationData.title,
          style: TextStyle(color: Color(0xFF151515), fontSize: 20.0, fontWeight: FontWeight.w900),
        ),
        SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  Widget buildPostCard(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50.0,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: YoutubePlayer(
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
                child: InkWell(
                  onTap: (){
                    print(stationData.giftImage);
                    isImageLoading = true;
                    showImageDialouge(stationData.giftImage.toString());
                  },
                  child: Column(
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
                        height: 10.0,
                      ),
                      Text(
                        AppLocalizations.of(context).trans('get_a_free_gift'),
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
              Expanded(
                child: InkWell(
                  onTap: (){
                    Share.share(stationData.videoUrl);
                  },
                  child: Column(
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
                        child: Image.asset('assets/share_icon.png', width: 20.0, height: 20.0,),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        AppLocalizations.of(context).trans('share'),
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          buildCommentField(),
          SizedBox(
            height: 10.0,
          ),
          buildCommentButton(),
          SizedBox(
            height: 10.0,
          )
        ],
      ),
    );
  }

  Widget buildCommentField() {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                SizedBox(
                  height: 7.0,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: (){
                    FocusScope.of(context).requestFocus(commentNode);
                  },
                  child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Color(0xFF787777), width: 1.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              onSubmitted: (value){
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                              focusNode: commentNode,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(0),
                                border: OutlineInputBorder(borderSide: BorderSide.none),
                                hintStyle: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: 'regular',
                                  color: Color(0xFFA3A3A3),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: 'regular',
                                color: Color(0xFF666666),
                              ),
                              controller: commentController,
                              maxLines: 1,
                              onChanged: (value){
                                comment = value;
                              },
                            ),
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCommentButton(){
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: (){
              if(comment.length > 1){
                showProgressDialog(true);
                apiSendComment();
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal:15.0,vertical: 5.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent,),
                borderRadius: BorderRadius.circular(3.0)
              ),
              child: Center(
                child: Text(
                    AppLocalizations.of(context).trans('comment'),
                  style: TextStyle(
                    color: Color(0xFF787777),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildCommentList(){
    return Container(
      padding: EdgeInsets.only(top: 45.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40.0),),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            )
          ]
      ),
      child: commentList.isEmpty && isApiLoaded ? Container(
        height: MediaQuery.of(context).size.width/3,
        child: Center(
          child: Text(
            AppLocalizations.of(context).trans('no_comment_available'),
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18.0,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ) : ListView.builder(itemBuilder: buildCommentCard,
        padding: EdgeInsets.all(0.0),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: commentList.length,
      ),
    );
  }


  Widget buildCommentCard(context, index){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(3.0, 0), // changes position of shadow
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  commentList[index].name,
                  style: TextStyle(
                    color: Color(0xFF20AE62),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                  dateFormat(commentList[index].created_at),
                style: TextStyle(
                  color: Color(0xFFA4A0A0),
                  fontWeight: FontWeight.w300,
                  fontSize: 14
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            commentList[index].comment,
            style: TextStyle(
                color: Color(0xFFA4A0A0),
                fontWeight: FontWeight.w300,
                fontSize: 14
            ),
          ),
        ],
      ),
    );
  }


  showImageDialouge(String id) {
//    getGift(id.toString());
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
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
                                    image: NetworkImage(
                                        "https://www.thatsmontreal.com/media-images/$id"),
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

  String dateFormat(String date){
    List<String> newDate = date.split(' ');
    var dateTimeStame = DateTime.parse(date).toUtc().millisecondsSinceEpoch;
    print(dateTimeStame.toString());

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateTimeStame);
    return intl.DateFormat("MMM dd, yyyy").format(dateTime);
//    return newDate[0];
  }



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
              _message = error.toString();
              _path = path;
              updateState();
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
        _message = error.message;
        updateState();
      return;
    }

//    if (!mounted) return;
    Fluttertoast.showToast(
        msg: AppLocalizations.of(context).trans('your_gift_saved_to_gallery'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
      var location = Platform.isAndroid ? "Directory" : "Photo Library";
      _message = 'Saved as "$fileName" in $location.\n';
      _size = 'size:     $size';
      _mimeType = 'mimeType: $mimeType';
      _path = path;

      if (!_mimeType.contains("video")) {
        _imageFile = File(path);
      }
      updateState();
      return;
  }



  apiSendComment(){
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';

    Map<String, String> params = Map();
    params['video_id'] = stationData.id.toString();
    params['user_id'] = Utilities.user.user_id.toString();
    params['comment'] = comment.trim();

    http.post(Uri.parse(ApiUrl.web_api_url + '/api/comments'), headers: header, body: params).then((response) async {
      Map mapppedResponse = jsonDecode(response.body);
      print('-----------------MappedResponse----------------');
      print(mapppedResponse);
      print('-----------------MappedResponse----------------');
      String msg;
      if (mapppedResponse['status']) {
        msg = mapppedResponse['message'];
        commentController.clear();
        comment = '';
        updateState();
      } else {

      }
      showProgressDialog(false);
      updateState();
      Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor:Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }


  apiGetComments(){
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';

    http.get(Uri.parse(ApiUrl.web_api_url + '/api/get_comments/${stationData.id}'), headers: header).then((response) async {
      isApiLoaded = true;
      Map mapppedResponse = jsonDecode(response.body);
      print('-----------------MappedResponse----------------');
      print(mapppedResponse);
      print('-----------------MappedResponse----------------');
      String msg;
      if (mapppedResponse['status']) {
        commentList = (mapppedResponse['data'] as List).map((e) => MDComment.fromJson(e)).toList();
        updateState();
      } else {
        commentList = [];
//        msg = mapppedResponse['message'];
      }
      showProgressDialog(false);
      updateState();
      Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor:Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }

}