import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:async/async.dart';
import 'package:thats_montreal/helper/locolizations.dart';

import 'api_url.dart';

class ConfirmCard extends StatefulWidget {
  ConfirmCard({this.id});

  final int id;

  @override
  _ConfirmCardState createState() => _ConfirmCardState(videoId: id);
}

class _ConfirmCardState extends State<ConfirmCard> {
  _ConfirmCardState({this.videoId});

  final int videoId;
  Map dataComment;
  List CommentData;
  bool commentLoading = true;
  bool isSending=false;

  TextEditingController textEditingController = TextEditingController();

  Future getComments() async {
    http.Response response = await http.get(
        Uri.parse(ApiUrl.web_api_url+"api/get_comments/$videoId"));
    if (response.statusCode == 200) {
      dataComment = json.decode(response.body);
      CommentData = dataComment["data"];
      print("lengthh" + CommentData.length.toString());
      print(CommentData);
      setState(() {
        commentLoading = false;
      });
    } else {
      print(response.body);
    }
  }

  void _confirmRide(BuildContext context) {
    // alertbox
    final alertDialog = AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          SizedBox(
            width: 40.0,
          ),
          Text(
            AppLocalizations.of(context).trans('sending_request'),
            style: TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) => alertDialog,
      barrierDismissible: false,
    );

    // Snackbar
    final snack = SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        AppLocalizations.of(context).trans('request_sent_msg'),
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      duration: Duration(seconds: 4),
    );
  }

  //handle bad request
  void handleBadRequest() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).trans('oops_try_again')),
            content:
            Text(AppLocalizations.of(context).trans('select_destiny_before_confirm_ride')),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff757575),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        height: MediaQuery
            .of(context)
            .size
            .height / 1,
        padding: EdgeInsets.all(10.0),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
            commentLoading
            ? CircularProgressIndicator(
            backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            )
                : Container(
            height: MediaQuery.of(context).size.height * 0.45,
        child: ListView.builder(itemCount: CommentData.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(

                      image: DecorationImage(
                          image: AssetImage('assets/accountAvatar.jpg'),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.all(Radius.circular(105.0)),
                     ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "${CommentData[index]["name"]}",
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue,
                            fontFamily: 'Poppins'
                        ),
                      ),
                      Container(
                        child: Text("${CommentData[index]["comment"]}",
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 15, fontFamily: 'Poppins',),),
                      ),
                      SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.7,
                        child: Divider(color: Colors.black54,),
                      )
                    ],
                  ),
                ),
              ],
            )
            ;
          },),
      ),
      buildInput(),
      ],
    )),
    )
    ,
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: Colors.black, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                    hintText: AppLocalizations.of(context).trans('type_your_comment'), fillColor: Colors.white
                  //  hintStyle: TextStyle(color: greyColor),
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: isSending==true?CircularProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ):IconButton(
                icon: Icon(Icons.send),
                onPressed: () { setState(() {
                  isSending=true;
                });
                  onSendComment(textEditingController.text, context);},
                // color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      //  decoration: BoxDecoration(border: Border(top: BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
    );
  }

  onSendComment(String text, BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int UserId = pref.getInt("user_id");
    print("UserId" + UserId.toString());
    Map data = {
      'user_id': UserId.toString(),
      'video_id': widget.id.toString(),
      'comment': text,
    };
    var jsonData = null;

    var responce = await http.post(
        Uri.parse(ApiUrl.web_api_url+"api/comments"),
        body: data);

    if (responce.statusCode == 200) {
      jsonData = json.decode(responce.body);
      print(responce.body);
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).trans('comment_is_sent'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
//      Scaffold.of(context).showSnackBar(SnackBar(
//        content: Text("Comment is sent"),
//      ));

      Navigator.of(context).pop();


    } else {
      print("error" + responce.body);
    }
  }
}

