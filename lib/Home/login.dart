import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thats_montreal/Home/dashboard.dart';
import 'package:thats_montreal/api_url.dart';
import 'package:thats_montreal/globals.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/model/md_user.dart';
import 'package:thats_montreal/utilities.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Helper helper;
  ProgressHUD progressHUD;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper = Helper(context, showProgressDialog, updateState);
      progressHUD = new ProgressHUD(
        backgroundColor: Colors.black12,
        color: Theme.of(context).accentColor, //Colors.white,
        containerColor: Colors.transparent, //Color(0xFF591758),
        borderRadius: 5.0,
        text: '',
        loading: false,
      );
    }
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                //  helper.buildStatusBar(),
                // helper.buildActionBar(),
                helper.buildLogo(),
                Expanded(
                    child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(50.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(3.0, 0), // changes position of shadow
                        )
                      ]),
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   crossAxisAlignment: CrossAxisAlignment.end,
                      //   children: [
                      //     InkWell(
                      //       onTap: (){
                      //         Navigator.push(context, MaterialPageRoute(builder: (context)=> Language(true)));
                      //       },
                      //       child: Text(
                      //         Utilities.language =='en'? "EN" : "FR",
                      //         style: TextStyle(
                      //             color: Color(0xFF151515),
                      //             fontSize: 15.0,
                      //             fontWeight: FontWeight.w400
                      //         ),
                      //       ),
                      //     ),
                      //     Icon(
                      //       Icons.keyboard_arrow_down,
                      //       size: 20,
                      //       color: Color(0xFFA4A0A0),
                      //     ),
                      //     SizedBox(
                      //       width: 20.0,
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: 25.0,
                      ),
                      helper.buildLoginSignupButtons(),
                      helper.isLoginSelected
                          ? helper.buildLoginForm()
                          : helper.buildForm(),
                      helper.isLoginSelected
                          ? helper.buildLoginButton()
                          : helper.buildSignUpButton(),
                      helper.isLoginSelected
                          ? SizedBox(
                              height: 15.0,
                            )
                          : Container(),
                      helper.isLoginSelected
                          ? helper.forgetPassword()
                          : Container(),
                      helper.buildOrSeperator(),
                      helper.buildGuestModeButton(),
                      // helper.buildContinueWithHeading(),
                      // helper.buildFacebookGoogleButton(),
                      SizedBox(
                        height: 20.0,
                      )
                    ],
                  ),
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

  void updateState() {
    setState(() {});
  }
}

class Helper {
  BuildContext context;
  Function showProgressDialog;
  Function updateState;
  SharedPreferences preferences;
  String email = '', password = '';
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static final Key emailKey = new GlobalKey(debugLabel: 'emailKey');
  static final Key passwordKey = new GlobalKey(debugLabel: 'passwordKey');
  FocusNode emailNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  bool isLoginSelected = true, isSignupSelected = false;
  bool isShowPassowrd = true;
  bool isShowPassowrdRegister = true;
  FocusNode confirmPasswordNode = FocusNode();
  FocusNode nameNode = FocusNode();
  FocusNode emailRegisterNode = FocusNode();
  FocusNode passwordRegisterNode = FocusNode();

  String name = '',
      lastName = '',
      passwordRegister = '',
      confirmPassword = '',
      emailRegister = '';

  Helper(this.context, this.showProgressDialog, this.updateState) {
    SharedPreferences.getInstance().then((value) {
      preferences = value;
    });
  }

  ProgressHUD progressHUD;

