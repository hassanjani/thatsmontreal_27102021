import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thats_montreal/Home/login.dart';
import 'package:thats_montreal/api_url.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/model/md_user.dart';
import 'package:thats_montreal/utilities.dart';

import 'dashboard.dart';

class RegisterUser extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  Helper helper;
  ProgressHUD progressHUD;
  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper = Helper(context, showProgressDialog, updateState);
      progressHUD = new ProgressHUD(
        backgroundColor: Colors.black12,
        color: Theme.of(context).accentColor, //Colors.white,
        containerColor: Colors.transparent, //Color(0xFF591758),
        borderRadius: 5.0,
        text:
            '', //Utilities.language == 'en' ? Utilities.pleaseWaitEn : Utilities.pleaseWaitAr,
        loading: false,
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
                  padding: EdgeInsets.all(0.0),
                  children: <Widget>[
                    helper.buildLogo(),
                    helper.buildForm(),
                    helper.buildSignUpButton(),
                    helper.builAlreadyHaveAccount(),
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

  void showProgressDialog(bool isShow) {
    if (mounted) {
      setState(() {
        if (isShow) {
          progressHUD.state.show();
        } else {
          progressHUD.state.dismiss();
        }
      });
    }
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }
}

class Helper {
  BuildContext context;
  Function updateState, showProgressDialog;
  bool isCustomerTabSelected = true, isChefTabSelected = false;

  String name = '',
      lastName = '',
      password = '',
      confirmPassword = '',
      email = '';
  SharedPreferences preferences;
  FocusNode emailNode = FocusNode();
  FocusNode phoneNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  FocusNode confirmPasswordNode = FocusNode();
  FocusNode nameNode = FocusNode();

  Helper(this.context, this.showProgressDialog, this.updateState) {
    SharedPreferences.getInstance().then((value) {
      preferences = value;
    });
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

  Widget buildLogo() {
    return Container(
      height: MediaQuery.of(context).size.width / 3,
      margin: EdgeInsets.only(
          top: 20,
          left: MediaQuery.of(context).size.width / 10,
          right: MediaQuery.of(context).size.width / 10),
      child: Image.asset('assets/LOGO.jpg'),
    );
  }

  Widget buildActionBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(color: Colors.black),
          height: 55.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 2,
              ),
              Navigator.canPop(context)
                  ? InkWell(
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
                    )
                  : Container(
                      width: 15,
                    ),
              Container(
                child: Text(
                  AppLocalizations.of(context).trans('register'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: 'bold',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildForm() {
    return Form(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 12.0,
          ),
          buildNameField(),
          buildEmailField(),
          buildPasswordField(),
          buildConfirmPasswordField(),
        ],
      ),
    );
  }

  Widget buildNameField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('name'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '*',
                style: TextStyle(
                    color: Colors.red, fontSize: 14, fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(nameNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value) {
                          FocusScope.of(context).requestFocus(emailNode);
                        },
                        focusNode: nameNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context)
                              .trans('example_name'),
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'regular',
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        maxLines: 1,
                        onChanged: (value) {
                          name = value;
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                          FilteringTextInputFormatter.allow(
                              RegExp("[a-z A-Z.]")),
                        ],
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget buildEmailField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('email'),
                style: TextStyle(
                  color: Color(0xFF3A3A3A),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '*',
                style: TextStyle(
                    color: Colors.red, fontSize: 14, fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(emailNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value) {
                          FocusScope.of(context).requestFocus(phoneNode);
                        },
                        focusNode: emailNode,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context)
                              .trans('email_example'),
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'regular',
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        inputFormatters: [
                          new FilteringTextInputFormatter.allow(
                              RegExp("[a-zA-Z0-9-_.@]")),
                        ],
                        maxLines: 1,
                        onChanged: (value) {
                          email = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget buildPasswordField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('password'),
                style: TextStyle(
                  color: Color(0xFF3A3A3A),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '*',
                style: TextStyle(
                    color: Colors.red, fontSize: 14, fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(passwordNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                //padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(confirmPasswordNode);
                        },
                        focusNode: passwordNode,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: '••••••••',
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'regular',
                            color: Color(0xFFA3A3A3),
//                            height: 3.0,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        maxLines: 1,
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget buildConfirmPasswordField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('confirm_password'),
                style: TextStyle(
                  color: Color(0xFF3A3A3A),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '*',
                style: TextStyle(
                    color: Colors.red, fontSize: 14, fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(confirmPasswordNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                //padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        focusNode: confirmPasswordNode,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: '••••••••',
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'regular',
                            color: Color(0xFFA3A3A3),
//                            height: 3.0,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        maxLines: 1,
                        onChanged: (value) {
                          confirmPassword = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget buildSignUpButton() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 2.0,
        ),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(5.0)),
          height: 50.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 15.0),
          child: FlatButton(
            onPressed: () {
              validation();
            },
            child: Text(
              AppLocalizations.of(context).trans('register'),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  Widget builAlreadyHaveAccount() {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
      },
      child: Container(
        padding: EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).trans('already_have_account'),
              style: TextStyle(
                  fontSize: 12.8,
                  color: Color(0xFF666666),
                  fontFamily: 'regular'),
            ),
            SizedBox(
              width: 3,
            ),
            Text(
              AppLocalizations.of(context).trans('login_now'),
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  void validation() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (name.trim().isEmpty) {
      showToast(AppLocalizations.of(context).trans('enter_name'));
    } else if (email.trim().isEmpty) {
      showToast(AppLocalizations.of(context).trans('enter_email'));
    } else if (!isEmail(email.trim())) {
      showToast(AppLocalizations.of(context).trans('enter_valid_email'));
    } else if (password.trim().isEmpty) {
      showToast(AppLocalizations.of(context).trans('enter_password'));
    } else if (password.trim().length < 6) {
      showToast(AppLocalizations.of(context).trans('passowrd_length_short'));
    } else if (confirmPassword.trim().isEmpty) {
      showToast(AppLocalizations.of(context).trans('enter_confirm_password'));
    } else if (confirmPassword.trim().trim() != password.trim().trim()) {
      showToast(AppLocalizations.of(context).trans('password_not_matched'));
    } else {
      apiRegister();
    }
  }

  Future apiRegister() async {
    print('here');
    showProgressDialog(true);

    Map<String, String> params = Map();
    params['name'] = name.toString();
    params['email'] = email.trim();
    params['password'] = password.trim();
    params['type'] = 'user';
    params['login_type'] = 'email';

    print('----------Params-----------');
    print(params);
    print('----------Params-----------');

    Map<String, String> header = Map();
    header['Accept'] = 'application/json';
    http
        .post(Uri.parse(ApiUrl.web_api_url + 'api/register'),
            body: params, headers: header)
        .then((response) {
      Map mapppedResponse = jsonDecode(response.body);
      print(mapppedResponse);
      if (mapppedResponse['status']) {
        print('inside Success');
        Fluttertoast.showToast(
            msg: 'Registered Successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
        loginApi();
      } else {
        showProgressDialog(false);
        Fluttertoast.showToast(
            msg: mapppedResponse['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  loginApi() {
    showProgressDialog(true);
    Map<String, String> params = Map();

    Map<String, String> header = Map();
    header['Accept'] = 'application/json';
    params['email'] = email.trim();
    params['password'] = password.trim();

    print('--------Login Params--------');
    print(params);

    http
        .post(Uri.parse(ApiUrl.web_api_url + 'api/login'),
            body: params, headers: header)
        .then((response) async {
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
          showProgressDialog(false);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
              (Route<dynamic> route) => false);
        }
      } else {
        msg = mapppedResponse['message'];
        showProgressDialog(false);
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

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
