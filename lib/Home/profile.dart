import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:thats_montreal/helper/locolizations.dart';
import '../api_url.dart';
import '../utilities.dart';
import 'edit_profile_page.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ProgressHUD progressHUD;
  Helper helper;
  @override
  Widget build(BuildContext context) {
    if(helper == null){
      helper = Helper(context, showProgressDialog, updateState);
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
                    helper.buildProfileImage(),
                    helper.buildName(),
                    helper.buildEmail(),
                    helper.buildProfileInfoCard(),
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

class Helper{
  BuildContext context;
  Function showProgressDialog, updateState;

  Helper(this.context, this.showProgressDialog, this.updateState);

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
        Container(
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
                  child: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: Colors.black,
                  ),
                ),
              ) : Container(width: 15,),

              Expanded(
                child: Container(
                  child: Text(
                    AppLocalizations.of(context).trans('profile').toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              builEditIcon(),
            ],
          ),
        ),
      ],
    );
  }

  Widget builEditIcon(){
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
      },
      child: Container(
        height: 40,
        padding: EdgeInsets.all(12.5),
        child: Image.asset(
          'assets/update_icon.png',
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildProfileImage(){
    return Column(
      children: <Widget>[
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: (){
//            Navigator.push(context, MaterialPageRoute(builder: (context) => FullSizeImage(Utilities.user.image)));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(65),
            child: Container(
              height: 130,
              width: 130,
              color: Colors.grey[300],
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/user.jpg',
                image: '',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 12,
        ),
      ],
    );
  }

  Widget buildName(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Text(
          '',
//          Utilities.user.first_name + ' ' + Utilities.user.last_name,
          style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'semi-bold'
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget buildEmail(){
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 3, bottom: 40),
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Text(
          Utilities.user.email,
          style: TextStyle(
              color: Color(0xFF828282),
              fontSize: 16,
              fontFamily: 'regular'
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget buildProfileInfoCard(){
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [new BoxShadow(
          color: Color(0xFFF4F4F4),
          blurRadius: 10.0,
          spreadRadius: 5.0
        ),],
      ),
      child: Column(
        children: <Widget>[
          Container(
            //margin: EdgeInsets.symmetric(vertical: 8),
            height: 0.6,
            color: Color(0xFFDDDDDD),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).trans('name') + ':',
                  style: TextStyle(
                      color: Color(0xFF3A3A3A),
                      fontSize: 16,
                      fontFamily: 'medium'
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: (){

                    },
                    child: Container(
                      height: 25,
                      child: ListView(
                        children: <Widget>[
                          Center(
                            child: Text(
                              Utilities.user.name,
                              style: TextStyle(
                                  color: Color(0xFF555555),
                                  fontSize: 15,
                                  fontFamily: 'regular'
                              ),
                              maxLines: 1,
                              //overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
