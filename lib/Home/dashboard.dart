import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thats_montreal/Email.dart';
import 'package:thats_montreal/Home/announcement_detail.dart';
import 'package:thats_montreal/Home/billboard_page.dart';
import 'package:thats_montreal/Home/create_announcement.dart';
import 'package:thats_montreal/Home/edit_profile_page.dart';
import 'package:thats_montreal/Home/home_page.dart';
import 'package:thats_montreal/Home/login.dart';
import 'package:thats_montreal/Home/montreal_station.dart';
import 'package:thats_montreal/Home/morePage.dart';
import 'package:thats_montreal/Home/pdfViewer.dart';
import 'package:thats_montreal/Home/search_page.dart';
import 'package:thats_montreal/Home/update_announcement.dart';
import 'package:thats_montreal/Home/view_all_announcements.dart';
import 'package:thats_montreal/HomeScreen.dart';
import 'package:thats_montreal/News.dart';
import 'package:thats_montreal/Pdf_Viewer.dart';
import 'package:thats_montreal/api_url.dart';
import 'package:thats_montreal/globals.dart';
import 'package:thats_montreal/helper/language.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/model/md_announcement.dart';
import 'package:thats_montreal/model/md_menu.dart';
import 'package:thats_montreal/notification_page.dart';
import 'package:thats_montreal/utilities.dart';
import 'package:url_launcher/url_launcher.dart';

