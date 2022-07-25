import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'EditProfile.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'api_url.dart';

class ProfilePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ProfilePage> {
  String name = "";
  String email = "";
  String image = "";
  String phone = "";
  String address="";
  String earnigs="";

  registerCar(BuildContext context) {
    // alertbox
    final alertDialog = AlertDialog(
      title: Text(
        "Alert",
        style: TextStyle(
            color: Color(0xff474949)
        ),
      ),
      content: Text(
        "Are you really want to Log Out",
        style: TextStyle(color: Colors.grey),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Yes"),
          onPressed: (){
            logout();

//            changeSharedPreference();
          },
        ),
        FlatButton(
          child: Text("No"),
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
  List stationData;
  Map dataComment;
  List CommentData;
  getData(int id) async {
    print(id);
    http.Response response = await http.get(
        Uri.parse(ApiUrl.web_api_url+"api/user_profile/$id"));
    data = json.decode(response.body);

    setState(() {
      name=data['data']['name'];
      email=data['data']['email'];
      image=data['data']['user_image'];
    });

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height / 20),
        child: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            "My Profile",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
      ),
      backgroundColor: Colors.white,
      body: new Stack(
        children: <Widget>[

          ClipPath(
            child: Container(color: Colors.black.withOpacity(1)),
            clipper: GetClipper(),
          ),
          Positioned(
            right: 15.0,
            child: GestureDetector(
              onTap: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => EditProflie()));
              },
              child: Text(
                'Edit Profile',
                style: TextStyle(
                    fontFamily: 'Gotham',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ),
          ),
          Positioned(
            width: 350.0,
            left: 5,
            top: MediaQuery.of(context).size.height / 7,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(

                          image: DecorationImage(
                              image: AssetImage('assets/accountAvatar.jpg'),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.all(Radius.circular(105.0)),
                          boxShadow: [
                            BoxShadow(blurRadius: 9.0, color: Colors.black)
                          ]),
                    ),

                  ],
                ),
                SizedBox(height: 40.0),
                Container(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 25.0,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    Text(
//                      getBranch(branch),
//                      style: TextStyle(
//                        fontSize: 20.0,
//                        color: Colors.grey,
//                        // fontStyle: FontStyle.it,
//                      ),
//                    ),
//                    SizedBox(height: 15),
//                    Text(
//                      " - " + getYear(year),
//                      style: TextStyle(
//                        fontSize: 18.0,
//                        color: Colors.grey,
//                      ),
//                    ),
//                  ],
//                ),
                SizedBox(height: 20),
                Text(
                  'Email: ' + email,
                  style: TextStyle(
                    fontSize: 20.0,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
//                Text(
//                  'Address: ' + address,
//                  style: TextStyle(
//                    fontSize: 20.0,
//                    // fontWeight: FontWeight.bold,
//                  ),
//                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Image(image: AssetImage('assets/LOGO.jpg')),
                ),
//                Text(
//                  'Total Earnings: ' + earnigs,
//                  style: TextStyle(
//                    fontSize: 20.0,
//                    // fontWeight: FontWeight.bold,
//                  ),
//                ),
                SizedBox(
                  height: 10,
                ),
//                Image(
//                  image: AssetImage("assets/signUp.jpg"),
//                  // width: 20,
//                )
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        onPressed: () => registerCar(context),
        label: Text('Log Out', style: TextStyle(color: Colors.black),),
      ),
    );
  }

  void logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    Navigator.pushReplacementNamed(context, '/homescreen');
  }
}

class GetClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();

    path.lineTo(0.0, size.height / 3.5);
    path.lineTo(size.width + 60500, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

getBranch(String branch) {
  if (branch == 'CSA' || branch == 'CSB') return 'Computer Science';
  if (branch == 'ECA' || branch == 'ECB') return 'Electronics & Communication';
  if (branch == 'EB') return 'Electronics & Biomedical';
  if (branch == 'EEE') return 'Electronics & Electrical';
  return branch;
}

getYear(String year) {
  if (year == "1") return '1st Year';
  if (year == "2") return '2nd Year';
  if (year == "3") return '3rd Year';
  if (year == "4") return '4th Year';
  return year;
}
