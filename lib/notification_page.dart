import 'dart:convert';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thats_montreal/model/md_notification.dart';
import 'package:thats_montreal/utilities.dart';

import 'Home/announcement_detail.dart';
import 'api_url.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Helper helper;
  ProgressHUD progressHUD;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if(helper == null){
      helper = Helper(context, showProgressDialog, updateState);
      progressHUD = new ProgressHUD(
        backgroundColor: Colors.black12,
        color: Theme.of(context).accentColor,//Colors.white,
        containerColor: Colors.transparent, //Color(0xFF591758),
        borderRadius: 5.0,
        text: '',
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
                      physics: ClampingScrollPhysics(),
                      padding: EdgeInsets.all(0),
                      children: <Widget>[
                        helper.notificationList == null ? Container() : helper.buildNotificationList(),
                      ],
                    )),
                helper.buildSafeArea(),
              ],
            ),
            Positioned(
              child: progressHUD,
            ),
          ],
        ));
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
  Function showProgressDialog;
  Function updateState;
  bool isApiLoaded = false;

  List<MDNotification> notificationList;

  Helper(this.context, this.showProgressDialog, this.updateState){
    apiGetNotification();
  }

  Widget buildStatusBar() {
    return Container(
      height: MediaQuery.of(context).padding.top,
      color: Color(0xFF222222),
    );
  }

  Widget buildSafeArea() {
    return Container(
      height: MediaQuery.of(context).padding.bottom,
      color: Color(0xFF222222),
    );
  }

  Widget buildActionBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 40.0,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white
          ),
          height: 55.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 2,
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
                  height: 50,
                  padding: EdgeInsets.all(14),
                  child: Image.asset('assets/close_icon.png', width: 30,),
                ),
              ) : Container(width: 15,),
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Text(
              AppLocalizations.of(context).trans('notification'),
              style: TextStyle(
                color: Color(0xFF151515),
                fontSize: 22.0,
                fontWeight: FontWeight.w900
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20.0,
        )
      ],
    );
  }

  Widget buildNotificationList(){
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
      child: notificationList.isEmpty && isApiLoaded ? Container(
        height: MediaQuery.of(context).size.width,
        child: Center(
          child: Text(
            AppLocalizations.of(context).trans('no_notification_available'),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18.0,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ) : ListView.builder(itemBuilder: buildNotificationItem,
      padding: EdgeInsets.all(0.0),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: notificationList.length,
      ),
    );
  }

  Widget buildNotificationItem(context, index){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: InkWell(
        onTap: (){
          apiReadNotification(notificationList[index].id);
          Navigator.push(context, MaterialPageRoute(builder: (context)=> AnnouncementDetail(notificationList[index].announement.id))).then((value){
            showProgressDialog(true);
            apiGetNotification();
          });
        },
        child: Column(
          children: [
            SizedBox(
              height: 15.0,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    notificationList[index].announement.title,
                    style: TextStyle(
                      color: notificationList[index].read_at == null ? Color(0xFF535353) : Color(0xFFA4A0A0),//A4A0A0
                      fontSize: 20.0,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      dateFormat(notificationList[index].created_at),
                      style: TextStyle(
                        color: notificationList[index].read_at == null ? Color(0xFF515C6F) : Color(0xFFA4A0A0),
                        fontSize: notificationList[index].read_at == null ? 20.0 : 16.0,
                        fontWeight: notificationList[index].read_at == null ? FontWeight.w900 :FontWeight.w300
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    notificationList[index].read_at == null ? Container(
                      height: 10.0,
                      width: 10.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFF94E0D),
                        borderRadius: BorderRadius.circular(5.0)
                      ),
                    ) : Container(),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            Container(
              height: 1.5,
              margin: EdgeInsets.only(right: MediaQuery.of(context).size.width/6),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xFFC2C2C2)
              ),
            )
          ],
        ),
      ),
    );
  }

  String dateFormat(String date){
    List<String> newDate = date.split(' ');
    print(date);
    var dateTimeStame = DateTime.parse(date).toUtc().millisecondsSinceEpoch;

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateTimeStame);
    return intl.DateFormat("MMM dd, yyyy").format(dateTime);
//    return newDate[0];
  }

  apiGetNotification(){
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';

    http.get(Uri.parse(ApiUrl.web_api_url+'/api/notifications?user_id=${Utilities.user.user_id}'),headers: header).then((response) async {
      isApiLoaded = true;
      List<dynamic> mapppedResponse = jsonDecode(response.body);
      print('-----------------MappedResponse----------------');
      print(mapppedResponse);
      print('-----------------MappedResponse----------------');
      String msg;
      if (mapppedResponse.length > 0) {
        notificationList = (mapppedResponse as List).map((e) => MDNotification.fromJson(e)).toList();
        updateState();
      } else {
        notificationList = [];
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

  apiReadNotification(String notificationId){
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';

    http.get(Uri.parse(ApiUrl.web_api_url+'api/notifications/read?user_id=${Utilities.user.user_id}&notification_id=$notificationId'),headers: header).then((response) async {

      print('----------------Read Notification ID------------------');
      print(response.body.toString());
      print('----------------Read Notification ID------------------');
      updateState();
    });
  }


}