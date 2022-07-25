import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:thats_montreal/Email.dart';
import 'package:thats_montreal/HomeScreen.dart';
import 'package:thats_montreal/SignIn.dart';
import 'package:thats_montreal/SignUp.dart';
import 'package:thats_montreal/SpecialPromotion.dart';
import 'package:thats_montreal/SplashScreen.dart';
import 'package:thats_montreal/Stations.dart';
import 'package:thats_montreal/WhoWeAre.dart';
import 'package:thats_montreal/demoStation.dart';
import 'package:thats_montreal/profile.dart';
import 'package:thats_montreal/utilities.dart';
import 'package:get_storage/get_storage.dart';
import 'ImagePickedDemo.dart';
import 'News.dart';
import 'SignIn.dart';
import 'package:thats_montreal/app_config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'helper/application.dart';
import 'helper/localizations_delegate.dart';

import 'package:thats_montreal/providers/checked_icons_provider.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

SharedPreferences preferences;

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
void main() async {
  await GetStorage.init();
 WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    SharedPreferences.getInstance().then((sharedPreferencesInstance){
      preferences = sharedPreferencesInstance;
      runApp(MyApp());
    });
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  AppLocalizationsDelegate _appLocalizationsDelegate;
  SplashScreen splash;
  Locale appLocale;

  @override
  Widget build(BuildContext context) {
    if(splash == null){
      Utilities.language = preferences.getString('language') ?? 'en';
      appLocale = Locale(Utilities.language);
      setLanguage();
      splash = SplashScreen();
      _appLocalizationsDelegate = AppLocalizationsDelegate(newLocale: null);
      application.onLocaleChanged = onLocaleChange;
    }
    return ChangeNotifierProvider<CheckedIconsProvider>(
      create: (_) => CheckedIconsProvider(),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'That\'s Montreal',
        supportedLocales: application.supportedLocales(),
        locale:appLocale,
        localizationsDelegates: [
          _appLocalizationsDelegate,
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: splash,
        routes: {
          '/homescreen' : (context) => HomeScreen(),
          '/register'   : (context) => SignUp(),
          '/profile'   : (context) => ProfilePage(),
          '/Email'   : (context) => EmailScreen(),
          '/News'  : (context) => NewsScreen(),
          '/WhoWeAre' : (context) => WhoWeAre(),
          '/SpecialPormotion' : (context) => SpecialPormotion(),
        },
      ),
    );
  }

  Future setLanguage() async {
    preferences = await SharedPreferences.getInstance();
    Utilities.language = preferences.getString('language') ?? 'en';
    appLocale = Locale(Utilities.language);
    onLocaleChange(appLocale);
  }


  Future onLocaleChange(Locale locale) async{
    print('---------LANGUAGE CODE-------------');
    print(locale.languageCode);
    setState(() {
      Utilities.language = locale.languageCode;
      appLocale = locale;
      _appLocalizationsDelegate = AppLocalizationsDelegate(newLocale: locale);
    });
//    ApiUrl.web_url = ApiUrl.base_url + Utilities.language + '/api/';
    await preferences.setString('language', locale.languageCode);

  }
}

