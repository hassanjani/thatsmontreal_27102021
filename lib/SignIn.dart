import 'package:flutter/material.dart';
import 'package:thats_montreal/Animation/FadeAnimation.dart';
import 'package:thats_montreal/SignUp.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_url.dart';
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  TextEditingController edtEmailController = new TextEditingController();
  TextEditingController edtPasswordController = new TextEditingController();

  final RoundedLoadingButtonController _btnController =
  new RoundedLoadingButtonController();

  bool _validateEmail = false;
  bool _validatePassword = false;

  Future<void> _handleSignIn() async {
    print("objectin");
    try {
      await _googleSignIn.signIn();
      print("responce"+_googleSignIn.currentUser.id);

      SignUpWithApi(_googleSignIn.currentUser.displayName, _googleSignIn.currentUser.email, "Google", "Google");
      print("objecttry");

    } catch (error) {
      print("errrorr"+error);
    }
  }

  SignUpWithApi(
      String name, String email, String password, String loginType) async {
    Map data = {
      'name': name,
      'email': email,
      'password': password,
      'login_type': loginType
    };
    var jsonData = null;
    print(name+email+password+loginType);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var responce = await http.post(
        Uri.parse(ApiUrl.web_api_url+"api/register"),
        body: data);
    print(responce.body);
    if (responce.statusCode == 200) {
      print("jsonData['user_id']");
      jsonData = json.decode(responce.body);
      print(responce.body);
      print(jsonData['user_id']);
      if (jsonData['user_id'] != null) {
        _btnController.success();
        sharedPreferences.setInt("user_id",jsonData['user_id'] );
        print(jsonData['user_id']);
        sharedPreferences.setBool("isLoggedIn", true);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        _btnController.error();
      }
//      setState(() {
//        sharedPreferences.setString("login", "1");
//      });

    } else {
      print("sdsd"+responce.body);
    }
  }

  SignInWithApi(String email, String password) async {
    Map data = {
      'email': email,
      'password': password,
    };
    var jsonData = null;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var responce;
    try{
       responce  = await http.post(
          Uri.parse(ApiUrl.web_api_url+"api/login"),
          body: data);
    }catch(e){
      print(e);
    }

    if (responce.statusCode == 200) {
      print("jsonData['user_id']");
      jsonData = json.decode(responce.body);
      print(responce.body);
      print(jsonData['user_id']);
      if (jsonData['user_id'] != null) {
        _btnController.success();

        sharedPreferences.setInt("user_id",jsonData['user_id'] );
        print(jsonData['user_id']);

        sharedPreferences.setBool("isLoggedIn", true);

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        _btnController.error();
      }

    } else {
      print("error" + responce.body);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
//            gradient: LinearGradient(
//                begin: Alignment.topCenter,
//                colors: [Colors.white, Colors.white, Colors.white]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage('assets/LOGO.jpg'),
                  ),
                  FadeAnimation(
                      1,
                      Text(
                        "Sign in",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontFamily: 'Poppins',
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        FadeAnimation(
                            1.4,
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.15),
                                        spreadRadius: 10,
                                        blurRadius: 10,
                                        offset: Offset(0, 10))
                                  ]),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[200]))),
                                    child: TextField(
                                      controller: edtEmailController,
                                      decoration: InputDecoration(
                                          errorText: _validateEmail
                                              ? 'Email Can\'t Be Empty'
                                              : null,
                                          hintText: "Email ",
                                          hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'Poppins'),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[200]))),
                                    child: TextField(
                                      controller: edtPasswordController,
                                      decoration: InputDecoration(
                                          errorText: _validatePassword
                                              ? 'Password Can\'t Be Empty'
                                              : null,
                                          hintText: "Password",
                                          hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'Poppins'),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        SizedBox(
                          height: 40,
                        ),
                        RoundedLoadingButton(
                          controller: _btnController,
                          color: Colors.amber,
                          onPressed: () {
                            setState(() {

                              edtEmailController.text.isEmpty
                                  ? _validateEmail = true
                                  : _validateEmail = false;
                              edtPasswordController.text.isEmpty
                                  ? _validatePassword = true
                                  : _validatePassword = false;

                              if (_validateEmail == false &&
                                  _validatePassword == false) {
                                print(edtEmailController.text +
                                    edtPasswordController.text);
                                SignInWithApi(
                                    edtEmailController.text,
                                    edtPasswordController.text);
                              } else {
                                _btnController.reset();
                              }
                            });
                          },
                          child: FadeAnimation(
                              1.6,
                              Center(
                                child: Text(
                                  "Sign in",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FadeAnimation(
                            1.7,
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUp()));
                                },
                                child: Text(
                                  "Sign up ?",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ))),
                        SizedBox(
                          height: 20,
                        ),
                        FadeAnimation(
                            1.7,
                            Text(
                              "Continue with social media",
                              style: TextStyle(color: Colors.grey),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: <Widget>[
//                            Expanded(
//                              child: FadeAnimation(
//                                  1.8,
//                                  Container(
//                                    height: 50,
//                                    decoration: BoxDecoration(
//                                        borderRadius: BorderRadius.circular(50),
//                                        color: Colors.white),
//                                    child: Center(
//                                      child: Padding(
//                                        padding: const EdgeInsets.symmetric(
//                                            vertical: 8.0),
//                                        child: Image(
//                                          image:
//                                              AssetImage('assets/facebook.png'),
//                                        ),
//                                      ),
//                                    ),
//                                  )),
//                            ),
//                            SizedBox(
//                              width: 30,
//                            ),
                            Expanded(
                              child: FadeAnimation(
                                  1.9,
                                  GestureDetector(
                                    onTap: (){
                                      _handleSignIn();
                                    },
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: Colors.white),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Image(
                                            image:
                                                AssetImage('assets/google.png'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
