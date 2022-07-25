import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thats_montreal/helper/locolizations.dart';

import 'api_url.dart';

class EditProflie extends StatefulWidget {
  @override
  _EditProflieState createState() => _EditProflieState();
}

final TextEditingController _textEditingControllerName =
    TextEditingController();
final TextEditingController _textEditingControllerEmail =
    TextEditingController();
//final TextEditingController _textEditingControllerN = TextEditingController();

final _formKey = GlobalKey<FormState>();
String branch = "Male";
String year = '2001';

class _EditProflieState extends State<EditProflie> {
  int UserId;

  getUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    UserId = pref.getInt("user_id");
    getData(UserId);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserId();
  }

  Map data;
  String name = "";
  String email = "";
  String image = "";

  getData(int id) async {
    print(id);
    http.Response response = await http.get(Uri.parse(ApiUrl.web_api_url+"api/user_profile/$id"));
    data = json.decode(response.body);

    setState(() {
      name = data['data']['name'];
      email = data['data']['email'];
      image = data['data']['user_image'];
    });
  }

  editProfile(String name, String email, String password, String image) async {
    Map sendData = {
      "user_id": UserId.toString(),
      "name": name.toString(),
      "email": email.toString()
    };
    http.Response response = await http.post(
        Uri.parse(ApiUrl.web_api_url+"api/update_profile"),
        body: sendData);
    data = json.decode(response.body);
    print(response.body);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "Updated",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      Navigator.pushReplacementNamed(context, '/homescreen');
    }
//    setState(() {
//      name=data['data']['name'];
//      email=data['data']['email'];
//      image=data['data']['user_image'];
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).trans('edit_profile')),
        backgroundColor: Colors.black,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 10,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/accountAvatar.jpg'),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.all(Radius.circular(105.0)),
                    boxShadow: [
                      BoxShadow(blurRadius: 9.0, color: Colors.black)
                    ]),
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _textEditingControllerName,
                        decoration: InputDecoration(
                            helperText: name,
                            labelText: AppLocalizations.of(context).trans('name'),
                            labelStyle: TextStyle(fontFamily: 'Gotham')),
                      ),
                      TextFormField(
                        controller: _textEditingControllerEmail,
                        decoration: InputDecoration(
                            helperText: email,
                            labelText: AppLocalizations.of(context).trans('email'),
                            labelStyle: TextStyle(fontFamily: 'Gotham')),
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                            helperText: "********",
                            labelText: AppLocalizations.of(context).trans('password'),
                            labelStyle: TextStyle(fontFamily: 'Gotham')),
                      ),
                      SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Image(image: AssetImage('assets/LOGO.jpg')),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: 50,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(21.0),
                                    side: BorderSide(color: Colors.black)),
                                color: Colors.black,
                                child: Text(
                                  AppLocalizations.of(context).trans('edit').toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Gotham',
                                    fontSize: 15,
                                  ),
                                ),
                                textColor: Colors.white,
                                onPressed: () {
                                  print(_textEditingControllerName.text
                                      .toString()+
                                    _textEditingControllerEmail.text
                                        .toString(),);

                                  editProfile(
                                      _textEditingControllerName.text
                                          .toString(),
                                      _textEditingControllerEmail.text
                                          .toString(),
                                      "null",
                                      null);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
