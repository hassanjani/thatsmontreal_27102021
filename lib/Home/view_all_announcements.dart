import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:thats_montreal/Home/announcement_detail.dart';
import 'package:thats_montreal/api_url.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/model/md_announcement.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class ViewAllAnnouncements extends StatefulWidget {
  @override
  _ViewAllAnnouncementsState createState() => _ViewAllAnnouncementsState();
}

class _ViewAllAnnouncementsState extends State<ViewAllAnnouncements> {
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
              helper.buildStatusBar(),
              helper.buildActionBar(),
              helper.isSearch ? helper.buildSearchBar() : Container(),
              Expanded(
                  child: RefreshIndicator(child: helper.buildAnnouncementList(),
                    onRefresh: refreshAnnouncements,
                  )),
              helper.buildSafeArea(),
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
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isApiLoaded = false;

  List<MDAnnouncement> announcementList=[];
  int currentImageIndex = 0;


  bool isSearch = false;
  String category = '', keyword = '';
  String categoryInitialList = 'All,Event and Activities,Product To Buy,Small Business,Community services,Self Portfolio,Deals & Promotions,Appartments/Hotel/Rental locations,Restauration,Entertainment,Transport,Other';
  List<String> categoryList = [];
  FocusNode keywordNode = FocusNode();

  Helper(this.context, this.showProgressDialog, this.updateState) {
    category = categoryInitialList.split(',')[0];
    categoryList =categoryInitialList.split(',');
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
              Navigator.canPop(context) ? InkWell(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context, true);
                  }
                },
                child: Container(
                  height: 50,
                  padding: EdgeInsets.all(14),
                  child: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ) : Container(width: 15,),
              SizedBox(
                width: 5.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    AppLocalizations.of(context).trans('thats_montreal_billboard'),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              InkWell(
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
              ),
              SizedBox(
                width: 10.0,
              )
            ],
          ),
        ),
      ],
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
              AppLocalizations.of(context).trans('no_thats_montreal_billboard_available'),
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

              },
              child: announcementList[index].announcement_gallery.isEmpty ?  Container(
                color: Color(0xFFF5F5F5),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width/1.5,
                child: AspectRatio(
                  aspectRatio: 184/131,
                  child: Image.asset('assets/product.png', fit: BoxFit.contain,),
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
                          AppLocalizations.of(context).trans('keywprd'),
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


  void apiGetAnnouncementList(bool isSearch) {
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';
    String url = '';

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
        url = ApiUrl.web_api_url+"api/announcement";
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



}