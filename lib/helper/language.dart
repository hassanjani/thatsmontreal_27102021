import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:thats_montreal/Home/onboarding_page.dart';
import 'package:thats_montreal/HomeScreen.dart';
import 'package:thats_montreal/SplashScreen.dart';
import 'package:thats_montreal/get_started.dart';
import 'package:thats_montreal/globals.dart';
import 'package:thats_montreal/utilities.dart';

import 'application.dart';
import 'locolizations.dart';

class Language extends StatefulWidget {
  bool isFromHomeSettings = false;
  Language(this.isFromHomeSettings);
  @override
  _LanguageState createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  Helper helper;
  ProgressHUD progressHUD;
  @override
  Widget build(BuildContext context) {
    if(helper == null){
      progressHUD = new ProgressHUD(
        backgroundColor: Colors.black12,
        color: Theme.of(context).accentColor,
        //containerColor: Colors.blue,
        borderRadius: 5.0,
        text: '',
        loading: false,
      );
      helper = Helper(context, changeLanguageSelector, reminderCheckListener,widget.isFromHomeSettings, showProgressDialog, updateState);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              //helper.buildStatusBar(),
              //helper.buildActionBar(),
              Expanded(
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.only(top: 100),
                  children: <Widget>[
                    // SizedBox(
                    //   height: 25.0,
                    // ),
                    helper.buildLogo(),
                    helper.buildChangeLanguageText(),
                    helper.buildEnglishFrenchCard(),
                    helper.rememberChoiceCheckbox(),
                    helper.buildButton(),
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

  @override
  void dispose() {
    super.dispose();
  }

  void changeLanguageSelector() {
    setState(() {
      helper.isEnglish = !helper.isEnglish;
    });
  }

  void reminderCheckListener() {
    setState(() {
      helper.isRemember = !helper.isRemember;
    });
  }

  void updateState(){
    if(mounted){
      setState(() {

      });
    }
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

}


class Helper {
  BuildContext context;
  bool isEnglish = true;
  bool isRemember = false;
  Function changeLanguageSelector;
  Function reminderCheckListener;
  Function showProgressDialog, updateState;
  bool isFromHomeSettings = false;
  String previousLanguage;
  SharedPreferences preferences;
  Language language;

  Helper(this.context, this.changeLanguageSelector, this.reminderCheckListener,this.isFromHomeSettings, this.showProgressDialog, this.updateState){
    language = Language(false);
    SharedPreferences.getInstance().then((sharedPreference){
      this.preferences = sharedPreference;
      isRemember = preferences.getBool('isRemember') ?? false;
      updateState();
    });
    previousLanguage = Utilities.language;
    if(Utilities.language == "en"){
      isEnglish = true;
    }
    else{
      isEnglish = false;
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

  Widget buildActionBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
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
                  child: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ) : Container(width: 15,),

              Container(
                child: Text(
                  AppLocalizations.of(context).trans('app_name'),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLogo() {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 30, right: 30),
      child: Image.asset('assets/LOGO.jpg', height: MediaQuery.of(context).size.width/3,),
    );
  }

  Widget buildChangeLanguageText() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 25.0,
        ),
        Text(
          AppLocalizations.of(context).trans("change_language"),
          style: TextStyle(
              color: Color(0xFF1F1F1F), fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(
          AppLocalizations.of(context).trans("choose_language_to_continue"),
          style: TextStyle(
              color: Color(0xFF5B5B5B), fontSize: 13.0, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 30.0,
        ),
      ],
    );
  }

  Widget buildEnglishFrenchCard() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        decoration: new BoxDecoration(
          color: Colors.white,
          boxShadow: [new BoxShadow(
            color: Colors.grey[350],
            blurRadius: 10.0,
          ),],
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                if(!isEnglish){
                  changeLanguageSelector();
                  //application.onLocaleChanged(Locale('en'));
                }

              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 18,
                      width: 18,
                      child: Image.asset('assets/flag_en.png'),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).trans("english"),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontFamily: 'medium'),
                      ),
                    ),
                    Container(
                      height: 19,
                      width: 19,
                      child: isEnglish
                          ? Image.asset(
                        'assets/language_check.png',
                      )
                          : Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFF666666), width: 1.0),
                            borderRadius: BorderRadius.circular(9.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              height: 0.5,
              color: Color(0xFFDDDDDD),
            ),
            InkWell(
              onTap: () {

                if(isEnglish){
                  changeLanguageSelector();
                  //application.onLocaleChanged(Locale('ar'));
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 18,
                      width: 18,
                      child: Image.asset('assets/flag_fr.png'),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).trans("french"),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      height: 19,
                      width: 19,
                      child: !isEnglish
                          ? Image.asset(
                        'assets/language_check.png',)
                          : Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFF666666), width: 1.0),
                            borderRadius: BorderRadius.circular(9.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rememberChoiceCheckbox() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 22.0,
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 18.0),
            child: InkWell(
              splashColor: Color(0xFFF2F2F2),
              highlightColor: Color(0xFFF2F2F2),
              onTap: () {
                reminderCheckListener();
              },
              child: Row(
                children: <Widget>[
                  isRemember
                      ? Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.0),
                      color: Color(0xFF999999),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  )
                      : Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Color(0xFF000000), width: 0.5),
                        borderRadius: BorderRadius.circular(2.0)),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    AppLocalizations.of(context).trans("remember_my_choice"),
                    style: TextStyle(
                        color: Color(0xFF5B5B5B),
                        fontSize: 14.0,
                        fontFamily: 'medium'),
                  )
                ],
              ),
            )),
      ],
    );
  }

  Widget buildButton() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 25.0,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.black87,
            borderRadius: BorderRadius.circular(30.0)
          ),
          height: 50.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 15.0),
          child: FlatButton(
            onPressed: () {
              onContinueClick();
            },
            child: Center(
              child: Text(
                AppLocalizations.of(context).trans('continue').toUpperCase(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
          ),
        ),
        SizedBox(
          height: 30.0,
        ),
      ],
    );
  }
  Future<void> onContinueClick() async {
    await preferences.setBool('isRemember', isRemember);
    Utilities.language = isEnglish ? 'en' : 'fr';
    if(previousLanguage != Utilities.language){
      if(isEnglish){
        application.onLocaleChanged(Locale('en'));
        String jsonContent = await rootBundle.loadString("assets/lang/en.json");
        Globals.textData = json.decode(jsonContent);
        print("ali123");
        debugPrint(Globals.textData.toString(), wrapWidth: 1024);
      }
      else{
        application.onLocaleChanged(Locale('fr'));
        String jsonContent = await rootBundle.loadString("assets/lang/fr.json");
        Globals.textData = json.decode(jsonContent);
        print("ali123");
        debugPrint(Globals.textData.toString(), wrapWidth: 1024);
      }
      if(isFromHomeSettings){
        if(!Utilities.isGuest){
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SplashScreen()),(Route<dynamic> route) => false);
        }
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SplashScreen()));
      }
    }
    else{
      if(isFromHomeSettings){
        Navigator.pop(context);
      }
      else{/**/
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Onboarding()),(Route<dynamic> route) => false);
      }
    }

  }

}

