import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:thats_montreal/helper/locolizations.dart';

class WhoWeAre extends StatefulWidget {
  @override
  _WhoWeAreState createState() => _WhoWeAreState();
}

class _WhoWeAreState extends State<WhoWeAre> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(
              AppLocalizations.of(context).trans('w_for_what_we_do'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.yellow,
                  fontSize: 30
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                AppLocalizations.of(context).trans('w_for_what_we_do_msg'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 30
                ),
              ),
            ),
            SizedBox(
              width: 150,
              child: Divider(color: Colors.white,)
            ),
            SizedBox(
              width: 100,
              child: Divider(color: Colors.white,)
            ),
            Container(
              margin: EdgeInsets.only(top:20),
              child: Text(
                AppLocalizations.of(context).trans('who_are_we_msg'),
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.yellow,
                  fontFamily: 'Poppins'
                ),
              ),
            ),
            SizedBox(height: 30),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: AppLocalizations.of(context).trans('we_plan_to_reach'),
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontFamily: 'Poppins'
                ),
                children: <TextSpan> [
                  TextSpan(
                    text: AppLocalizations.of(context).trans('millions_of_people'),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.yellow,
                      fontSize: 17
                    ),
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context).trans('millions_of_people_msg'),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 17
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
//            Container(
//              height: MediaQuery.of(context).size.width * 0.8,
//              width: MediaQuery.of(context).size.width * 0.8,
//              decoration: BoxDecoration(
//                color: Colors.white
//              ),
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Icon(Icons.fastfood, color: Colors.black, size: 80,),
//                  Text(
//                    'VIDEO SERVICES',
//                    style: TextStyle(
//                      fontFamily: 'Poppins',
//                      color: Colors.black,
//                      fontSize: 25,
//                    ),
//                  ),
//                  Text(
//                    'Expose yourself!',
//                    style: TextStyle(
//                      fontFamily: 'Poppins',
//                      color: Colors.black,
//                      fontSize: 20,
//                    ),
//                  ),
//                ],
//              ),
//            ),
//            SizedBox(height: 20),
//            Container(
//              height: MediaQuery.of(context).size.width * 0.8,
//              width: MediaQuery.of(context).size.width * 0.8,
//              decoration: BoxDecoration(
//                color: Colors.white
//              ),
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Icon(Icons.photo_library, color: Colors.black, size: 80,),
//                  Text(
//                    'PHOTOGRAPHY',
//                    style: TextStyle(
//                      fontFamily: 'Poppins',
//                      color: Colors.black,
//                      fontSize: 25,
//                    ),
//                  ),
//                  Text(
//                    'Let your true colors shine though!',
//                    style: TextStyle(
//                      fontFamily: 'Poppins',
//                      color: Colors.black,
//                      fontSize: 20,
//                    ),
//                  ),
//                ],
//              ),
//            ),
//            SizedBox(height: 20),
//            Container(
//              height: MediaQuery.of(context).size.width * 0.8,
//              width: MediaQuery.of(context).size.width * 0.8,
//              decoration: BoxDecoration(
//                color: Colors.white
//              ),
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Icon(Icons.announcement, color: Colors.black, size: 80,),
//                  Text(
//                    'SPECIAL PORMOTIONS',
//                    style: TextStyle(
//                      fontFamily: 'Poppins',
//                      color: Colors.black,
//                      fontSize: 25,
//                    ),
//                  ),
//                  Text(
//                    'Get even more',
//                    style: TextStyle(
//                      fontFamily: 'Poppins',
//                      color: Colors.black,
//                      fontSize: 20,
//                    ),
//                  ),
//                ],
//              ),
//            ),
          ],
        ),
      ),
    );
  }
}