import '../WhoWeAre.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Helper helper;
  ProgressHUD progressHUD;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if(helper == null){
      helper = Helper(context, showProgressDialog, updateState);
      progressHUD = new ProgressHUD(
        backgroundColor: Colors.black12,
        color: Theme.of(context).accentColor,//Colors.white,
        containerColor: Colors.transparent, //Color(0xFF591758),
        borderRadius: 5.0,
        text: '',
        loading: false,
      );
    }
    return Scaffold(
        backgroundColor: Colors.white,
        key: helper.scaffoldKey,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                helper.buildStatusBar(),
                helper.isSearch ? helper.buildSearchBar() : Container(),
//                helper.announcementList.isNotEmpty && helper.isApiLoaded ? helper.myAnnouncementsHeading() : Container(),
                Expanded(
                  child: helper.buildMenuBody(),
//                    child: RefreshIndicator(child: helper.buildAnnouncementList(),
//                    onRefresh: refreshAnnouncements,
//                    ),
                ),
                helper.buildBottomMenu(),
                helper.buildSafeArea(),
              ],
            ),
            Positioned(
              child: progressHUD,
            ),
          ],
        ),
        drawer: helper.buildDrawer(),
    );

  }

  Future<void> refreshAnnouncements() async {
    setState(() {
      showProgressDialog(true);
      helper.announcementList = [];
      helper.isApiLoaded = false;
      helper.apiGetAnnouncementList(false);
    });
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
  Function showProgressDialog;
  Function updateState;
  SharedPreferences preferences;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<MDMenu> menuList = [];
  bool isApiLoaded = false;
  bool isSearch = false;
  String category = '', keyword = '';
  String categoryInitialList = 'All,Event and Activities,Product To Buy,Small Business,Community services,Self Portfolio,Deals & Promotions,Appartments/Hotel/Rental locations,Restauration,Entertainment,Transport,Other';
  List<String> categoryList = [];
  FocusNode keywordNode = FocusNode();

  List<MDAnnouncement> announcementList=[];
  int currentImageIndex = 0;

  bool isHome = true,
      isMontRealStation = false,
      isBillboard = false,
      isSearchTab = false,
      isMore = false,
      isMenu = false;
  HomePage homePage;
  BillboardPage billboardPage;
 // HomePage stationsPage;
  SearchPage searchPage;
  MontrealStationPage montrealStationPage;
  MorePage morePage;
  Helper(this.context, this.showProgressDialog, this.updateState) {
    getLanguage();
    category = categoryInitialList.split(',')[0];
    categoryList =categoryInitialList.split(',');
    SharedPreferences.getInstance().then((value) {
      preferences = value;
      print(preferences.getString('email'));
    });
/*
    if(!Utilities.isGuest){
      buildNavbarMenu();
    }
*/
    buildNavbarMenu();
    homePage = HomePage();
    billboardPage = BillboardPage();
    //stationsPage = HomePage();
    searchPage = SearchPage();
    montrealStationPage = MontrealStationPage();
    morePage = MorePage(menuList);
  //  stationsPage = Stations();
//    apiGetAnnouncementList(false);
  }
  getLanguage()async{
    print("geting language");
    if(Utilities.language=="en"){
      String jsonContent = await rootBundle.loadString("assets/lang/en.json");
      Globals.textData = json.decode(jsonContent);
    }else{
      String jsonContent = await rootBundle.loadString("assets/lang/fr.json");
      Globals.textData  = json.decode(jsonContent);
    }
  }
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

  Widget buildActionBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Colors.black
          ),
          height: 55.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 10,
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: (){
                  scaffoldKey.currentState.openDrawer();
                },
                child: Icon(
                  Icons.view_headline,
                  size: 30.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    AppLocalizations.of(context).trans('dashboard'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              Utilities.isGuest ? InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: (){
                  isSearch = !isSearch;
                  updateState();
                },
                child: Icon(
                  isSearch ? Icons.close : Icons.search,
                  size: 25,
                  color: Colors.white,
                ),
              ) : Container(),
              SizedBox(
                width: 10.0,
              )
            ],
          ),
        ),
      ],
    );
  }


  //Drawer Items Start
  Widget buildDrawer() {
    return Drawer(
      child: Column(
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
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFCE860)
            ),
            width: MediaQuery.of(context).size.width-50,
            child: Center(
              child: Text(
                AppLocalizations.of(context).trans('leave_a_feedback'),
                style: TextStyle(
                  color: Color(0xFF151515),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w900
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width-50,
            decoration: BoxDecoration(
                color: Color(0xFFFCE860)
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 5.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width-50,
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  height: 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xFFF4D500)
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 25.0,
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).trans('terms_and_conditions'),
                        style: TextStyle(
                          color: Color(0xFF535353),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w300
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: (){

                        },
                        child: Text(
                          AppLocalizations.of(context).trans('privacy_policy'),
                          style: TextStyle(
                              color: Color(0xFF535353),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w300
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.0,
                )
              ],
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
          buildSafeArea(),
        ],
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Language(true)));
                },
                child: Text(
                  Utilities.language =='en'? "EN" : "FR",
                  style: TextStyle(
                    color: Color(0xFF151515),
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Color(0xFFA4A0A0),
              )
            ],
          ),
          Expanded(
            child: Container(),
          ),
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

  void buildNavbarMenu() {
//    MDMenu menuItem = MDMenu('Profile', FontAwesomeIcons.user,
//        'profile');
//    menuList.add(menuItem);
    MDMenu menuItem;
  if(!Utilities.isGuest)
    {
      MDMenu menuItem = MDMenu(AppLocalizations.of(context).trans('edit_profile'), 'assets/update_icon.png',
          'edit_profile');
      menuList.add(menuItem);
    }

    menuItem = MDMenu(AppLocalizations.of(context).trans('change_language'), 'assets/globe.png',
        'change_language');
    menuList.add(menuItem);

    menuItem = MDMenu(AppLocalizations.of(context).trans('news'), 'assets/news_icon.png',
        'news');
    menuList.add(menuItem);

    menuItem = MDMenu(AppLocalizations.of(context).trans('who_we_are'), 'assets/who_we_are_icon.png',
        'who_we_are');
    menuList.add(menuItem);


    menuItem = MDMenu(AppLocalizations.of(context).trans('email_us'), 'assets/email_icon.png',
        'email_us');
    menuList.add(menuItem);


    print("language:${Utilities.language}");
    menuItem = MDMenu(
        Utilities.language=="en"?"All Gifts":"Tous les cadeaux", 'assets/gift_icon.png',
        'save_with_gifts');
    menuList.add(menuItem);
    menuItem = MDMenu(Globals.textData['prices'].toString()??"", 'assets/price_icon.png', 'prices');
    menuList.add(menuItem);
  }

  Widget buildMenuList() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFCE860),
