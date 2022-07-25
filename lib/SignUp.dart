import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thats_montreal/Animation/FadeAnimation.dart';
import 'package:thats_montreal/HomeScreen.dart';
import 'package:thats_montreal/SignIn.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'dart:convert' show json;
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'dart:io';

import 'GoogleSignInDemo.dart';
import 'api_url.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

//  static final FacebookLogin facebookSignIn = new FacebookLogin();
//
//  Future<Null> _login() async {
//    final FacebookLoginResult result =
//    await facebookSignIn.logIn(['email']);
//
//    switch (result.status) {
//      case FacebookLoginStatus.loggedIn:
//        final FacebookAccessToken accessToken = result.accessToken;
//        print('''
//         Logged in!
//
//         Token: ${accessToken.token}
//         User id: ${accessToken.userId}
//         Expires: ${accessToken.expires}
//         Permissions: ${accessToken.permissions}
//         Declined permissions: ${accessToken.declinedPermissions}
//         ''');
//        break;
//      case FacebookLoginStatus.cancelledByUser:
//        print('Login cancelled by the user.');
//        break;
//      case FacebookLoginStatus.error:
//        print('Something went wrong with the login process.\n'
//            'Here\'s the error Facebook gave us: ${result.errorMessage}');
//        break;
//    }
//  }

  GoogleSignInAccount _currentUser;
  String _contactText;

  @override
  void initState() {
    super.initState();
//    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
//      setState(() {
//        _currentUser = account;
//        print(_currentUser.displayName);
//      });
//      if (_currentUser != null) {
//
////        _handleGetContact();
//      }
//    });
//    _googleSignIn.signInSilently();
  }

  Future<void> _handleGetContact() async {
    setState(() {
      _contactText = "Loading contact info...";
    });
    final http.Response response = await http.get(
        Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await _currentUser.authHeaders,

    );
    print("kjkjk"+_currentUser.displayName);
    if (response.statusCode != 200) {
      setState(() {
        _contactText = "People API gave a ${response.statusCode} "
            "response. Check logs for details.";
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data = json.decode(response.body);
    final String namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = "I see you know $namedContact!";
      } else {
        _contactText = "No contacts to display.";
      }
    });
  }

  String _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic> connections = data['connections'];
    final Map<String, dynamic> contact = connections?.firstWhere(
          (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    );
    if (contact != null) {
      final Map<String, dynamic> name = contact['names'].firstWhere(
            (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    print("objectin");
    try {
      await _googleSignIn.signIn();
      print("responce"+_googleSignIn.currentUser.displayName);

      SignUpWithApi(_googleSignIn.currentUser.displayName, _googleSignIn.currentUser.email, "Google", "Google");
      print("objecttry");

    } catch (error) {
      print("errrorr"+error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();
  TextEditingController edtNameController = new TextEditingController();
  TextEditingController edtEmailController = new TextEditingController();
  TextEditingController edtPasswordController = new TextEditingController();

  final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();

  bool _validateName = false;
  bool _validateEmail = false;
  bool _validatePassword = false;
  Future<File> imageFile1;
  Future<File> imageFile2;
  Future<File> imageFile3;
  Future<File> imageFile4;
  final _picker = ImagePicker();

  pickImageFromGallery(ImageSource source,int check) {
    if(check==1){
      setState(() async {
        final pickedFile=await _picker.getImage(source: source, imageQuality: 50);
        imageFile1 =pickedFile.path as Future<File>;
      });
    }
    if(check==2){
      setState(() async {
        final pickedFile=await _picker.getImage(source: source, imageQuality: 50);
        imageFile2 =pickedFile.path as Future<File>;
//        imageFile2 = ImagePicker.pickImage(source: source);
      });
    }
    if(check==3){
      setState(() async {
        final pickedFile=await _picker.getImage(source: source, imageQuality: 50);
        imageFile3 =pickedFile.path as Future<File>;
//        imageFile3 = ImagePicker.pickImage(source: source);
      });
    }
    if(check==4){
      setState(() async {
        final pickedFile=await _picker.getImage(source: source, imageQuality: 50);
        imageFile4 =pickedFile.path as Future<File>;
//        imageFile4 = ImagePicker.pickImage(source: source);
      });
    }

  }

  Widget showImage(int check) {
    if(check==1){
      return FutureBuilder<File>(
        future: imageFile1,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Container(
              margin: EdgeInsets.only(left: 15),
              height: 200,
              width: 200,
              child: Image.file(
                snapshot.data,
                fit: BoxFit.cover,
                height: 200,
                width: 200,
              ),
            );
          } else if (snapshot.error != null) {
            return const Text(
              'Error Picking Image',
              textAlign: TextAlign.center,
            );
          } else {
            return Container(
              margin: EdgeInsets.only(left: 10),
              height: MediaQuery.of(context).size.width / 2.3,
              width: MediaQuery.of(context).size.width / 2.3,
              decoration: BoxDecoration(
                  image:
                  DecorationImage(image: AssetImage('assets/download1.png'), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(25)),
            );
          }
        },
      );
    }
    if(check==2){
      return FutureBuilder<File>(
        future: imageFile2,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Container(
              margin: EdgeInsets.only(left: 15),
              height: 200,
              width: 200,
              child: Image.file(
                snapshot.data,
                fit: BoxFit.cover,
                height: 200,
                width: 200,
              ),
            );
          } else if (snapshot.error != null) {
            return const Text(
              'Error Picking Image',
              textAlign: TextAlign.center,
            );
          } else {
            return Container(
              margin: EdgeInsets.only(left: 10),
              height: MediaQuery.of(context).size.width / 2.3,
              width: MediaQuery.of(context).size.width / 2.3,
              decoration: BoxDecoration(
                  image:
                  DecorationImage(image: AssetImage('assets/download1.png'), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(25)),
            );
          }
        },
      );
    }
    if(check==3){
      return FutureBuilder<File>(
        future: imageFile3,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Container(
              margin: EdgeInsets.only(left: 15),
              height: 200,
              width: 200,
              child: Image.file(
                snapshot.data,
                fit: BoxFit.cover,
                height: 200,
                width: 200,
              ),
            );
          } else if (snapshot.error != null) {
            return const Text(
              'Error Picking Image',
              textAlign: TextAlign.center,
            );
          } else {
            return Container(
              margin: EdgeInsets.only(left: 10),
              height: MediaQuery.of(context).size.width / 2.3,
              width: MediaQuery.of(context).size.width / 2.3,
              decoration: BoxDecoration(
                  image:
                  DecorationImage(image: AssetImage('assets/download1.png'), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(25)),
            );
          }
        },
      );
    }
    if(check==4){
      return FutureBuilder<File>(
        future: imageFile4,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Container(
              margin: EdgeInsets.only(left: 15),
              height: 200,
              width: 200,
              child: Image.file(
                snapshot.data,
                fit: BoxFit.cover,
                height: 200,
                width: 200,
              ),
            );
          } else if (snapshot.error != null) {
            return const Text(
              'Error Picking Image',
              textAlign: TextAlign.center,
            );
          } else {
            return Container(
              margin: EdgeInsets.only(left: 10),
              height: MediaQuery.of(context).size.width / 2.3,
              width: MediaQuery.of(context).size.width / 2.3,
              decoration: BoxDecoration(
                  image:
                  DecorationImage(image: AssetImage('assets/download1.png'), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(25)),
            );
          }
        },
      );
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
                        "Sign up",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontFamily: 'Poppins',
                        ),
                      )),
//                  Row(
//                    children: <Widget>[
//                      RaisedButton(onPressed: (){
//                        pickImageFromGallery(ImageSource.gallery,1);
//                      }),
//                      showImage(1),
//                    ],
//                  )
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
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
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
                                      controller: edtNameController,
                                      decoration: InputDecoration(
                                          errorText: _validateName
                                              ? 'Name Can\'t Be Empty'
                                              : null,
                                          hintText: "Name",
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
                                      controller: edtEmailController,
                                      decoration: InputDecoration(
                                          errorText: _validateEmail
                                              ? 'Email Can\'t Be Empty'
                                              : null,
                                          hintText: "Email",
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
                          height: 20,
                        ),
                        RoundedLoadingButton(
                          controller: _btnController,
                          color: Colors.amber,
                          onPressed: () {
                            setState(() {
                              edtNameController.text.isEmpty
                                  ? _validateName = true
                                  : _validateName = false;
                              edtEmailController.text.isEmpty
                                  ? _validateEmail = true
                                  : _validateEmail = false;
                              edtPasswordController.text.isEmpty
                                  ? _validatePassword = true
                                  : _validatePassword = false;

                              if (_validateName == false &&
                                  _validateEmail == false &&
                                  _validatePassword == false) {
                                print(edtNameController.text +
                                    edtEmailController.text +
                                    edtPasswordController.text);
                                SignUpWithApi(
                                    edtNameController.text,
                                    edtEmailController.text,
                                    edtPasswordController.text,
                                    "normal");
                              } else {
                                _btnController.reset();
                              }
                            });
                          },
                          child: FadeAnimation(
                              1.6,
                              Center(
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                      color: Colors.white,
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
                                          builder: (context) => SignIn()));
                                },
                                child: Text(
                                  "Sign in ?",
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
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
//                            Expanded(
//                              child: FadeAnimation(
//                                  1.8,
//                                  GestureDetector(
//                                    onTap: (){
////                                      _login();
//                                    },
//                                    child: Container(
//                                      height: 50,
//                                      decoration: BoxDecoration(
//                                          borderRadius: BorderRadius.circular(50),
//                                          color: Colors.white),
//                                      child: Center(
//                                        child: Padding(
//                                          padding: const EdgeInsets.symmetric(
//                                              vertical: 8.0),
//                                          child: Image(
//                                            image:
//                                                AssetImage('assets/facebook.png'),
//                                          ),
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
                                    onTap: () {
//                                      Navigator.push(
//                                          context,
//                                          MaterialPageRoute(
//                                              builder: (context) =>
//                                                  SignInDemo()));
                                     _handleSignIn();
                                    },
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
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
