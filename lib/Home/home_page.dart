import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:thats_montreal/Pdf_Viewer.dart';
import 'package:thats_montreal/api_url.dart';
import 'package:thats_montreal/globals.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/utilities.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../Email.dart';
import '../News.dart';
import '../SpecialPromotion.dart';
import '../Stations.dart';
import '../WhoWeAre.dart';
import 'package:custom_rounded_rectangle_border/custom_rounded_rectangle_border.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProgressHUD progressHUD;
  Helper helper;

  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper = Helper(context, showProgressDialog, updateState);
      progressHUD = new ProgressHUD(
        backgroundColor: Colors.black12,
        color: Theme.of(context).accentColor,
        //Colors.white,
        containerColor: Colors.transparent,
        //Color(0xFF591758),
        borderRadius: 5.0,
        text: '',
        //Utilities.language == 'en' ? Utilities.pleaseWaitEn : Utilities.pleaseWaitAr,
        loading: false,
      );
    }
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(0.0),
                physics: ClampingScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.07,
                  ),
                  helper.buildProfile(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.08,
                  ),
                  helper.buildChooseOrColorText(),
                  helper.buildMainBody(),
                  helper.buildMapDownloadWidget(),
                ],
              ),
            ),
          ],
        ),
        helper.showNotification(),
        progressHUD,
      ],
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

  void updateState() {
    setState(() {});
  }
}

class Helper {
  BuildContext context;
  Function showProgressDialog, updateState;

  double height = 110;
  double width = 130;
  double radius = 120;
  double blackHeight = 110;
  double blackwidth = 50;