//            border: Border(
//              right: BorderSide(color: Color(0xFF999999), width: 0.6),
//            ),
        borderRadius: BorderRadius.only(topRight: Radius.circular(50.0))
        ),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 15),
          itemBuilder: buildMenuItem,
          itemCount: menuList.length,
        ),
      ),
    );
  }

  Widget buildMenuItem(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        print("clicking");
        print(index);
        handleMenuItemClickListener(menuList[index]);
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.0),
                    border: Border.all(
                      color: Color(0xFFF4D500),
                      width: 1.0
                    )
                  ),
                  child: Image.asset(
                    menuList[index].image,
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
                    menuList[index].name,
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
        ],
      ),
    );
  }

  void handleMenuItemClickListener(MDMenu menu) async{
    Navigator.pop(context);
    switch (menu.tag) {
      case 'home':
        scaffoldKey.currentState.openEndDrawer();
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
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Language(true);
          }));
        break;
      case 'create_announcement':
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateAnnouncement())).then((value){
              if(value !=null){
                showProgressDialog(true);
                apiGetAnnouncementList(false);
              }
        });
        break;
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

  //Drawer Ended

  Widget buildSearchBar(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
          SizedBox(
            height: 5.0,
          ),
          buildCategoryDropdown(),
          buildKeywordField(),
          buildSearchButton(),
        ],
      ),
    );
  }

  Widget buildCategoryDropdown() {
    return Container(
      child: PopupMenuButton<String>(
        offset: Offset(0, 65),
        child: buildCategoryDropdownWidget(),
        padding: EdgeInsets.all(0.0),
        onSelected: (value) {
          category = value;
          updateState();
        },
        itemBuilder: (BuildContext context) {
          return categoryList.map((String value) {
            return PopupMenuItem<String>(
              value: value,
              height: 45,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                width: MediaQuery.of(context).size.width,
                child: Text(value),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget buildCategoryDropdownWidget(){
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Container(
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 15.0,
                ),
                Expanded(
                    child: Container(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                ),
                SizedBox(
                  width: 50.0,
                ),
                Container(
                  height: 50,
                  width: 47,
                  child: Icon(
                    FontAwesomeIcons.chevronDown,
                    size: 15,
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          ),
        ],
      ),);
  }

  Widget buildKeywordField(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 5.0,
          ),
          InkWell(
            onTap: (){
              FocusScope.of(context).requestFocus(keywordNode);
            },
            child: Container(
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.text,
                        focusNode: keywordNode,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText:
                          AppLocalizations.of(context).trans('keyword'),
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
                        onChanged: (value) => keyword = value,
                        maxLines: 1,
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget buildSearchButton() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(5.0)
          ),
          height: 45.0,
          width: MediaQuery.of(context).size.width,
          child: FlatButton(
            onPressed: () {
              isSearch = false;
              showProgressDialog(true);
              apiGetAnnouncementList(true);
              updateState();
            },
            child: Text(
              AppLocalizations.of(context).trans('search').toUpperCase(),
              style: TextStyle(
                  color: Colors.white, fontSize: 16.0, fontFamily: 'bold'),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
        SizedBox(
          height: 10.0 ,
        ),
      ],
    );
  }

  Widget myAnnouncementsHeading(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Text(
        Utilities.isGuest ? AppLocalizations.of(context).trans('that_mont_billboard') : AppLocalizations.of(context).trans('my_announcements'),
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }

  Widget buildAnnouncementList(){
    return announcementList.isEmpty && isApiLoaded ? buildNoAnnouncement() : ListView.builder(itemBuilder: buildAnnouncementCard,
      padding: EdgeInsets.all(0.0),
      shrinkWrap: true,
      itemCount: announcementList.length,
      physics: AlwaysScrollableScrollPhysics(),
    );
  }

  Widget buildNoAnnouncement(){
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          height: MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top+MediaQuery.of(context).padding.bottom+50),
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Text(
              AppLocalizations.of(context).trans('no_announcement_available'),
              style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAnnouncementCard(BuildContext context, int index){
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> AnnouncementDetail(announcementList[index].id)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300], width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProductCarousel(context, index),
            SizedBox(
              height: 10.0,
            ),
            Utilities.isGuest ? Container() : Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> UpdateAnnouncement(announcementList[index]))).then((value){
                        if(value != null){
                          showProgressDialog(true);
                          apiGetAnnouncementList(false);
                        }
                      });
                    },
                    child: Icon(
                      FontAwesomeIcons.edit,
                      size: 20.0,
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: (){
                      openDeleteAnnouncementConfirmation(announcementList[index].id);
                    },
                    child: Icon(
                      Icons.delete,
                      size: 25.0,
                    ),
                  ),
                ],
              ),
            ),
            Utilities.isGuest ? Container() : SizedBox(
              height: 10.0,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Text(AppLocalizations.of(context).trans('duration')+': ${announcementList[index].duration.toString()} '+AppLocalizations.of(context).trans('days'),
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 15.0,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Text(
                    dateFormat(announcementList[index].created_at),
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                announcementList[index].title,
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                announcementList[index].category,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                announcementList[index].body,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
            SizedBox(
              height: 10.0,
            )
          ],
        ),
      ),
    );
  }

  Widget buildProductCarousel(context, index){
    return Container(
      height: MediaQuery.of(context).size.width/1.5,
      color: Color(0xFFF5F5F5),
      child: Stack(
        children: <Widget>[
          Positioned(
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> AnnouncementDetail(announcementList[index].id)));
              },
              child: announcementList[index].announcement_gallery.isEmpty ?  Container(
                color: Color(0xFFF5F5F5),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width/1.5,
                child: AspectRatio(
                  aspectRatio: 184/131,
                  child: Image.asset('assets/product.png', fit: BoxFit.cover,),
                ),
              ) : CarouselSlider(
                initialPage: 0,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                height: MediaQuery.of(context).size.width/1.5,
                onPageChanged: (index) {
                  currentImageIndex = index;
                  updateState();
                },
                items: announcementList[index].announcement_gallery.map((image) {
                  return productImage(image.path);
                }).toList(),
              ),
            ),
          ),
          Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 3.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 25,
                    width: MediaQuery.of(context).size.width - 32,
                    child: Center(
                      child: ListView.builder(
                          itemCount: announcementList[index].announcement_gallery.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Center(
                              child: Container(
                                width: 8.0,
                                height: 8.0,
                                margin: EdgeInsets.symmetric(horizontal: 2.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currentImageIndex != index
                                        ? Colors.white
                                        : Colors.transparent,
                                    border: Border.all(
                                        color: currentImageIndex != index
                                            ? Colors.white
                                            : Theme.of(context).accentColor,
                                        width: 1.5)),
                              ),
                            );
                          }),
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }

  Widget productImage(String image) {
    return InkWell(
      onTap: () {

      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        color: Color(0xFFF5F5F5),
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: 184/131,
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: ApiUrl.web_image_url+image,
//            height: MediaQuery.of(context).size.width / 1.4,
//            width: MediaQuery.of(context).size.width,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                  color: Color(0xFFD7D7D7)
              ),
              child: Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Image.asset(
              'assets/product.png',
              fit: BoxFit.cover,),
          ),
        ),
      ),
    );
  }


  void apiGetAnnouncementList(bool isSearch) {
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';
    String url;

    if(isSearch){
      if(category == 'All'){
        url = ApiUrl.web_api_url+"api/announcement?keyword=$keyword";
        keyword = '';
      }else{
        url = ApiUrl.web_api_url+"api/announcement?category=$category&keyword=$keyword";
        keyword = '';
        category = 'All';
      }

    }else{
      if(Utilities.isGuest){
        url = ApiUrl.web_api_url+"api/announcement";
      }else{
        url = ApiUrl.web_api_url+"api/user/announcement?user_id=${Utilities.user.user_id}";
      }
    }

    print(url);

    http.get(Uri.parse(url), headers: header).then((response) {
      isApiLoaded = true;
      List<dynamic> mapppedResponse = jsonDecode(response.body);
//      if(!mapppedResponse['status']){
//        String msg = mapppedResponse['message'];
//        Fluttertoast.showToast(
//            msg: msg,
//            toastLength: Toast.LENGTH_SHORT,
//            gravity: ToastGravity.BOTTOM,
//            timeInSecForIosWeb: 1,
//            backgroundColor: Colors.grey,
//            textColor: Colors.white,
//            fontSize: 16.0);
//      }else{
//        print(mapppedResponse);
//        announcementList = (mapppedResponse as List).map((e) => MDAnnouncement.fromJson(e)).toList();
//        updateState();
//      }

      print(mapppedResponse);
      announcementList = (mapppedResponse as List).map((e) => MDAnnouncement.fromJson(e)).toList();
      updateState();
      showProgressDialog(false);
    });
  }


  String dateFormat(String date){
    List<String> newDate = date.split(' ');
    var dateTimeStame = DateTime.parse(date).toUtc().millisecondsSinceEpoch;
    print(dateTimeStame.toString());

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateTimeStame);
    return intl.DateFormat("MMM dd, yyyy").format(dateTime);
