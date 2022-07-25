import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thats_montreal/Home/update_announcement.dart';
import 'package:thats_montreal/api_url.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/model/md_announcement.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:thats_montreal/utilities.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong/latlong.dart';
import 'package:readmore/readmore.dart';

class AnnouncementDetail extends StatefulWidget {
  dynamic id;
  AnnouncementDetail(this.id);
  @override
  _AnnouncementDetailState createState() => _AnnouncementDetailState();
}

class _AnnouncementDetailState extends State<AnnouncementDetail> {
  Helper helper;
  ProgressHUD progressHUD;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if(helper == null){
      helper = Helper(context, showProgressDialog, updateState, widget.id);
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
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              helper.buildStatusBar(),
              Expanded(
                  child: helper.announcementDetail == null ? Container() : ListView(
                    padding: EdgeInsets.all(0.0),
                    physics: ClampingScrollPhysics(),
                    children: [
                      helper.buildProductCarousel(),
                      SizedBox(
                        height: 10,
                      ),
                      helper.buildPostDescription(),
                      helper.buildProductDetailAndPayment(),
                      helper.buildContactDetails(),
//                      helper.titleHeading(),
//                      helper.buildTimeAndCategory(),
//                      helper.buildPostDetail(),
                      helper.addressHeading(),
                      helper.buildMapView(),
                      helper.addressdetailBody(),
                    ],
                  )
              ),
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
  bool isApiLoaded = false;
  dynamic id;

  MDAnnouncement announcementDetail;

  int currentImageIndex = 0;

  Helper(this.context, this.showProgressDialog, this.updateState, this.id) {
    print(id);
    apiGetAnnouncementDetail();
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
              Container(
                child: Text(
                  AppLocalizations.of(context).trans('announcements_detail'),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget titleHeading(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Text(
        announcementDetail.title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget buildTimeAndCategory(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0,vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(AppLocalizations.of(context).trans('posted')+' : ',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12.0,
                ),
              ),
              Text(
                dateFormat(announcementDetail.created_at),
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            children: [
              Text(AppLocalizations.of(context).trans('updated')+' : ',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12.0,
                ),
              ),
              Text(
                dateFormat(announcementDetail.updated_at),
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12.0,
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Text(
                announcementDetail.category,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12.0,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildProductCarousel(){
    return Container(
//      margin: EdgeInsets.symmetric(horizontal: 15.0),
      height: MediaQuery.of(context).size.width*1.2,
      color: Color(0xFFF5F5F5),
      child: Stack(
        children: <Widget>[
          Positioned(
            child: InkWell(
              onTap: () {

              },
              child: announcementDetail.announcement_gallery.isEmpty ?  Container(
                color: Color(0xFFF5F5F5),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: AspectRatio(
                  aspectRatio: 184/131,
                  child: Image.asset('assets/product.png', fit: BoxFit.cover,),
                ),
              ) : CarouselSlider(
                initialPage: 0,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                height: MediaQuery.of(context).size.width/1.2,
                onPageChanged: (index) {
                  currentImageIndex = index;
                  updateState();
                },
                items: announcementDetail.announcement_gallery.map((image) {
                  return productImage(image.path);
                }).toList(),
              ),
            ),
          ),
          Positioned(
            top: 25.0,
            left: 15.0,
            child: Container(
              width: MediaQuery.of(context).size.width-32,
              height: 30.0,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context, true);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF151515),
                        borderRadius: BorderRadius.circular(5.0)
                      ),
                      padding: EdgeInsets.all(7.0),
                      child: Image.asset('assets/back_icon.png', fit: BoxFit.contain, width: 15.0,),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  !Utilities.isGuest && Utilities.user.user_id.toString() != announcementDetail.user_id.toString() ? Container() : InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> UpdateAnnouncement(announcementDetail))).then((value){
                        if(value != null){
                          showProgressDialog(true);
                          apiGetAnnouncementDetail();
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0)
                      ),
                      padding: EdgeInsets.all(4.0),
                      child: Image.asset('assets/update_icon.png', fit: BoxFit.contain, width: 20.0,),
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  !Utilities.isGuest && Utilities.user.user_id.toString() != announcementDetail.user_id.toString() ? Container() : InkWell(
                    onTap: (){
                      openDeleteAnnouncementConfirmation(announcementDetail.id);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0)
                      ),
                      padding: EdgeInsets.all(4.0),
                      child: Image.asset('assets/delete_icon.png', fit: BoxFit.contain, width: 20.0,),
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20.0,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05, right: MediaQuery.of(context).size.width*0.05, top: 5.0, bottom: 65),
              decoration: BoxDecoration(
                color: Color(0xFF151515),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        height: 25,
                        //width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            itemCount: announcementDetail.announcement_gallery.length,
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
                                              : Color(0xFFF94E0D),
                                          width: 1.5)),
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width*0.75,
                        child: Text(
                            announcementDetail.title.toString(),
                            style: TextStyle(
                              color: Color(0xFFF4D500),
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: (){

                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0)
                          ),
                          padding: EdgeInsets.all(5.0),
                          child: Image.asset('assets/share_icon.png', width: 15,),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    announcementDetail.category.toString(),
                    style: TextStyle(
                      color: Color(0xFFA4A0A0),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),


            ),
          ),
          Positioned(
            bottom: 3.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 25.0, right: 25.0,top: 25.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0))
              ),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context).trans('posted')+" : ",
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    dateFormat(announcementDetail.created_at),
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 14.0,
                    ),
                  ),
                  Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppLocalizations.of(context).trans('updated')+" : ",
                        style: TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(
                        height: 3.0,
                      ),
                      Text(
                        dateFormat(announcementDetail.updated_at),
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 14.0,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
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
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: 184/131,
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: ApiUrl.web_image_url+image,
//            height: MediaQuery.of(context).size.width / 1.2,
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

  Widget buildPostDescription(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 2.0),
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 20.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).trans('description'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          ReadMoreText(
            announcementDetail.body.toString(),
            trimLines: 2,
            colorClickableText: Colors.pink,
            trimMode: TrimMode.Line,
            trimCollapsedText: AppLocalizations.of(context).trans('read_more'),
            trimExpandedText: AppLocalizations.of(context).trans('show_less'),
            style: TextStyle(
              color: Color(0xFFA4A0A0),
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              height: 1.3
            ),
            moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFA4A0A0),),
          )
        ],
      ),
    );
  }

  Widget buildProductDetailAndPayment(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 30.0),
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 20.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).trans('product_detail'),
            style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              Text(
                  AppLocalizations.of(context).trans('purchase_link')+' : ',
                  style: TextStyle(
                    color: Color(0xFF787777),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  )
              ),
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: (){
                    launchURL(announcementDetail.product_purchase_link);
                  },
                  child: Container(
                    child: Text(
                      announcementDetail.product_purchase_link,
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          Text(
            AppLocalizations.of(context).trans('payment_details'),
            style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
          announcementDetail.payment_detail.toString(),
              style: TextStyle(
                color: Color(0xFF787777),
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              )
          )
        ],
      ),
    );
  }

  Widget buildContactDetails(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0,),
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 20.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).trans('contact_details'),
            style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: [
              Text(
                  AppLocalizations.of(context).trans('email')+' : ',
                  style: TextStyle(
                    color: Color(0xFF787777),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  )
              ),
              Expanded(
                child: Text(
                    announcementDetail.email.toString(),
                    style: TextStyle(
                      color: Color(0xFF787777),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    )
                ),
              )
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: [
              Text(
                  AppLocalizations.of(context).trans('name')+' : ',
                  style: TextStyle(
                    color: Color(0xFF787777),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  )
              ),
              Expanded(
                child: Text(
                    announcementDetail.contact_name.toString(),
                    style: TextStyle(
                      color: Color(0xFF787777),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    )
                ),
              )
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: [
              Text(
                  AppLocalizations.of(context).trans('phone')+' : ',
                  style: TextStyle(
                    color: Color(0xFF787777),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  )
              ),
              Expanded(
                child: Text(
                    announcementDetail.phone.toString(),
                    style: TextStyle(
                      color: Color(0xFF787777),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    )
                ),
              )
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: [
              Text(
                  AppLocalizations.of(context).trans('languages')+' : ',
                  style: TextStyle(
                    color: Color(0xFF787777),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  )
              ),
              Expanded(
                child: Text(
                    announcementDetail.languages.toString(),
                    style: TextStyle(
                      color: Color(0xFF787777),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    )
                ),
              )
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
          announcementDetail.contact_by_phone == '1' ? Text(
            '- '+AppLocalizations.of(context).trans('contact_by_phone'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.bold
            ),
          ) : Container(),
          SizedBox(
            height: 8.0,
          ),
          announcementDetail.contact_by_text == '1' ? Text(
            '- '+AppLocalizations.of(context).trans('contact_by_text'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.bold
            ),
          ) : Container(),
          SizedBox(
            height: 8.0,
          ),
        ],
      ),
    );
  }


  Widget addressHeading(){
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 35.0, bottom: 10.0),
      child: Text(
        announcementDetail.google_location,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Widget buildMapView(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0,vertical: 15.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width/1.2,
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(double.parse(announcementDetail.lat), double.parse(announcementDetail.lng)),
          zoom: 14.0,
        ),
        layers: [
          new TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']
          ),
          new MarkerLayerOptions(
            markers: [
              new Marker(
                width: 35.0,
                height: 35.0,
                point: LatLng(double.parse(announcementDetail.lat), double.parse(announcementDetail.lng)),
                builder: (ctx) =>
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: (){
                    openMapConfirmation(double.parse(announcementDetail.lat), double.parse(announcementDetail.lng));
                  },
                  child: new Container(
                    child: Image.asset('assets/map_icon.png'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget addressdetailBody(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                  AppLocalizations.of(context).trans('metro_station')+': ',
                  style: TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  )
              ),
              Expanded(
                child: Container(
                  child: Text(
                    announcementDetail.metro_station,
                    style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 15.0,
                        fontWeight: FontWeight.w300
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            children: [
              Text(
                  AppLocalizations.of(context).trans('street')+' : ',
                  style: TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  )
              ),
              Expanded(
                child: Container(
                  child: Text(
                    announcementDetail.street,
                    style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            children: [
              Text(
                  AppLocalizations.of(context).trans('cross_street')+' : ',
                  style: TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  )
              ),
              Expanded(
                child: Container(
                  child: Text(
                    announcementDetail.cross_street,
                    style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 15.0,
                        fontWeight: FontWeight.w300
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            children: [
              Text(
                  AppLocalizations.of(context).trans('city')+' : ',
                  style: TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  )
              ),
              Expanded(
                child: Container(
                  child: Text(
                    announcementDetail.city,
                    style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 15.0,
                        fontWeight: FontWeight.w300
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
        ],
      ),
    );
  }

  void apiGetAnnouncementDetail() {
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';

    String url;
    if(Utilities.isGuest){
      url = ApiUrl.web_api_url+"api/announcement/$id";
    }else{
      url = ApiUrl.web_api_url+"api/announcement/$id?user_id=${Utilities.user.user_id}";
    }


    http.get(Uri.parse(url), headers: header).then((response) {
      isApiLoaded = true;
      Map mappedResponse = jsonDecode(response.body);


      print('----------------Read Notification ID------------------');
      print(mappedResponse.toString());
      print('----------------Read Notification ID------------------');

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

//      announcementList = (mapppedResponse as List).map((e) => MDAnnouncement.fromJson(e)).toList();
      announcementDetail = MDAnnouncement.fromJson(mappedResponse);
      updateState();
      showProgressDialog(false);
    });
  }


  String dateFormat(String date){
    List<String> newDate = date.split(' ');
    print(date);
    var dateTimeStame = DateTime.parse(date).toUtc().millisecondsSinceEpoch;

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateTimeStame);
    return intl.DateFormat("MMM dd, yyyy").format(dateTime);
//    return newDate[0];
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  void openMapConfirmation(double latitude, double longitude) {
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
                          child: Text(AppLocalizations.of(context).trans('confirmation'), style: TextStyle(
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
                          child: Text(AppLocalizations.of(context).trans('do_you_want_to_open_map'), style: TextStyle(
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
                                openMap(latitude, longitude);
                              },
                              child: Container(
                                height: 32,
                                width: 105,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.circular(20.0)
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
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(color: Colors.black)
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
        Navigator.pop(context, true);
      }else{
        showProgressDialog(false);
      }
      updateState();
    });
  }


}