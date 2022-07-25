import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';


class AppLocalizations{
  Locale locale;
  static Map<dynamic, dynamic> _sentences;

  AppLocalizations(Locale locale){
    this.locale = locale;
  }

  static AppLocalizations of(BuildContext context){
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale) async {
    GetStorage storage = GetStorage();
    String jsonContent = '';
    if (storage.hasData('languages_' + locale.languageCode)) {
      jsonContent = storage.read('languages_' + locale.languageCode);
    } else {
      jsonContent = await rootBundle.loadString("assets/lang/${locale.languageCode}.json");
    }
    _sentences = json.decode(jsonContent);
    AppLocalizations appTranslations = AppLocalizations(locale);

    return appTranslations;
  }
  static Future<AppLocalizations> loadFromStorage(Locale locale, Map languages) async {
    _sentences = languages;
    // print('Storage ' +_sentences.values.toString());
    AppLocalizations appTranslations = AppLocalizations(locale);
    return appTranslations;
  }

  get currentLanguage => locale.languageCode;

  String trans(String key) {
    try{
      return _sentences[key] ?? '$key not found';
    }
    catch(e){
      print(e);
      return "not Found";
    }
  }
}

class StringResources{
  Map<String, String> enResources = Map();
  Map<String, String> frResources = Map();

  StringResources(){
    enResources['en_title'] = 'English';
    enResources['fr_title'] = 'Français';

    frResources['en_title'] = 'English';
    frResources['fr_title'] = 'Français';
  }
}