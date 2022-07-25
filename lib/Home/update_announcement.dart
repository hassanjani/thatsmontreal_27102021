import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:place_picker/place_picker.dart';
import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thats_montreal/api_url.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/model/md_announcement.dart';
import 'package:thats_montreal/model/md_announcement_gallery.dart';
import 'package:thats_montreal/utilities.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
class UpdateAnnouncement extends StatefulWidget {
  MDAnnouncement announcementData;
  UpdateAnnouncement(this.announcementData);
  @override
  _UpdateAnnouncementState createState() => _UpdateAnnouncementState();
}

class _UpdateAnnouncementState extends State<UpdateAnnouncement> {
  Helper helper;
  ProgressHUD progressHUD;

  @override
  Widget build(BuildContext context) {
    if(helper == null){
      helper = Helper(context, showProgressDialog, updateState, getImage, widget.announcementData);
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
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              helper.buildStatusBar(),
              helper.buildActionBar(),
              Expanded(
                  child: ListView(
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    children: <Widget>[
                      helper.buildForm(),
                    ],
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

  void getImage(ImageSource source) {
    final picker=ImagePicker();
    picker.getImage(source: source, imageQuality: 80, maxHeight: 720, maxWidth: 1280).then((imageFile) {
      if(imageFile != null){
//        /*if(helper.isForProfileImage){
//          helper.image = file;
//        }
//        else{
//          helper.tradeImage = file;
//        }*/
        cropImage(File(imageFile.path));
      }

    });
  }

  Future cropImage(File pickedImage) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: CropAspectRatio(ratioX: 620, ratioY: 877),
    );
    if(croppedFile != null){
      setState(() {
        MDAnnouncementGallery galleryImage = MDAnnouncementGallery(croppedFile.path);
        helper.imageList.add(galleryImage);
      });
    }
  }
}

class Helper {
  BuildContext context;
  Function showProgressDialog;
  Function updateState;
  Function getImage;
  MDAnnouncement announcementData;

  //Input Field Data

  int contactByPhone = 0;
  int contactByText = 0;
  FocusNode titleNode = FocusNode();
  FocusNode postalCodeNode = FocusNode();
  FocusNode metroStationNode = FocusNode();
  FocusNode productPurLinkNode = FocusNode();
  FocusNode paymentDetailsNode = FocusNode();
  FocusNode languagesNode = FocusNode();
  FocusNode bodyNode = FocusNode();
  FocusNode emailNode = FocusNode();
  FocusNode contactNameNode = FocusNode();
  FocusNode phoneNode = FocusNode();
  FocusNode extensionNode = FocusNode();
  FocusNode streetNode = FocusNode();
  FocusNode crossStreetNode = FocusNode();
  FocusNode cityNode = FocusNode();
  bool isAddressInitiliaze = true;
  LocationResult pickedLocation;
  String address;

  List<MDAnnouncementGallery> imageList = [];
  String title='', google_location='', postal_code='', metro_station='', category='',product_purchase_link='', payment_detail='', duration='', languages='';
  String body='', email='', contact_name='', phone='', extension='', street='', crossStreet='', city='';

  List<String> categoryList = [];
  List<String> durationList = [];
  String categoryListAll = 'Event and Activities,Product To Buy,Small Business,Community services,Self Portfolio,Deals & Promotions,Appartments/Hotel/Rental locations,Restauration,Entertainment,Transport,Other';
  String initialDurationList = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30';

  Helper(this.context, this.showProgressDialog, this.updateState, this.getImage, this.announcementData) {
    category = categoryListAll.split(',')[0];
    categoryList =categoryListAll.split(',');
    duration = initialDurationList.split(',')[0];
    durationList =initialDurationList.split(',');

    title = announcementData.title;
    google_location = announcementData.google_location;
    address = announcementData.google_location;
    postal_code = announcementData.postal_code;
    metro_station = announcementData.metro_station;
    category = announcementData.category;
    product_purchase_link = announcementData.product_purchase_link;
    payment_detail = announcementData.payment_detail;
    duration = announcementData.duration;
    languages = announcementData.languages;
    body = announcementData.body;
    email = announcementData.email;
    contact_name = announcementData.contact_name;
    phone = announcementData.phone;
    extension = announcementData.extension;
    street = announcementData.street;
    crossStreet = announcementData.cross_street;
    city = announcementData.city;
    contactByPhone = int.parse(announcementData.contact_by_phone);
    contactByPhone = int.parse(announcementData.contact_by_phone);
    imageList.addAll(announcementData.announcement_gallery);
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
                width: 2,
              ),
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
              Container(
                child: Text(
                  AppLocalizations.of(context).trans('update_announcement'),
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

  Widget buildForm() {
    return Form(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 12.0,
          ),
          buildTitleField(),
          postalCodeField(),
          metroStationField(),
          buildCategoryDropDownPopUp(),
          productPurLinkField(),
          buildDurationDropDownField(),
          languagesField(),
          paymentDetailField(),
          bodyField(),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                AppLocalizations.of(context).trans('contact_info'),
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          buildEmailField(),
          phoneNumberField(),
          extensionField(),
          contactNameField(),
          buildContactByField(),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                AppLocalizations.of(context).trans('contact_info'),
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          buildAddressField(),
          streetField(),
          crossStreetField(),
          buildCityField(),
          buildPickImage(),
          buildImagesList(),
          buildCreateButton(),
        ],
      ),
    );
  }

  Widget buildTitleField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('title'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '*',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(titleNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(titleNode);
                        },
                        focusNode: titleNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('post_title'),
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
                        controller: fieldController(title),
                        maxLines: 1,
                        onChanged: (value){
                          title = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget buildAddressField(){
    if(!isAddressInitiliaze){
      isAddressInitiliaze = true;
      address = 'Address';
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('specific_location'),
                style:TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '*',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(FocusNode());
              showPlacePicker();
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        Center(
                          child: Text(
                            address,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'regular',
                              color: Color(0xFFA3A3A3),
                            ),
                            maxLines: 1,
                            //overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                  Container(
                    child: Icon(
                      Icons.location_on,
                      size: 15.0,
                      color: Color(0xFFA3A3A3),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),);
  }

  Widget postalCodeField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('postal_code'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '*',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(postalCodeNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(postalCodeNode);
                        },
                        focusNode: postalCodeNode,
                        keyboardType: TextInputType.text,
                        controller: fieldController(postal_code),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('postal_code'),
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
                        maxLines: 1,
                        onChanged: (value){
                          postal_code = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget metroStationField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('metro_station'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '*',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(metroStationNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(metroStationNode);
                        },
                        focusNode: metroStationNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('metro_station'),
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'regular',
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        controller: fieldController(metro_station),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        maxLines: 1,
                        onChanged: (value){
                          metro_station= value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget productPurLinkField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('product_purchase_link'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                AppLocalizations.of(context).trans('or_give_payment_details'),
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(productPurLinkNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(productPurLinkNode);
                        },
                        focusNode: productPurLinkNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('product_purchase_link'),
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'regular',
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        controller: fieldController(product_purchase_link),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        maxLines: 1,
                        onChanged: (value){
                          product_purchase_link= value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget paymentDetailField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('payment_details'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                AppLocalizations.of(context).trans('or_add_link_to_buy_product'),
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(paymentDetailsNode);
            },
            child: Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(paymentDetailsNode);
                        },
                        focusNode: paymentDetailsNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('payment_details'),
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'regular',
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        controller: fieldController(payment_detail),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        maxLines: 4,
                        onChanged: (value){
                          payment_detail= value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget languagesField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('language_speaking'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(languagesNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(languagesNode);
                        },
                        focusNode: languagesNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('language_etc'),
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'regular',
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        controller: fieldController(languages),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        maxLines: 1,
                        onChanged: (value){
                          languages= value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget bodyField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('post_body'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '*',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(bodyNode);
            },
            child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(bodyNode);
                        },
                        focusNode: bodyNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'regular',
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        controller: fieldController(body),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        maxLines: 6,
                        onChanged: (value){
                          body= value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget buildEmailField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('email'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '*',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(emailNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(contactNameNode);
                        },
                        focusNode: emailNode,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('email'),
                          hintStyle: TextStyle(
                            fontSize: 14.0,
                            fontFamily: 'regular',
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        controller: fieldController(email),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        inputFormatters: [
                          new FilteringTextInputFormatter.allow(
                              RegExp("[a-zA-Z0-9-_.@]")),
                        ],
                        maxLines: 1,
                        onChanged: (value){
                          email = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget contactNameField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('contact_name'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '*',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(contactNameNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(contactNameNode);
                        },
                        focusNode: contactNameNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('contact_name'),
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
                        maxLines: 1,
                        controller: fieldController(contact_name),
                        onChanged: (value){
                          contact_name = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget phoneNumberField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('phone')+' #',
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(phoneNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(extensionNode);
                        },
                        focusNode: phoneNode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('phone')+' #',
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
                        maxLines: 1,
                        controller: fieldController(phone),
                        onChanged: (value){
                          phone = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget extensionField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('extension'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(extensionNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(contactNameNode);
                        },
                        focusNode: extensionNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('extension'),
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
                        maxLines: 1,
                        controller: fieldController(extension),
                        onChanged: (value){
                          extension = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget streetField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('street'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(streetNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        focusNode: streetNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('street'),
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
                        maxLines: 1,
                        controller: fieldController(street),
                        onChanged: (value){
                          street = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget crossStreetField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('cross_street'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(crossStreetNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(cityNode);
                        },
                        focusNode: crossStreetNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('cross_street'),
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
                        maxLines: 1,
                        controller: fieldController(crossStreet),
                        onChanged: (value){
                          crossStreet = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget buildCityField(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('city'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              FocusScope.of(context).requestFocus(cityNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value){
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        focusNode: cityNode,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          hintText: AppLocalizations.of(context).trans('city'),
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
                        maxLines: 1,
                        controller: fieldController(city),
                        onChanged: (value){
                          city = value;
                        },
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),);
  }

  Widget buildContactByField(){
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 18, top: 5),
      child: Column(
        children: [SizedBox(
          height: 18.0,
        ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('user_can_contact_by'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              if(contactByPhone ==0){
                contactByPhone = 1;
              }else{
                contactByPhone = 0;
              }
              updateState();
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 4),
                  height: 18,
                  width: 18,
                  child: contactByPhone == 1
                      ?
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.redAccent, width: 1.2),
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.redAccent
                    ),
                    child: Icon(
                      Icons.check,
                      size: 15,
                    ),
                  )
                      :
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF888888), width: 1.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).trans('contact_by_phone'),
                    style: TextStyle(
                        color: Color(0xFF868686),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: (){
              if(contactByText ==0){
                contactByText = 1;
              }else{
                contactByText = 0;
              }
              updateState();
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 4),
                  height: 18,
                  width: 18,
                  child: contactByText == 1
                      ?
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.redAccent, width: 1.2),
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.redAccent
                    ),
                    child: Icon(
                      Icons.check,
                      size: 15,
                    ),
                  )
                      :
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF888888), width: 1.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).trans('contact_by_text'),
                    style: TextStyle(
                        color: Color(0xFF868686),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildCategoryDropDownPopUp() {
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0),
      child: PopupMenuButton<String>(
        offset: Offset(0, 65),
        child: buildCategoryDropDown(),
        padding: EdgeInsets.all(0.0),
        onSelected: (value) {
          category = value;
          updateState();
        },
        itemBuilder: (BuildContext context) {
          return categoryList.map((String value) {
            return PopupMenuItem<String>(
              value: value,
              height: 48,
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

  Widget buildCategoryDropDown(){
    return Column(
      children: [
        SizedBox(
          height: 18.0,
        ),
        Row(
          children: <Widget>[
            Text(
              AppLocalizations.of(context).trans('category'),
              style: TextStyle(
                  color: Color(0xFF3A3A3A),
                  fontSize: 13,
                  fontWeight: FontWeight.bold
              ),
            ),
            Text(
              '',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontFamily: 'bold'),
            )
          ],
        ),
        SizedBox(
          height: 7.0,
        ),
        Container(
          height: 50,
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
                width: 10.0,
              ),
              Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Icon(
                  FontAwesomeIcons.chevronDown,
                  size: 15,
                  color: Colors.black45,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDurationDropDownField() {
    return Container(
      margin: EdgeInsets.only(left: 15.0, right: 15.0),
      child: PopupMenuButton<String>(
        offset: Offset(0, 65),
        child: buildDurationDropDown(),
        padding: EdgeInsets.all(0.0),
        onSelected: (value) {
          duration = value;
          updateState();
        },
        itemBuilder: (BuildContext context) {
          return durationList.map((String value) {
            return PopupMenuItem<String>(
              value: value,
              height: 48,
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

  Widget buildDurationDropDown(){
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          SizedBox(
            height: 18.0,
          ),
          Row(
            children: <Widget>[
              Text(
                AppLocalizations.of(context).trans('duration'),
                style: TextStyle(
                    color: Color(0xFF3A3A3A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontFamily: 'bold'),
              )
            ],
          ),
          SizedBox(
            height: 7.0,
          ),
          Container(
            height: 50,
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
                        duration+" "+AppLocalizations.of(context).trans('days'),
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
                  width: 10.0,
                ),
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(
                    FontAwesomeIcons.chevronDown,
                    size: 15,
                    color: Colors.black45,
                  ),
                )
              ],
            ),
          ),
        ],
      ),);
  }

  Widget buildCreateButton() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 18.0,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(5.0)
          ),
          height: 50.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 15.0),
          child: FlatButton(
            onPressed: () {
              validation();
            },
            child: Text(
              AppLocalizations.of(context).trans('update').toUpperCase(),
              style: TextStyle(
                  color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
        SizedBox(
          height: 20.0 ,
        ),
      ],
    );
  }

  Widget buildPickImage(){
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: (){
        getImage(ImageSource.gallery);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width/7,
        margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(5.0)
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context).trans('add_image'),
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImagesList(){
    return imageList.isEmpty ? Container() : Container(
      height: MediaQuery.of(context).size.width/2.8,
      child: ListView.builder(itemBuilder: buildImageCard,
        itemCount: imageList.length,
        padding: EdgeInsets.all(0.0),
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget buildImageCard(context, index){
    return Container(
      width: MediaQuery.of(context).size.width/2.8,
      height: MediaQuery.of(context).size.width/2.8,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 7.0),
            width: MediaQuery.of(context).size.width/3,
            height: MediaQuery.of(context).size.width/3,
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(5.0)
            ),
            child: imageList[index].id == -1 ? Image.asset(imageList[index].path,fit: BoxFit.cover,):
            FadeInImage.assetNetwork(placeholder: 'assets/product.png', image: ApiUrl.web_image_url+imageList[index].path, fit: BoxFit.cover,),
          ),
          Positioned(
            top: 0.0,
            right: 0.0,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: (){
                if(imageList[index].id == -1){
                  imageList.removeAt(index);
                }else{
                  openDeleteAnnouncementConfirmation(announcementData.announcement_gallery[index].id, index);
                }
                updateState();
              },
              child: Icon(
                FontAwesomeIcons.timesCircle,
                size: 20,
                color: Colors.redAccent,
              ),
            ),
          )
        ],
      ),
    );
  }


  void showPlacePicker() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("AIzaSyChT7iBjqvTKOK4VdtaOa9nZiSqNk38z_I")));

    // Handle the result in your way
    if(result != null){
      pickedLocation = result;
      address = result.formattedAddress;
      updateState();
    }

  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  void validation(){
    FocusScope.of(context).requestFocus(FocusNode());
    if(title.trim().isEmpty){
      showToast(AppLocalizations.of(context).trans('enter_title'));
    }
    else if(postal_code.trim().isEmpty){
      showToast(AppLocalizations.of(context).trans('enter_postal_code'));
    }else if(metro_station.trim().isEmpty){
      showToast(AppLocalizations.of(context).trans('enter_metro_station'));
    }else if(body.trim().isEmpty){
      showToast(AppLocalizations.of(context).trans('enter_post_body'));
    }else if(email.trim().isEmpty){
      showToast(AppLocalizations.of(context).trans('enter_email'));
    }
    else if(!isEmail(email.trim())){
      showToast(AppLocalizations.of(context).trans('enter_valid_email'));
    }else if(contact_name.trim().isEmpty){
      showToast(AppLocalizations.of(context).trans('enter_contact_name'));
    }else if(address == 'Address'){
      showToast(AppLocalizations.of(context).trans('select_address'));
    }else if(imageList.isEmpty){
      showToast(AppLocalizations.of(context).trans('add_image'));
    }else{
      apiUpdateAnnouncement();
    }
  }


  apiUpdateAnnouncement() async {
    showProgressDialog(true);
    Dio dio = new Dio();
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';
    Map<String, dynamic> params = Map();
    params['user_id'] = Utilities.user.user_id.toString();
    params['title'] = title.toString();
    if(pickedLocation == null){
      params['google_location'] = announcementData.google_location;
      params['lat'] = announcementData.lat.toString();
      params['lng'] = announcementData.lng.toString();
    }else{
      params['google_location'] = address.toString();
      params['lat'] = pickedLocation.latLng.latitude.toString();
      params['lng'] = pickedLocation.latLng.longitude.toString();
    }
    params['postal_code'] = postal_code.toString();
    params['metro_station'] = metro_station.toString();
    params['category'] = category.toString();
    params['product_purchase_link'] = product_purchase_link.toString();
    params['payment_detail'] = payment_detail.toString();
    params['duration'] = duration.toString();
    params['languages'] = languages.toString();
    params['body'] = body.toString();
    params['email'] = email.toString();
    params['contact_name'] = contact_name.toString();
    params['phone'] = phone.toString();
    params['extension'] = extension.toString();
    params['contact_by_phone'] = contactByPhone.toString();
    params['contact_by_text'] = contactByText.toString();
    params['street'] = street.toString();
    params['cross_street'] = crossStreet.toString();
    params['city'] = city.toString();
    if(imageList.isNotEmpty){
      List<MultipartFile> uploadImagesList = [];
      for(int i=0; i< imageList.length; i++){
        if(imageList[i].id == -1){
          uploadImagesList.add(await MultipartFile.fromFile(imageList[i].path,
              filename: imageList[i].path.split('/').last,
              contentType: MediaType(
                  mime(imageList[i].path).split('/')[0], mime(imageList[i].path).split('/')[1])));
        }

      }
//      params['images[]'] = await MultipartFile.fromFile(imageList[0].path,
//          filename: imageList[0].path.split('/').last,
//          contentType: MediaType(
//              mime(imageList[0].path).split('/')[0], mime(imageList[0].path).split('/')[1]));
      params['images'] = uploadImagesList;
    }
    FormData formdata = FormData.fromMap(params);

    print('--------------------Form Data---------------------');
    print(params);
    print('--------------------Form Data---------------------');

    dio.post(ApiUrl.web_api_url+"api/user/announcement-update/${announcementData.id}", data: formdata, options: Options(
        method: 'POST', headers: header, responseType: ResponseType.json// or ResponseType.JSON
    )).then((response) {
      showProgressDialog(false);
      if(response.statusCode == 200){
        Map mapppedResponse = response.data;
        print('--------------------Form Data---------------------');
        print(mapppedResponse);
        print('--------------------Form Data---------------------');
        String msg = mapppedResponse['message'];

        if(msg == 'Announcement Updated Successfully'){
          msg = 'Announcement Updated Successfully';
          Navigator.pop(context, true);
        }

        showToast(msg);
      }}).catchError((error) {
      print(error);
      showProgressDialog(false);
    });
  }

  void showToast(String msg){
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }


  TextEditingController fieldController(String data){
    TextEditingController dataController = TextEditingController();
    dataController.text = data;
    dataController.selection = TextSelection.fromPosition(
        TextPosition(offset: data.length));
    return dataController;
  }

  void openDeleteAnnouncementConfirmation(int announcementId, int index) {
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
                            AppLocalizations.of(context).trans('delete_annoucement_image')
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
                                apiAnnouncementImageDelete(announcementId, index);
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

  void apiAnnouncementImageDelete(int announcementId, int index) {
    showProgressDialog(true);
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';

    http.get(Uri.parse(ApiUrl.web_api_url+"api/user/announcement-gallery-delete/$announcementId?user_id=${Utilities.user.user_id}"), headers: header).then((response) {
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
        msg = 'Announcement Image Deleted Successfully';
      }
      imageList.removeAt(index);
        showProgressDialog(false);
      updateState();
    });
  }


}