//    return newDate[0];
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

  void openDeleteAnnouncementConfirmation(int id) {
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
                            AppLocalizations.of(context).trans('do_you_want_to_delete_announcement')
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
                                apiDeleteAnnouncement(id);
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
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.circular(5.0)
                                ),
                                child: Center(
                                  child: Text(AppLocalizations.of(context).trans('no'), style: TextStyle(
                                    color: Colors.white,
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

  void apiDeleteAnnouncement(int id) {
    showProgressDialog(true);
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';

    http.get(Uri.parse(ApiUrl.web_api_url+"api/user/announcement-delete/$id?user_id=${Utilities.user.user_id}"), headers: header).then((response) {
      isApiLoaded = true;
      Map mappedResponse = jsonDecode(response.body);
      print(mappedResponse);
      String msg = mappedResponse['message'];
        Fluttertoast.showToast(
            msg: msg,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
        if(msg =='Announcement Deleted Successfully'){
          announcementList = [];
          isApiLoaded = false;
          apiGetAnnouncementList(false);
        }else{
          showProgressDialog(false);
        }
      updateState();
    });
  }

  Widget buildMenuBody(){
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            height: isHome ? MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom+ 70) : 0.0,
            child: homePage,
          ),
          Container(
            height: isMontRealStation ? MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom+ 70) : 0.0,
            child: montrealStationPage,
          ),
          Container(
            height: isBillboard ? MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom+ 70) : 0.0,
            child: billboardPage,
          ),
          Container(
            height: isSearchTab ? MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom+ 70) : 0.0,
            child: searchPage,
          ),
          Container(
            height: isMore ? MediaQuery.of(context).size.height - (MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom+ 70) : 0.0,
            child: morePage,
          ),
        ],
      ),
    );
  }


  Widget buildBottomMenu(){
    return Container(
      color: isMore?Colors.yellow:Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ]
        ),
        height: 70.0,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: (){
                  if(!isHome){
                    isHome = true;
                    isMontRealStation = false;
                    isBillboard = false;
                    isMenu = false;
                    isSearchTab = false;
                    isMore = false;
                    updateState();
                  }
                },
                child: Container(
                 decoration: BoxDecoration(
                   border: Border(
                    bottom: BorderSide( //                   <--- left side
                     color: isHome?Color(0xFFFF0000):Colors.transparent,
                       width: 3.0,
                     ),
                    ),
                 ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset('assets/home_icon.png', color: isHome ? Color(0xFFFF0000) : Color(0xFF707070), width: 30,),
                        Text(
                          AppLocalizations.of(context).trans('home'),
                          style: TextStyle(
                            color: isHome ? Color(0xFFFF0000) : Color(0xFF707070),
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: (){
                 // Navigator.push(context, MaterialPageRoute(builder: (context) => MontrealStationPage()));
                 if(!isMontRealStation){
                   isHome = false;
                   isMontRealStation = true;
                   isBillboard = false;
                   isMenu = false;
                   isSearchTab = false;
                   isMore = false;
                   updateState();
                 }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide( //                   <--- left side
                        color: isMontRealStation?Color(0xFFFF0000):Colors.transparent,
                        width: 3.0,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset('assets/montreal_stations.png', color: isMontRealStation ? Color(0xFFFF0000) : Color(0xFF707070), width: 30,),
                        Text(
                          AppLocalizations.of(context).trans('montreal_station'),
                          style: TextStyle(
                            color: isMontRealStation ? Color(0xFFFF0000) : Color(0xFF707070),
                            fontSize: 12.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: (){
                  if(!isBillboard){
                    isHome = false;
                    isMontRealStation = false;
                    isBillboard = true;
                    isMenu = false;
                    isSearchTab = false;
                    isMore = false;
                    updateState();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide( //                   <--- left side
                        color: isBillboard?Color(0xFFFF0000):Colors.transparent,
                        width: 3.0,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset('assets/billboard_icon.png', color: isBillboard ? Color(0xFFFF0000) : Color(0xFF707070), width: 30.0,),
                        Text(
                          AppLocalizations.of(context).trans('billboards'),
                          style: TextStyle(
                            color: isBillboard ? Color(0xFFFF0000) : Color(0xFF707070),
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: (){
                  if(!isSearchTab){
                    isHome = false;
                    isMontRealStation = false;
                    isBillboard = false;
                    isSearchTab = true;
                    isMenu = false;
                    isMore = false;
                    updateState();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide( //                   <--- left side
                        color: isSearchTab?Color(0xFFFF0000):Colors.transparent,
                        width: 3.0,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset('assets/search.png', color: isSearchTab ? Color(0xFFFF0000) : Color(0xFF707070), width: 24.0,),
                        Text(
                          AppLocalizations.of(context).trans('search'),
                          style: TextStyle(
                            color: isSearchTab ? Color(0xFFFF0000) : Color(0xFF707070),
                            fontSize: 12.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: (){
                  //scaffoldKey.currentState.openDrawer();
                  if(!isMore){
                    isHome = false;
                    isMontRealStation = false;
                    isBillboard = false;
                    isSearchTab = false;
                    isMenu = false;
                    isMore = true;
                    updateState();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide( //                   <--- left side
                        color: isMore?Color(0xFFFF0000):Colors.transparent,
                        width: 3.0,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset('assets/more_icon.png', color: isMore ? Color(0xFFFF0000) : Color(0xFF707070), width: 30.0,),
                        Text(
                          AppLocalizations.of(context).trans('more'),
                          style: TextStyle(
                            color: isMore ? Color(0xFFFF0000) : Color(0xFF707070),
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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


}