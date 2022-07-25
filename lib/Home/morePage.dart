import 'package:flutter/material.dart';
import 'package:thats_montreal/Email.dart';
import 'package:thats_montreal/Home/create_announcement.dart';
import 'package:thats_montreal/Home/edit_profile_page.dart';
import 'package:thats_montreal/Home/login.dart';
import 'package:thats_montreal/Home/pdfViewer.dart';
import 'package:thats_montreal/Home/view_all_announcements.dart';
import 'package:thats_montreal/HomeScreen.dart';
import 'package:thats_montreal/News.dart';
import 'package:thats_montreal/Pdf_Viewer.dart';
import 'package:thats_montreal/WhoWeAre.dart';
import 'package:thats_montreal/api_url.dart';
import 'package:thats_montreal/globals.dart';
import 'package:thats_montreal/helper/language.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/model/md_menu.dart';
import 'package:thats_montreal/notification_page.dart';
import 'package:thats_montreal/utilities.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';import 'package:url_launcher/url_launcher.dart';

class MorePage extends StatefulWidget {
  final  List<MDMenu> menuList;
  MorePage(this.menuList);
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
 // List<MDMenu> menuList = [];
  SharedPreferences preferences;
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   buildNavbarMenu();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: buildDrawer());
  }
//   void buildNavbarMenu() {
// //    MDMenu menuItem = MDMenu('Profile', FontAwesomeIcons.user,
// //        'profile');
// //    menuList.add(menuItem);
//
//     MDMenu menuItem = MDMenu(AppLocalizations.of(context).trans('edit_profile'), 'assets/update_icon.png',
//         'edit_profile');
//     menuList.add(menuItem);
//
//     menuItem = MDMenu(AppLocalizations.of(context).trans('notification'), 'assets/notification_icon.png',
//         'notification');
//     menuList.add(menuItem);
//
//     menuItem = MDMenu(AppLocalizations.of(context).trans('news'), 'assets/news_icon.png',
//         'news');
//     menuList.add(menuItem);
//
//     menuItem = MDMenu(AppLocalizations.of(context).trans('who_we_are'), 'assets/who_we_are_icon.png',
//         'who_we_are');
//     menuList.add(menuItem);
//
//
//     menuItem = MDMenu(AppLocalizations.of(context).trans('email_us'), 'assets/email_icon.png',
//         'email_us');
//     menuList.add(menuItem);
//
//
//     menuItem = MDMenu(AppLocalizations.of(context).trans('save_with_gifts'), 'assets/gift_icon.png',
//         'save_with_gifts');
//     menuList.add(menuItem);
//     menuItem = MDMenu(Globals.textData['price'].toString()??"", 'assets/price_icon.png', 'prices');
//     menuList.add(menuItem);
//   }
  Widget buildDrawer() {
    return Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).padding.top + 200,
          width: MediaQuery.of(context).size.width - 50,
//            color: Colors.black54,
          child: Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).padding.top + 200,
                width: MediaQuery.of(context).size.width - 50,
                child: Container(),
              ),
              Container(
                height: MediaQuery.of(context).padding.top + 200,
                width: MediaQuery.of(context).size.width - 50,
                padding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: buildHeader(),
              ),
            ],
          ),
        ),
        buildMenuList(),
        // Divider(
        //     color: Color(0xFFF4D500)
        // ),
        // Container(
        //   decoration: BoxDecoration(
        //       color: Color(0xFFFCE860)
        //   ),
        //   width: MediaQuery.of(context).size.width-50,
        //   child: Center(
        //     child: Text(
        //       AppLocalizations.of(context).trans('leave_a_feedback'),
        //       style: TextStyle(
        //           color: Color(0xFF151515),
        //           fontSize: 20.0,
        //           fontWeight: FontWeight.w900
        //       ),
        //     ),
        //   ),
        // ),
        // Container(
        //   width: MediaQuery.of(context).size.width-50,
        //   decoration: BoxDecoration(
        //       color: Color(0xFFFCE860)
        //   ),
        //   child: Column(
        //     children: [
        //       SizedBox(
        //         height: 5.0,
        //       ),
        //       Container(
        //         width: MediaQuery.of(context).size.width-50,
        //         margin: EdgeInsets.symmetric(horizontal: 20.0),
        //         height: 1.0,
        //         decoration: BoxDecoration(
        //             color: Color(0xFFF4D500)
        //         ),
        //       ),
        //       SizedBox(
        //         height: 5.0,
        //       ),
        //       Row(
        //         children: [
        //           SizedBox(
        //             width: 25.0,
        //           ),
        //           Expanded(
        //             child: Text(
        //               AppLocalizations.of(context).trans('terms_and_conditions'),
        //               style: TextStyle(
        //                   color: Color(0xFF535353),
        //                   fontSize: 14.0,
        //                   fontWeight: FontWeight.w300
        //               ),
        //             ),
        //           ),
        //           SizedBox(
        //             width: 10.0,
        //           ),
        //           Expanded(
        //             child: InkWell(
        //               onTap: (){
        //
        //               },
        //               child: Text(
        //                 AppLocalizations.of(context).trans('privacy_policy'),
        //                 style: TextStyle(
        //                     color: Color(0xFF535353),
        //                     fontSize: 14.0,
        //                     fontWeight: FontWeight.w300
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //       SizedBox(
        //         height: 15.0,
        //       )
        //     ],
        //   ),
        // ),
        buildSafeArea(),
      ],
    );
  }
  Widget showLogout(){
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          width: MediaQuery.of(context).size.width-50,
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          height: 1.0,
          decoration: BoxDecoration(
              color: Color(0xFFF4D500)
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width-50,
            decoration: BoxDecoration(
                color: Color(0xFFFCE860)
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: openLogoutConfirmatinoDialog,
                child: Text("Logout",style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    height: 1.0

                ),textAlign: TextAlign.center,),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget buildHeader() {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: (){

      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).padding.top,
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
          //     )
          //   ],
          // ),
          // Expanded(
          //   child: Container(),
          // ),
          SizedBox(
            height: 4,
          ),
          Utilities.isGuest ? Flexible(
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  AppLocalizations.of(context).trans('login_as_user'),
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'regular',
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ) : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80.0,
                width: 80.0,
                decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFFCE860), width: 3.0),
                    borderRadius: BorderRadius.circular(40.0)
                ),
                child: ClipRRect(
                  child: FadeInImage.assetNetwork(placeholder: 'assets/accountAvatar.jpg', image: ApiUrl.user_image_url+Utilities.user.image),
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          !Utilities.isGuest ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: InkWell(
                  onTap: () {

                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      Utilities.user.email,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'regular',
                          color: Color(0xFF151515),
                          fontWeight: FontWeight.w900
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ) : Container()
        ],
      ),
    );
  }
  Widget buildMenuList() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xFFFCE860),
