import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:thats_montreal/Home/login.dart';
import 'package:thats_montreal/helper/locolizations.dart';

class GetStartedPage extends StatefulWidget {
  @override
  _GetStartedPageState createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  ProgressHUD progressHUD;
  Helper helper;
  @override
  Widget build(BuildContext context) {
    if(helper == null){
      helper = Helper(context, showProgressDialog, updateState);
      progressHUD = new ProgressHUD(
        backgroundColor: Colors.black12,
        color: Theme.of(context).accentColor,//Colors.white,
        containerColor: Colors.transparent, //Color(0xFF591758),
        borderRadius: 5.0,
        text: '',//Utilities.language == 'en' ? Utilities.pleaseWaitEn : Utilities.pleaseWaitAr,
        loading: false,
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFF151515),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              helper.buildStatusBar(),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(0.0),
                  physics: ClampingScrollPhysics(),
                  children: [
                    helper.buildLogo(),
                    helper.buildTextAndButton()
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

  void showProgressDialog(bool value) {
    setState(() {
      if (value) {
        progressHUD.state.show();
      } else {
        progressHUD.state.dismiss();
      }
    });
  }

  void updateState(){
    setState(() {

    });
  }
}

class Helper {
  BuildContext context;
  Function showProgressDialog, updateState;

  Helper(this.context, this.showProgressDialog, this.updateState);

  Widget buildStatusBar() {
    return Container(
      height: MediaQuery
          .of(context)
          .padding
          .top,
      color: Color(0xFF222222),
    );
  }

  Widget buildSafeArea() {
    return Container(
      height: MediaQuery
          .of(context)
          .padding
          .bottom,
      color: Color(0xFF222222),
    );
  }


  Widget buildLogo() {
    return Container(
      height: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.width/2.5, left: 15.0, right: 15.0),
      child: Image.asset('assets/splash_logo.png'),
    );
  }

  Widget buildTextAndButton(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).trans('cool_places_good_deals'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(
            height: 50.0,
          ),
          Container(
            decoration: BoxDecoration(
                color: Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(30.0)
            ),
            height: 60.0,
            width: MediaQuery.of(context).size.width,
            child: FlatButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
              },
              child: Text(
                AppLocalizations.of(context).trans('get_started'),
                style: TextStyle(
                    color: Colors.black, fontSize: 22.0, fontWeight: FontWeight.w900),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
            ),
          )
        ],
      ),
    );
  }

}