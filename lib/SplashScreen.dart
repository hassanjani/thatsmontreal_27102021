import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thats_montreal/Home/onboarding_page.dart';
import 'package:thats_montreal/globals.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/model/md_user.dart';

import './api_url.dart';
import './get_started.dart';
import './utilities.dart';
import 'Home/dashboard.dart';
import 'helper/language.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Helper helper;
  final storage = GetStorage();
  bool isConnected = false;
  bool languageLoading = true;

  Future getLanguageData() async {
    await storeLanguage('en');
    await storeLanguage('fr');
  }

  Future<void> storeLanguage(String lang) async{
      http.Response rsp = await http.get(Uri.parse('https://apis.thatsmontreal.com/api/translations/' + lang));
      if (rsp.statusCode == 200) {
        storage.write('languages', true);
        storage.write('languages_$lang', rsp.body.toString());
      }
  }

  setLanguageData() async {
    await _checkInternetConnection();
    String language = Utilities.language ?? 'en';
    bool hasData = storage.hasData('languages');
    if(hasData){
      if(isConnected) {
        getLanguageData().then((_){
          AppLocalizations.load(Locale(language));
        });
      }
      AppLocalizations.load(Locale(language));
        setState(() {
          languageLoading = false;
        });
    }
    else {
      if(isConnected){
        await getLanguageData();
      }
      AppLocalizations.load(Locale(language));
      setState(() {
        languageLoading = false;
      });
    }
  }



  Future<void> _checkInternetConnection() async {
    try {
      final response = await InternetAddress.lookup('google.com');
      if (response.isNotEmpty) {
        return isConnected = true;
      }
    } on SocketException catch (_) {
      print(_);
     return isConnected = false;
    }
  }


  @override
  void initState() {
    setLanguageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    if (helper == null) {
      helper = Helper(context, updateState, languageLoading);
//    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: helper.buildBody(),
    );
  }

  void updateState(){
    setState(() {

    });
  }
}

class Helper{

  Language language;
  SharedPreferences preferences;
  BuildContext context;
  Function updateState;
  bool languageLoading = true;
  Helper(this.context, this.updateState, this.languageLoading){
    if(!languageLoading){
      language = Language(false);
      SharedPreferences.getInstance().then((value) {
        preferences = value;
        checkLoginOrRedirect();
      });
    }
  }


  Widget buildBody(){
    return Stack(
      children: <Widget>[
        Center(child: Image(image: AssetImage('assets/splash.jpg'))),
        Positioned(
          bottom: 50,
          left: MediaQuery.of(context).size.width*0.4,
          right: MediaQuery.of(context).size.width*0.4,
          child: Center(
            child: SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }


  checkLoginOrRedirect()async{
    if (preferences.getBool('isLogin') ?? false) {
      print('here Login');
      loginApi(preferences.getString('email'),
          preferences.getString('password'));
    } else if (preferences.getBool('isSocialLogin') ?? false) {
      print('here Socail Login');
      handleSocialLogin(
          preferences.getString('loginId'),
          preferences.getString('name'),
          preferences.getString('email')
      );
    }
    else {
      if(preferences.getBool('isRemember').toString() == 'true'){
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Onboarding()));
      }
      else{
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => language));
      }
    }

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
  loginApi(String email, String password){
    Map<String, String> params = Map();

    Map<String, String> header = Map();
    header['Accept'] = 'application/json';
    params['email'] = email.trim();
    params['password'] = password.trim();

    print('--------Login Params--------');
    print(params);

    http.post(Uri.parse(ApiUrl.web_api_url+'api/login'), body: params,headers: header).then((response) async {
      Map mapppedResponse = jsonDecode(response.body);
      print('-----------------MappedResponse----------------');
      print(mapppedResponse);
      print('-----------------MappedResponse----------------');
      String msg;
      if (mapppedResponse['status']) {
        msg = mapppedResponse['message'];
        Utilities.user = MDUser.fromJson(mapppedResponse);
        if (Utilities.user.status) {
          await preferences.setBool('isLogin', true);
          await preferences.setString('email', email.trim());
          await preferences.setString("password", password.trim());
          Utilities.isGuest = false;
          await getLanguage();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
                  (Route<dynamic> route) => false);
        }
      } else {
        msg = mapppedResponse['message'];
//        Navigator.pushAndRemoveUntil(
//            context,
//            MaterialPageRoute(builder: (context) => HomeScreen()),
//                (Route<dynamic> route) => false);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => language));
      }
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


  handleSocialLogin(dynamic loginId, String name, String socialEmail){
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';

    print('--------Login Params--------');
    print(ApiUrl.web_api_url+"api/login-with-facebook/$name/$socialEmail/$loginId");

    http.get(Uri.parse(ApiUrl.web_api_url+"api/login-with-facebook/$name/$socialEmail/$loginId"), headers: header).then((response) async {
      Map mapppedResponse = jsonDecode(response.body);
      print('--------------------Social Login Response------------------');
      print(mapppedResponse);
      print('--------------------Social Login Response------------------');
      String msg;
      if (mapppedResponse['status']) {
        msg = mapppedResponse['message'];
        Utilities.user = MDUser.fromJson(mapppedResponse);
        if (Utilities.user.status) {
          await preferences.setBool('isSocialLogin', true);
          await preferences.setString('email', socialEmail);
          await preferences.setString("loginId", loginId.trim());
          await preferences.setString("name", name.trim());
          Utilities.isGuest = false;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
                  (Route<dynamic> route) => false);
        }
      } else {
        msg = mapppedResponse['message'];
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => language));
//        Navigator.pushAndRemoveUntil(
//            context,
//            MaterialPageRoute(builder: (context) => HomeScreen()),
//                (Route<dynamic> route) => false);
      }
      Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }


}