  Helper(this.context, this.showProgressDialog, this.updateState) {
    getLanguage();
  }
  getLanguage()async{
    print("geting language");
    if(Utilities.language=="en"){
      String jsonContent = await rootBundle.loadString("assets/lang/en.json");
      Globals.textData = json.decode(jsonContent);
    }else{
      String jsonContent = await rootBundle.loadString("assets/lang/fr.json");
      Globals.textData  = json.decode(jsonContent);
    }
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

  Widget buildProfile() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 10.0,
        ),
        !Utilities.isGuest
            ? Container(
                height: 60.0,
                width: 60.0,
                decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFFF9700), width: 3.0),
                    borderRadius: BorderRadius.circular(30.0)),
                child: ClipRRect(
                  child: FadeInImage.assetNetwork(
                      placeholder: 'assets/accountAvatar.jpg', image: ApiUrl.user_image_url + Utilities.user.image),
                  borderRadius: BorderRadius.circular(30.0),
                ),
              )
            : Container(),
        SizedBox(
         width: 12.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  !Utilities.isGuest
                      ? AppLocalizations.of(context).trans('hi') + " " + Utilities.user.name+","
                      : AppLocalizations.of(context).trans('hi'),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16.0),
                ),

              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).trans('welcome_to'),
                  style: TextStyle(color: Color(0xFF707070), fontSize: 16.0, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  "That's Montreal!",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16.0),
                ),
              ],
            )
          ],
        ),

      ],
    );
  }
 Widget showNotification(){
   return Positioned(
     top: MediaQuery.of(context).size.height*0.08,
     right: 15,
     child: Container(
       child: Icon(
           Icons.notifications_active_outlined
       ),
     ),
   );
 }
  Widget buildChooseOrColorText() {
    return Column(
      children: [
        Container(
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context).trans('choose_a'),
                style: TextStyle(color: Colors.black, fontFamily: 'Poppins', fontSize: 20),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                AppLocalizations.of(context).trans('direction'),
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                AppLocalizations.of(context).trans('or'),
                style: TextStyle(color: Colors.black, fontFamily: 'Poppins', fontSize: 20),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                AppLocalizations.of(context).trans('color') + "!",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Globals.textData["colors"].toString() + " ",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
            Text(
              Globals.textData["for_your_favourite_metro_line"].toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 14.0),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Globals.textData["directions"].toString() + " ",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0),
            ),
            Text(
              Globals.textData["for_other_information"].toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 14.0),
            ),
          ],
        ),
        SizedBox(
          height: 30.0,
        ),
      ],
    );
  }

  Widget buildMainBody() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.width*0.03,
              bottom: MediaQuery.of(context).size.width*0.03
          ),
          child: Container(
            width: MediaQuery.of(context).size.width*0.84,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.width*0.02,
              bottom: MediaQuery.of(context).size.width*0.02
            ),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(radius),
              boxShadow:  [
                BoxShadow(
                  color: Colors.orangeAccent.withOpacity(0.1),
                  spreadRadius: 15,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Stations(
                                      stationsColor: Colors.orange,
                                      strMetroName: "orange_subway_line",
                                      stationCount: 30,
                                    )));
                      },
                      child: Container(
                        padding: EdgeInsets.all(35),
                        height: height,
                        width: MediaQuery.of(context).size.width*0.32,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(radius),
                          ),
                          //image: DecorationImage(image: AssetImage('assets/subway.png'), fit: BoxFit.fill)
                        ),
                        child: Image(
                          image: AssetImage('assets/subway.png'),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.15,
                      height: blackHeight,
                      decoration: BoxDecoration(color: Colors.black),
                      child: Column(children: <Widget>[
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => NewsScreen()));
                          },
                          child: Text(
                            AppLocalizations.of(context).trans('n'),
                            style: TextStyle(fontSize: 30, color: Colors.yellow, fontWeight: FontWeight.bold),
                          ),
                        ),
                        //Text('N', style: TextStyle(color: Colors.yellow, fontSize: 30),),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Stations(
                                      stationsColor: Colors.blue,
                                      strMetroName: "blue_subway_line",
                                      stationCount: 12,
                                    )));
                      },
                      child: Container(
                        padding: EdgeInsets.all(35),
                        height: height,
                        width: MediaQuery.of(context).size.width*0.32,
                        decoration: BoxDecoration(
                            color: Colors.blue[700], borderRadius: BorderRadius.only(topRight: Radius.circular(radius))),
                        child: Image(
                          image: AssetImage('assets/subway.png'),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  width: MediaQuery.of(context).size.width*0.79,
                  height: MediaQuery.of(context).size.width*0.15,
                  decoration: BoxDecoration(color: Colors.black),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => WhoWeAre()));
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => WhoWeAre()));
                          },
                          child: Text(
                            AppLocalizations.of(context).trans('w'),
                            style: TextStyle(fontSize: 30, color: Colors.yellow, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _launchURL("yousafzulpich@gamil.com", "For Bussinesss", "Your proposal");
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EmailScreen()));
                          },
                          child: Text(
                            AppLocalizations.of(context).trans('e'),
                            style: TextStyle(fontSize: 30, color: Colors.yellow, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Stations(
                                      stationsColor: Colors.green,
                                      strMetroName: "green_subway_line",
                                      stationCount: 25,
                                    )));
                      },
                      child: Container(
                        padding: EdgeInsets.all(35),
                        height: height,
                        width: MediaQuery.of(context).size.width*0.32,
                        decoration: BoxDecoration(
                            color: Colors.green, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(radius))),
                        child: Image(
                          image: AssetImage('assets/subway.png'),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.15,
                      height: blackHeight,
                      decoration: BoxDecoration(color: Colors.black),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialPormotion()));
                            },
                            child: Text(
                              AppLocalizations.of(context).trans('s'),
                              style: TextStyle(fontSize: 30, color: Colors.yellow, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Stations(
                                      stationsColor: Colors.yellow,
                                      strMetroName: "yellow_subway_line",
                                      stationCount: 2,
                                    )));
                      },
                      child: Container(
                        padding: EdgeInsets.all(35),
                        height: height,
                        width: MediaQuery.of(context).size.width*0.32,
                        decoration: BoxDecoration(
                            color: Colors.yellow, borderRadius: BorderRadius.only(bottomRight: Radius.circular(radius))),
                        child: Image(
                          image: AssetImage('assets/subway.png'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          // margin: EdgeInsets.only(top: 70.0),
          height: 170,
          width: 170,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/logo.png'), fit: BoxFit.contain),
            color: Colors.black,
            border: Border.all(color: Colors.yellow, width: 3),
            shape: BoxShape.circle,
          ),
        ),
        Positioned(
            top: 0,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide( //                   <--- left side
                    color: Color(0xFFFF0000),
                    width: 1.0,
                  ),
                  left: BorderSide( //                   <--- left side
                    color: Color(0xFFFF0000),
                    width: 1.0,
                  ),
                ),
              ),
              height: 50,
              width: 50,
            )
        ),
        Positioned(
            top: 0,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide( //                   <--- left side
                    color: Color(0xFFFF0000),
                    width: 1.0,
                  ),
                  right: BorderSide( //                   <--- left side
                    color: Color(0xFFFF0000),
                    width: 1.0,
                  ),
                ),
              ),
              height: 50,
              width: 50,
            )
        ),
        Positioned(
            bottom: 0,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide( //                   <--- left side
                    color: Color(0xFFFF0000),
                    width: 1.0,
                  ),
                  left: BorderSide( //                   <--- left side
                    color: Color(0xFFFF0000),
                    width: 1.0,
                  ),
                ),
              ),
              height: 50,
              width: 50,
            )
        ),
        Positioned(
            bottom: 0,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide( //                   <--- left side
                    color: Color(0xFFFF0000),
                    width: 1.0,
                  ),
                  right: BorderSide( //                   <--- left side
                    color: Color(0xFFFF0000),
                    width: 1.0,
                  ),
                ),
              ),
              height: 50,
              width: 50,
            )
        ),
      ],
    );
  }

  Widget buildMapDownloadWidget() {
    return Column(
      children: [
        SizedBox(
          height: 30.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(
                height: 5.0,
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  print("ali");
                  Get.to(PdfMapViewer(), arguments: ['montreal_metro_map', "assets/map.pdf"]);
                 // Navigator.push(context, MaterialPageRoute(builder: (context) => PdfMapViewer()));
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context).trans('see_montreal_metro_map'),
                        style: TextStyle(fontSize: 17, color: Colors.black, fontFamily: 'Poppins')),
                    Text(
                      AppLocalizations.of(context).trans('here').toUpperCase(),
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.orange, fontSize: 17),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 80.0,
        )
      ],
    );
  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