//            border: Border(
//              right: BorderSide(color: Color(0xFF999999), width: 0.6),
//            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0))
        ),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 15),
          itemBuilder: buildMenuItem,
          itemCount: widget.menuList.length,
        ),
      ),
    );
  }
  Widget buildMenuItem(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        handleMenuItemClickListener(widget.menuList[index]);
      },
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
            width: MediaQuery.of(context).size.width - 50,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width/8,
                ),
                Container(
                  height: 30,
                  width: 30,
                  padding: EdgeInsets.all(index==1||index==6?5:0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.0),
                      border: Border.all(
                          color: Color(0xFFF4D500),
                          width: 1.0
                      )
                  ),
                  child: Image.asset(
                    widget.menuList[index].image,
                    width: 30,
                    color: Color(0xFFF94E0D),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.49,
                  child: Text(
                    widget.menuList[index].name,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        height: 1.0
                    ),
                  ),
                ),
              ],
            ),
          ),
          index==widget.menuList.length-1?showLogout():Container(),
        ],
      ),
    );
  }
  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  void handleMenuItemClickListener(MDMenu menu) async{
    //Navigator.pop(context);
    switch (menu.tag) {
      case 'home':
        //scaffoldKey.currentState.openEndDrawer();
        break;
      case 'notification':
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return NotificationPage();
        }));
        break;
      case 'edit_profile':
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return EditProfile();
        }));
        break;
      case 'news':
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return NewsScreen();
        }));
        break;
      case 'who_we_are':
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return WhoWeAre();
        }));
        break;
      case 'email_us':
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return EmailScreen();
        }));
        break;

      case 'save_with_gifts':
        print("clicked");
        launchURL("https://thatsmontreal.com/blog");

//        Navigator.push(context, MaterialPageRoute(builder: (context) {
//          return ;
//        }));
        break;
      case 'change_language':
        Get.to(Language(true));
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return Language(true);
        // }));
        break;
      // case 'create_announcement':
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => CreateAnnouncement())).then((value){
      //     if(value !=null){
      //       showProgressDialog(true);
      //       apiGetAnnouncementList(false);
      //     }
      //   });
      //   break;
      case 'view_announcement':
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ViewAllAnnouncements()));
        break;
      case 'prices':
        try{
          PDFDocument document = await PDFDocument.fromAsset("assets/prices.pdf");
          if(document!=null){
            Get.to(PdfViewer(document));
          }
        }catch(e){
          print(e);
        }
        //Get.to(PdfMapViewer(), arguments: ['Prices', "assets/prices.pdf"]);
        break;
    }
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
  void openLogoutConfirmatinoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              Navigator.pop(context);
            },
            child: GestureDetector(
              onTap: (){},
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 15.0),
                child: Center(
                  child: Container(
                    //height: 135,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          child: Text(AppLocalizations.of(context).trans('alert'), style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'medium',
                          ),
                            textAlign: TextAlign.center,
                          ),

                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          child: Text(
                            AppLocalizations.of(context).trans('do_you_want_logout')
                            , style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                            fontFamily: 'medium',
                          ),
                            textAlign: TextAlign.center,
                          ),

                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: (){
                                Navigator.pop(context);
                                SharedPreferences.getInstance().then((value) {
                                  preferences = value;
                                  preferences.setBool("isLogin", false).then((isLoginSet) {
                                    if (isLoginSet) {
                                      preferences.setBool('isSocialLogin', false)
                                          .then((isSocialLoginSet) {
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => HomeScreen()),
                                                (Route<dynamic> route) => false);
                                      });
                                    }
                                  });
                                });
                              },
                              child: Container(
                                height: 32,
                                width: 105,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.circular(5.0)
                                ),
                                child: Center(
                                  child: Text(AppLocalizations.of(context).trans('yes'), style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: 'medium',
                                  ),),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            InkWell(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 32,
                                width: 105,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                        color: Colors.black
                                    )
                                ),
                                child: Center(
                                  child: Text(AppLocalizations.of(context).trans('no'), style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontFamily: 'medium',
                                  ),),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        //
      },
    );
  }
}
