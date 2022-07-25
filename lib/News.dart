import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thats_montreal/helper/locolizations.dart';

class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                 AppLocalizations.of(context).trans('n_for_news'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.yellow,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 10, right: 10),
                child: Text(
                  AppLocalizations.of(context).trans('n_for_news_msg')+":",
                  //textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontSize: 25,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 10, right: 10),
                child: Text(
                  AppLocalizations.of(context).trans('become_vip_member'),
                  //textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.yellow,
                    fontFamily: "Poppins",
                    fontSize: 25,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 10, right: 10),
                child: Text(
                  AppLocalizations.of(context).trans('to_this_address')+" : info@thatsmontreal.com.",
                  //textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontSize: 25,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 10, right: 10),
                child: Text(
                  AppLocalizations.of(context).trans('random_surprises_msg'),
                  //textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontSize: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
