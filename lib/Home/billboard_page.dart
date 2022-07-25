import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:thats_montreal/Home/update_announcement.dart';
import 'package:thats_montreal/helper/custom_grid_view.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/model/md_announcement.dart';
import 'package:thats_montreal/model/md_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart' as intl;


import '../api_url.dart';
import '../utilities.dart';
import 'announcement_detail.dart';
import 'create_announcement.dart';

class BillboardPage extends StatefulWidget {
  @override
  _BillboardPageState createState() => _BillboardPageState();
}

class _BillboardPageState extends State<BillboardPage> {
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
        loading: true,
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      key: helper.scaffoldKey,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  child: helper.buildOverallList(),
                  onRefresh: refreshAnnouncements,
                ),
              ),
            ],
          ),
          Positioned(
            child: progressHUD,
          ),
        ],
      ),
    );

  }
  Future<void> refreshAnnouncements() async {
    setState(() {
      showProgressDialog(true);
      helper.announcementList = [];
      helper.isApiLoaded = false;
      helper.selectedCategoryIndex = 0;
      helper.searchController.clear();
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
  bool isLoading = false;
  Function updateState;
  SharedPreferences preferences;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<MDMenu> menuList = [];
  bool isApiLoaded = false;
  bool isSearch = false;
  String category = '',
      keyword = '';
  String categoryInitialList = 'All,Event and Activities,Product To Buy,Small Business,Community services,Self Portfolio,Deals & Promotions,Appartments/Hotel/Rental locations,Restauration,Entertainment,Transport,Other';
  List<String> categoryList = [];
  FocusNode keywordNode = FocusNode();
  int selectedCategoryIndex = 0;
  TextEditingController searchController = TextEditingController();

  List<MDAnnouncement> announcementList = [];
  int currentImageIndex = 0;

  Helper(this.context, this.showProgressDialog, this.updateState) {
    category = categoryInitialList.split(',')[0];
    categoryList =categoryInitialList.split(',');
    SharedPreferences.getInstance().then((value) {
      preferences = value;
      print(preferences.getString('email'));
    });
    apiGetAnnouncementList(false);
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

  Widget buildSearchBar(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: [
          SizedBox(
            height: 5.0,
          ),
          buildKeywordField(),
          SizedBox(
            height: 25.0,
          ),
          buildCategories(),
        ],
      ),
    );
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
                height: 55,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      )
                    ]
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset('assets/search_icon.png', width: 30.0,),
                          SizedBox(
                            width: 5.0,
                          ),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.search,
                              focusNode: keywordNode,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(0),
                                border: OutlineInputBorder(borderSide: BorderSide.none),
                                hintText:
                                AppLocalizations.of(context).trans('search'),
                                hintStyle: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: 'regular',
                                  color: Color(0xFFA3A3A3),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: 'regular',
                                color: Color(0xFF666666),
                              ),
                              onChanged: (value) => keyword = value,
                              maxLines: 1,
                              controller: searchController,
                              onSubmitted: (value){
                                showProgressDialog(true);
                                apiGetAnnouncementList(true);
                                updateState();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget buildCategories(){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).trans('categories'),
            style: TextStyle(
                color: Color(0xFF7B7580),
                fontSize: 20.0,
                fontWeight: FontWeight.w400
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          buildCategoriesList(),
        ],
      ),
    );
  }

  Widget buildCategoriesList(){
    CustomGridView gridView = new CustomGridView(categoryList.length, buildCategoryCard, 4, false, 0.0, ScrollController());
    return categoryList.isNotEmpty ? Container(
      height: MediaQuery.of(context).size.width/1.6,
      child: gridView.buildGridView(),
    ) : Container();
  }

  Widget buildCategoryCard(index){
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: (){
        selectedCategoryIndex = index;
        category = categoryList[index];
        showProgressDialog(true);
        apiGetAnnouncementList(true);
        updateState();
      },
      child: Container(
        height: MediaQuery.of(context).size.width/6,
        width: MediaQuery.of(context).size.width/3.2,
        margin: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            color: selectedCategoryIndex == index ? Color(0xFFF94E0D) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              )
            ]
        ),
        child: Center(
          child: Text(
            categoryList[index],
            style: TextStyle(
                color: selectedCategoryIndex == index ? Colors.white : Color(0xFF7B7580),
                fontSize: 11.0,
                fontWeight: FontWeight.w400
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget thatsmontrealHeading(){
    return Container(
      padding: EdgeInsets.only(top: 50.0,),
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Center(
        child: Text(
          AppLocalizations.of(context).trans('that_mont_billboard'),
          style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget buildOverallList(){
    return ListView(
      padding: EdgeInsets.all(0.0),
      shrinkWrap: false,
      children: [
        announcementList.isNotEmpty && isApiLoaded ? thatsmontrealHeading() : Container(),
        buildSearchBar(),
        Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 7,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  )
                ]
            ),

            child: Column(
              children: [
                SizedBox(
                  height: 40.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).trans('my_billboard'),
                          style: TextStyle(
                              color: Color(0xFFF94E0D),
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      !Utilities.isGuest ? Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFF94E0D).withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: Offset(0, 3), // changes position of shadow
                              )
                            ]
                        ),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreateAnnouncement())).then((value){
                              if(value !=null){
                                showProgressDialog(true);
                                apiGetAnnouncementList(false);
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context).trans('create_new'),
                                style: TextStyle(
                                    color: Color(0xFF787777),
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Image.asset('assets/add_icon.png', width: 15.0,)
                            ],
                          ),
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                buildAnnouncementList(),
              ],
            )),
      ],
    );
  }

  Widget buildAnnouncementList(){
    return announcementList.isEmpty && isApiLoaded ? buildNoAnnouncement() : ListView.builder(
      itemBuilder: buildAnnouncementCard,
      padding: EdgeInsets.all(0.0),
      shrinkWrap: true,
      itemCount: announcementList.length,
      physics: ClampingScrollPhysics(),
    );
  }

  Widget buildNoAnnouncement(){
    return Container(
      height: MediaQuery.of(context).size.height/2 - (MediaQuery.of(context).padding.top+MediaQuery.of(context).padding.bottom+50),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProductCarousel(context, index),
            SizedBox(
              height: 5.0,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      announcementList[index].title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(
                    height: 7.0,
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
                    child: Row(
                      children: [
                        Text(AppLocalizations.of(context).trans('duration')+': ${announcementList[index].duration.toString()} '+AppLocalizations.of(context).trans('days'),
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 11.0,
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Text(
                          dateFormat(announcementList[index].created_at),
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Utilities.isGuest ? Container() : Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
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
                          child: Image.asset('assets/update_icon.png', width: 30.0,),
                        ),
                        SizedBox(
                          width: 7.0,
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: (){
                            openDeleteAnnouncementConfirmation(announcementList[index].id);
                          },
                          child: Image.asset('assets/delete_icon.png', width: 30.0,),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget buildProductCarousel(context, index){
    return Container(
      height: MediaQuery.of(context).size.width/2.5,
      width: MediaQuery.of(context).size.width/2.5,
      color: Color(0xFFF5F5F5),
      child: Stack(
        children: <Widget>[
          Positioned(
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> AnnouncementDetail(announcementList[index].id))).then((value){
                  if(value != null){
                    showProgressDialog(true);
                    apiGetAnnouncementList(false);
                  }
                });
              },
              child: isLoading ?  Container(
                color: Color(0xFFF5F5F5),
                width: MediaQuery.of(context).size.width/2.2,
                height: MediaQuery.of(context).size.width/2.5,
                child: AspectRatio(
                  aspectRatio: 184/131,
                  child: Image.asset('assets/product.png', fit: BoxFit.cover,),
                ),
              ) : CarouselSlider(
                initialPage: 0,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                height: MediaQuery.of(context).size.width/2.5,
                onPageChanged: (index) {
                  currentImageIndex = index;
                  updateState();
                },
                items: announcementList[index].announcement_gallery.map((image) {
                  print(image.path);
                  if(image.path!=null){
                    return productImage(image.path.toString());
                  }else{
                    return productImage("assets/product.png");
                  }
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
                    width: MediaQuery.of(context).size.width/2.5 - 32,
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
        print("alia");
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        color: Color(0xFFF5F5F5),
        width: MediaQuery.of(context).size.width/2.5,
        child: AspectRatio(
          aspectRatio: 184/131,
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: ApiUrl.web_image_url+image.toString(),
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


  void apiGetAnnouncementList(bool isSearch)async {
    announcementList.clear();
    isLoading = true;
    updateState();
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';
    String url;

    if(isSearch){
      if(category == 'All'){
        url = ApiUrl.web_api_url+"api/announcement?keyword=$keyword";
        keyword = '';
        searchController.clear();
      }else{
        url = ApiUrl.web_api_url+"api/announcement?category=$category&keyword=$keyword";
        keyword = '';
        category = 'All';
        searchController.clear();
      }

    }else{
      if(Utilities.isGuest){
        url = ApiUrl.web_api_url+"api/announcement";
      }else{
        url = ApiUrl.web_api_url+"api/user/announcement?user_id=${Utilities.user.user_id}";
      }
    }

    print(url);

    http.get(Uri.parse(url), headers: header).then((response) async{
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
      announcementList = await  mapppedResponse.map((e) => MDAnnouncement.fromJson(e)).toList();
      updateState();
      isLoading = false;
      updateState();
      showProgressDialog(false);
    });
    isLoading = false;
    updateState();
  }


  String dateFormat(String date){
    List<String> newDate = date.split(' ');
    var dateTimeStame = DateTime.parse(date).toUtc().millisecondsSinceEpoch;
    print(dateTimeStame.toString());

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateTimeStame);
    return intl.DateFormat("MMM dd, yyyy").format(dateTime);
//    return newDate[0];
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

}