import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thats_montreal/Home/login.dart';
import 'package:thats_montreal/Home/register_user.dart';
import 'package:thats_montreal/News.dart';
import 'package:thats_montreal/Pdf_Viewer.dart';
import 'package:thats_montreal/SpecialPromotion.dart';
import 'package:thats_montreal/Stations.dart';
import 'package:thats_montreal/WhoWeAre.dart';
import 'package:thats_montreal/globals.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/utilities.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'Email.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double height = 130;
  double width = 130;
  double radius = 120;
  double blackHeight = 130;
  double blackwidth = 50;

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool isLoging;

  checkLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool('isLoggedIn') == true) {
      print("loging status $isLoging");
      isLoging = true;
    } else {
      isLoging = false;
      print("loging status $isLoging");
    }
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
  Alert(BuildContext context) {
    // alertbox
    final alertDialog = AlertDialog(
      title: Text(
        AppLocalizations.of(context).trans('alert'),
        style: TextStyle(
            color: Color(0xff474949)
        ),
      ),
      content: Text(
        AppLocalizations.of(context).trans('not_login_msg'),
        style: TextStyle(color: Colors.grey),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(AppLocalizations.of(context).trans('yes')),
          onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Login()));
          },
        ),
        FlatButton(
          child: Text(AppLocalizations.of(context).trans('no')),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
    showDialog(
      context: context, builder: (BuildContext context) => alertDialog,
      barrierDismissible: false,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(AppLocalizations.of(context).trans('app_name')),
//        leading: GestureDetector(
//          onTap: () {
//            isLoging == false
//                ? Alert(context)
//                : Navigator.of(context).pushNamed('/profile');
//          },
//          child: Padding(
//              padding: EdgeInsets.all(12),
//              child: CircleAvatar(
//                backgroundImage: AssetImage("assets/accountAvatar.jpg"),
//              )),
//        ),
      ),
      body: Stack(children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 30),
          alignment: Alignment.topCenter,
          child: Text(
            AppLocalizations.of(context).trans('choose_direction_or_color'),
            style: TextStyle(
                color: Colors.black, fontFamily: 'Poppins', fontSize: 20),
          ),
        ),
        Column(
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
                                  strMetroName: "Orange",
                                  stationCount: 30,
                                )));
                  },
                  child: Container(
                    padding: EdgeInsets.all(35),
                    height: height,
                    width: width,
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
                  width: blackwidth,
                  height: blackHeight,
                  decoration: BoxDecoration(color: Colors.black),
                  child: Column(children: <Widget>[
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewsScreen()));
                      },
                      child: Text(
                        AppLocalizations.of(context).trans('n'),
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold),
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
                    width: width,
                    decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(radius))),
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
              width: 310,
              height: 50,
              decoration: BoxDecoration(color: Colors.black),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => WhoWeAre()));
                    },
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WhoWeAre()));
                      },
                      child: Text(
                        AppLocalizations.of(context).trans('w'),
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchURL("yousafzulpich@gamil.com", "For Bussinesss",
                          "Your proposal");
                    },
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmailScreen()));
                      },
                      child: Text(
                        AppLocalizations.of(context).trans('e'),
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold),
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
                                  strMetroName: "Green",
                                  stationCount: 25,
                                )));
                  },
                  child: Container(
                    padding: EdgeInsets.all(35),
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(radius))),
                    child: Image(
                      image: AssetImage('assets/subway.png'),
                    ),
                  ),
                ),
                Container(
                  width: blackwidth,
                  height: blackHeight,
                  decoration: BoxDecoration(color: Colors.black),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SpecialPormotion()));
                        },
                        child: Text(
                          AppLocalizations.of(context).trans('s'),
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold),
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
                                  strMetroName: "Yellow",
                                  stationCount: 2,
                                )));
                  },
                  child: Container(
                    padding: EdgeInsets.all(35),
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(radius))),
                    child: Image(
                      image: AssetImage('assets/subway.png'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Center(
          child: Container(
            height: 170,
            width: 170,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/logo.png'), fit: BoxFit.contain),
              color: Colors.black,
              border: Border.all(color: Colors.yellow, width: 3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 10,
          right: 10,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                          height: 40.0,
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context).trans('login'), style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold
                            ),
                            ),
                          ),
                        ),
                      ),
                    ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> RegisterUser()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(5.0)
                            ),
                            height: 40.0,
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).trans('register'), style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold
                              ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    print("ali");
                    //Get.to(PdfMapViewer(), arguments: ['montreal_metro_map', "assets/map.pdf"]);
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => PdfMapViewer()));
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
        )
      ]),
    );
  }

  launchWebUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