  GoogleSignIn googleSignIn = new GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

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
//            color: Colors.black
              ),
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
                          color: Colors.black,
                        ),
                      ),
                    )
                  : Container(
                      width: 15,
                    ),
              Container(
                child: Text(
                  AppLocalizations.of(context).trans('login'),
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

  Widget buildLogo() {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.width / 3,
        margin: EdgeInsets.only(
            top: 20,
            left: MediaQuery.of(context).size.width / 10,
            right: MediaQuery.of(context).size.width / 10,
            bottom: 20),
        child: Image.asset('assets/LOGO.jpg'),
      ),
    );
  }

  Widget buildLoginSignupButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (!isLoginSelected) {
                  isLoginSelected = true;
                  isSignupSelected = false;
                  updateState();
                }
              },
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context).trans('login'),
                    style: TextStyle(
                      color: isLoginSelected
                          ? Color(0xFF151515)
                          : Color(0xFFC2C2C2),
                      fontSize: 20.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: isLoginSelected
                          ? Color(0xFFF4D500)
                          : Color(0xFFA4A0A0),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                if (!isSignupSelected) {
                  isLoginSelected = false;
                  isSignupSelected = true;
                  updateState();
                }
              },
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context).trans('register'),
                    style: TextStyle(
                      color: isSignupSelected
                          ? Color(0xFF151515)
                          : Color(0xFFC2C2C2), //C2C2C2,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    height: 10.0,
                    decoration: BoxDecoration(
                      color: isSignupSelected
                          ? Color(0xFFF4D500)
                          : Color(0xFFA4A0A0),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildLoginForm() {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          buildEmailField(),
          buildPasswordField(),
          SizedBox(
            height: 5.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                isShowPassowrd = !isShowPassowrd;
                updateState();
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    height: 18,
                    width: 18,
                    child: !isShowPassowrd
                        ? Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.redAccent, width: 1.2),
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.redAccent),
                            child: Icon(
                              Icons.check,
                              size: 15,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFF888888), width: 1.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    AppLocalizations.of(context).trans('show_password'),
                    style: TextStyle(
                        color: Color(0xFF868686),
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
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
            height: 30,
          ),
//          Row(
//            children: <Widget>[
//              Text(
//                AppLocalizations.of(context).trans('email'),
//                style: TextStyle(
//                  color: Color(0xFF000000),
//                  fontSize: 15,
//                  fontFamily: 'medium',
//                ),
//              ),
//              Text(
//                '*',
//                style: TextStyle(
//                    color: Colors.red, fontSize: 15, fontFamily: 'regular'),
//              ),
//            ],
//          ),
//          SizedBox(
//            height: 7.0,
//          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(emailNode);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Color(0xFF787777), width: 1.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      'assets/user_icon.png',
                      width: 30.0,
                    ),
                  ),
                  SizedBox(
                    width: 7.0,
                  ),
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      focusNode: emailNode,
                      key: emailKey,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        hintText:
                            AppLocalizations.of(context).trans('enter_email'),
                        hintStyle: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'regular',
                          color: Color(0xFFA3A3A3),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'regular',
                        color: Color(0xFF666666),
                      ),
                      maxLines: 1,
                      onChanged: (value) {
                        email = value;
                      },
                      inputFormatters: [
                        new FilteringTextInputFormatter.allow(
                            RegExp("[a-zA-Z0-9-_.@]")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
            height: 20,
          ),
//          Row(
//            children: <Widget>[
//              Text(
//                AppLocalizations.of(context).trans('password'),
//                style: TextStyle(
//                  color: Color(0xFF000000),
//                  fontSize: 15,
//                  fontFamily: 'medium',
//                ),
//              ),
//              Text(
//                '*',
//                style: TextStyle(
//                    color: Colors.red, fontSize: 15, fontFamily: 'regular'),
//              ),
//            ],
//          ),
//          SizedBox(
//            height: 7.0,
//          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(passwordNode);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Color(0xFF787777), width: 1.0),
              ),
              //padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 10.0,
                  ),
                  Container(
                    child: Image.asset(
                      'assets/pass_icon.png',
                      width: 30.0,
                    ),
                  ),
                  SizedBox(
                    width: 7.0,
                  ),
                  Expanded(
                    child: TextField(
                      //controller: controller,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      focusNode: passwordNode,
                      key: passwordKey,
                      keyboardType: TextInputType.text,
                      obscureText: isShowPassowrd,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        hintText:
                            AppLocalizations.of(context).trans('password'),
                        hintStyle: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'regular',
                          color: Color(0xFFA3A3A3),
//                          height: 3.0
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
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildLoginButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 23.0,
        ),
        Container(
          decoration: BoxDecoration(
              color: Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(30.0)),
          height: 60.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 15.0),
          child: FlatButton(
            onPressed: () {
              validation();
            },
            child: Text(
              AppLocalizations.of(context).trans('login').toUpperCase(),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w900),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
      ],
    );
  }

  Widget forgetPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Globals.textData["forget_password?"].toString() + " ",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black26, fontSize: 14.0),
        ),
        Text(
          Globals.textData["click_here!"].toString(),
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xffF94E0D), fontSize: 14.0),
        ),
      ],
    );
  }

  void validation() {
    if (email.isEmpty) {
      showToast(AppLocalizations.of(context).trans('enter_email'));
    } else if (!isEmail(email.trim())) {
      showToast(AppLocalizations.of(context).trans('enter_valid_email'));
    } else if (password.isEmpty) {
      showToast(AppLocalizations.of(context).trans('enter_password'));
    } else if (password.length < 6) {
      showToast(AppLocalizations.of(context).trans('passowrd_length_short'));
    } else {
      loginApi();
    }
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  Widget buildLoginRegisterButton() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 30.0,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFEB1E1D),
                      borderRadius: BorderRadius.circular(5.0)),
                  height: 47.0,
                  width: MediaQuery.of(context).size.width,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Text(
                      AppLocalizations.of(context).trans('login'),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontFamily: 'bold'),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
              ),
              SizedBox(
                width: 16.0,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFEB1E1D),
                      borderRadius: BorderRadius.circular(5.0)),
                  height: 47.0,
                  width: MediaQuery.of(context).size.width,
                  child: FlatButton(
                    onPressed: () {
//                      Navigator.push(context,
//                          MaterialPageRoute(builder: (context) => Register()));
                    },
                    child: Text(
                      AppLocalizations.of(context).trans('register'),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontFamily: 'bold'),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildOrSeperator() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 25.0,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 15.0,
            ),
            Expanded(
              child: Container(
                height: 0.8,
                color: Color(0xFFDDDDDD),
              ),
            ),
            SizedBox(
              width: 8.0,
            ),
            Text(
              AppLocalizations.of(context).trans('or'),
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 16.0,
                fontFamily: 'semi-bold',
              ),
            ),
            SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Container(
                height: 0.8,
                color: Color(0xFFDDDDDD),
              ),
            ),
            SizedBox(
              width: 15.0,
            ),
          ],
        ),
        SizedBox(
          height: 25.0,
        ),
      ],
    );
  }

  Widget buildGuestModeButton() {
    return Column(
      children: <Widget>[
        Container(
            height: 60,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                border: Border.all(color: Colors.black)),
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 15.0),
            child: FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: () {
                Utilities.isGuest = true;
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Dashboard()));
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).trans('login_as_guest'),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'bold',
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
        SizedBox(
          height: 15.0,
        ),
      ],
    );
  }

  Widget buildContinueWithHeading() {
    return Column(
      children: [
        SizedBox(
          height: 5.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 15.0),
          child: Center(
            child: Text(
              AppLocalizations.of(context).trans('continue_with'),
              style: TextStyle(
                color: Color(0xFF151515),
                fontSize: 17.0,
                fontWeight: FontWeight.w400,
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

  Widget buildFacebookGoogleButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildGoogleButton(),
        buildFacebookButton(),
      ],
    );
  }

  Widget buildFacebookButton() {
    return Container(
        height: 40,
        decoration: BoxDecoration(
//                color: Color(0xFF39568E),
          borderRadius: BorderRadius.circular(5.0),
        ),
//            width: MediaQuery.of(context).size.width,
        child: FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: () {
            handleFacebookSignIn();
          },
          child: Container(
            width: 40.0,
            child: Image.asset(
              'assets/facebook_icon.png',
            ),
          ),
        ));
  }

  Widget buildGoogleButton() {
    return Container(
        height: 40,
        decoration: BoxDecoration(
//                color: Color(0xFF4688F2),
            borderRadius: BorderRadius.circular(5.0)),
//            width: MediaQuery.of(context).size.width,
        child: InkWell(
          onTap: () {
            handleGoogleSignIn();
          },
          child: Container(
            width: 40.0,
            child: Image.asset(
              'assets/google_icon_new.png',
            ),
          ),
        ));
  }

  //Signup Form Data

  Widget buildForm() {
    return Form(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          buildNameField(),
          buildEmailFieldRegister(),
          buildPasswordFieldRegister(),
          buildConfirmPasswordField(),
          SizedBox(
            height: 5.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0),
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                isShowPassowrdRegister = !isShowPassowrdRegister;
                updateState();
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    height: 18,
                    width: 18,
                    child: !isShowPassowrdRegister
                        ? Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.redAccent, width: 1.2),
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.redAccent),
                            child: Icon(
                              Icons.check,
                              size: 15,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xFF888888), width: 1.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    AppLocalizations.of(context).trans('show_password'),
                    style: TextStyle(
                        color: Color(0xFF868686),
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
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
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(nameNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color(0xFF787777), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Image.asset(
                        'assets/user_icon.png',
                        width: 30.0,
                      ),
                    ),
                    SizedBox(
                      width: 7.0,
                    ),
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(emailRegisterNode);
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

  Widget buildEmailFieldRegister() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(emailRegisterNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color(0xFF787777), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Image.asset(
                        'assets/email_icon_register.png',
                        width: 30.0,
                      ),
                    ),
                    SizedBox(
                      width: 7.0,
                    ),
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(passwordRegisterNode);
                        },
                        focusNode: emailRegisterNode,
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
                          emailRegister = value;
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

  Widget buildPasswordFieldRegister() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(passwordRegisterNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color(0xFF787777), width: 1.0),
                ),
                //padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Image.asset(
                        'assets/pass_icon.png',
                        width: 30.0,
                      ),
                    ),
                    SizedBox(
                      width: 7.0,
                    ),
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          FocusScope.of(context)
                              .requestFocus(confirmPasswordNode);
                        },
                        focusNode: passwordRegisterNode,
                        keyboardType: TextInputType.text,
                        obscureText: isShowPassowrdRegister,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText:
                              AppLocalizations.of(context).trans('password'),
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
                          passwordRegister = value;
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
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(confirmPasswordNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color(0xFF787777), width: 1.0),
                ),
                //padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Image.asset(
                        'assets/pass_icon.png',
                        width: 30.0,
                      ),
                    ),
                    SizedBox(
                      width: 7.0,
                    ),
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        focusNode: confirmPasswordNode,
                        keyboardType: TextInputType.text,
                        obscureText: isShowPassowrdRegister,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context)
                              .trans('confirm_password'),
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
          height: 23.0,
        ),
        Container(
          decoration: BoxDecoration(
              color: Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(30.0)),
          height: 60.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 15.0),
          child: FlatButton(
            onPressed: () {
              validationRegister();
            },
            child: Text(
              AppLocalizations.of(context).trans('register'),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w900),
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

  //Signup form data ended

  Future handleGoogleSignIn() async {
    await googleSignIn.signOut();
    try {
      //await _googleSignIn.signIn();
      await googleSignIn.signIn().then((result) {
        result.authentication.then((googleKey) {
          print(googleKey.accessToken);
          print('IDTOKEN: ' + googleKey.idToken.toString());
          print(googleSignIn.currentUser.displayName);
          print(googleSignIn.currentUser.email);
          String name = googleSignIn.currentUser.displayName == null
              ? ''
              : googleSignIn.currentUser.displayName;
          handleSocialLogin('google', googleSignIn.currentUser.id, name,
              googleSignIn.currentUser.email);
        }).catchError((err) {
          print('inner error');
        });
      }).catchError((err) {
        print(err.toString());
        print('error occured');
        print(err);
      });
    } catch (error) {
      print(error);
    }
  }

  void handleFacebookSignIn() async {
    var facebookLogin = FacebookLogin();
    await facebookLogin.logOut();
    var facebookLoginResult = await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        print(facebookLoginResult.errorMessage);
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        showProgressDialog(true);
        http
            .get(Uri.parse(
                'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${facebookLoginResult.accessToken.token}'))
            .then((graphResponse) {
          //showDialog(false);
          var profile = json.decode(graphResponse.body);
          print(profile.toString());
          handleSocialLogin(
              'facebook', profile['id'], profile['name'], profile['email']);
//          apiSocialLogin(profile['id'],
//              'facebook', profile['name'], profile['email'], AppLocalizations.of(context).trans('signup_with_facebook'));
        });
        break;
    }
  }

  Future apiSocialLogin(String socialId, String authMethod, String name,
      String email, String actionbarText) async {
    showProgressDialog(true);
    Map<String, String> params = Map();
//    params['authMethod'] = authMethod;
    if (authMethod == 'google') {
      params['google_id'] = socialId;
    } else if (authMethod == 'facebook') {
      params['facebook_id'] = socialId;
    } else {
      params['instagram_id'] = socialId;
    }

//    params['accessToken'] = accessToken;
//    params['fcm_token'] = await firebaseMessaging.getToken();

    Map<String, String> header = Map();
    header['Accept'] = 'application/json';
    print('--------Social Login Params--------');
    print(params);

    http
        .post(Uri.parse('ApiUrl.web_url'), body: params, headers: header)
        .then((response) async {
      Map mapppedResponse = jsonDecode(response.body);
      showProgressDialog(false);
      print(mapppedResponse);

      if (mapppedResponse['success']) {
//        Utilities.user = MDUser.fromJson(mapppedResponse['data']['collection']);
//        if (Utilities.user.is_verified /*|| !Utilities.user.isEmailVerified*/) {
//          Utilities.isGuest = false;
//          Utilities.connectPusher();
//          await preferences.setBool('isSocialLogin', true);
//          await preferences.setString('socialId', socialId);
//          await preferences.setString('authMethod', authMethod);
//          showProgressDialog(false);
//          Utilities.isGuest = false;
//          Navigator.pushAndRemoveUntil(
//              context,
//              MaterialPageRoute(builder: (context) => BottomNavigationHost()),
//                  (Route<dynamic> route) => false);
//        } else {
//          showProgressDialog(false);
////          Navigator.push(
////              context,
////              MaterialPageRoute(
////                  builder: (context) =>
////                      EmailVerification('', '', socialId, authMethod)));
//        }
      }
    }).catchError((e) {
      print(e.toString());
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

  handleSocialLogin(
      String loginFrom, dynamic loginId, String name, String socialEmail) {
    showProgressDialog(true);
    Map<String, String> params = Map();

    Map<String, String> header = Map();
    header['Accept'] = 'application/json';

    print('--------Login Params--------');
    print(ApiUrl.web_api_url +
        "api/login-with-facebook/$name/$socialEmail/$loginId");

    http
        .get(
            Uri.parse(ApiUrl.web_api_url +
                "api/login-with-facebook/$name/$socialEmail/$loginId"),
            headers: header)
        .then((response) async {
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
          showProgressDialog(false);
          Utilities.isGuest = false;
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
          Utilities.isGuest = false;
          await getLanguage();
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

  getLanguage() async {
    print("geting language");
    if (Utilities.language == "en") {
      String jsonContent = await rootBundle.loadString("assets/lang/en.json");
      Globals.textData = json.decode(jsonContent);
    } else {
      String jsonContent = await rootBundle.loadString("assets/lang/fr.json");
      Globals.textData = json.decode(jsonContent);
    }
  }

  //Register APi Calls

  void validationRegister() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (name.trim().isEmpty) {
      showToast(AppLocalizations.of(context).trans('enter_name'));
    } else if (emailRegister.trim().isEmpty) {
      showToast(AppLocalizations.of(context).trans('enter_email'));
    } else if (!isEmail(emailRegister.trim())) {
      showToast(AppLocalizations.of(context).trans('enter_valid_email'));
    } else if (passwordRegister.trim().isEmpty) {
      showToast(AppLocalizations.of(context).trans('enter_password'));
    } else if (passwordRegister.trim().length < 6) {
      showToast(AppLocalizations.of(context).trans('passowrd_length_short'));
    } else if (confirmPassword.trim().isEmpty) {
      showToast(AppLocalizations.of(context).trans('enter_confirm_password'));
    } else if (confirmPassword.trim().trim() !=
        passwordRegister.trim().trim()) {
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
    params['email'] = emailRegister.trim();
    params['password'] = passwordRegister.trim();
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
        loginRegisterApi();
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

  loginRegisterApi() {
    showProgressDialog(true);
    Map<String, String> params = Map();

    Map<String, String> header = Map();
    header['Accept'] = 'application/json';
    params['email'] = emailRegister.trim();
    params['password'] = passwordRegister.trim();

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

//Ended

}
