import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:place_picker/place_picker.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/model/md_user.dart';

import '../api_url.dart';
import '../utilities.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  ProgressHUD progressHUD;
  Helper helper;
  @override
  Widget build(BuildContext context) {
    if (helper == null) {
      helper = Helper(context, showProgressDialog, populateData, getImage,
          genderRadioListener);
      progressHUD = new ProgressHUD(
        backgroundColor: Colors.black12,
        color: Theme.of(context).accentColor, //Colors.white,
        containerColor: Colors.transparent, //Color(0xFF591758),
        borderRadius: 5.0,
        text:
            '', //Utilities.language == 'en' ? Utilities.pleaseWaitEn : Utilities.pleaseWaitAr,
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
                  padding: EdgeInsets.symmetric(vertical: 30),
                  children: <Widget>[
                    helper.buildProfileImage(),
                    helper.buildForm(),
                    helper.buildSaveButton(),
                  ],
                ),
              ),
              helper.buildSafeArea(),
            ],
          ),
          progressHUD
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

  void populateData(int which) {
    setState(() {
      if (which == 0) {
        Utilities.user = Utilities.user;
      }
    });
  }

  void getImage(ImageSource source) {
    final picker = ImagePicker();
    picker
        .getImage(
            source: source, imageQuality: 80, maxHeight: 720, maxWidth: 1280)
        .then((file) {
      if (file != null) {
//        /*if(helper.isForProfileImage){
//          helper.image = file;
//        }
//        else{
//          helper.tradeImage = file;
//        }*/
        cropImage(File(file.path));
      }
    });
  }

  Future cropImage(File pickedImage) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: helper.isForProfileImage
          ? CropAspectRatio(ratioX: 262, ratioY: 262)
          : CropAspectRatio(ratioX: 620, ratioY: 877),
    );
    if (croppedFile != null) {
      setState(() {
        if (helper.isForProfileImage) {
          helper.image = croppedFile;
        } else {
          helper.tradeImage = croppedFile;
        }
      });
      helper.imageFileName = croppedFile.path;
      setState(() {});
    }
  }

  void genderRadioListener(int value) {
    setState(() {
      helper.genderRadioGroupValue = value;
    });
  }
}

class Helper {
  BuildContext context;
  Function showProgressDialog, populateData, getImage, genderRadioListener;
  File image;
  File tradeImage;

  String name = '', email = '', imageFileName = '', tradeFileImageName = '';
  String imagePath = '';
  LocationResult pickedLocation;

  FocusNode firstNameNode = FocusNode();
  FocusNode lastNameNode = FocusNode();
  FocusNode emailNode = FocusNode();
  FocusNode phoneNode = FocusNode();

  int genderRadioGroupValue = -1;
  bool isForProfileImage = true;

  SharedPreferences preferences;

  Helper(this.context, this.showProgressDialog, this.populateData,
      this.getImage, this.genderRadioListener) {
    initPreferences();

    name = Utilities.user.name;
    email = Utilities.user.email;
  }

  initPreferences() async {
    preferences = await SharedPreferences.getInstance();
  }

  Widget buildStatusBar() {
    return Container(
      height: MediaQuery.of(context).padding.top,
      color: Color(0xFF222222),
    );
  }

  Widget buildSafeArea() {
    return Container(
      height: MediaQuery.of(context).padding.bottom,
      color: Color(0xFF222222),
    );
  }

  Widget buildActionBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF151515),
          ),
          height: 55.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 2,
              ),
              Navigator.canPop(context)
                  ? InkWell(
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
                    )
                  : Container(
                      width: 15,
                    ),
              Expanded(
                child: Container(
                  child: Text(
                    AppLocalizations.of(context).trans('edit_profile'),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                width: 5.0,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProfileImage() {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              child: Container(
                height: 130.0,
                width: 130.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(65.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(65.0),
                  child: isLoadFromUrlOrFromFile(),
                ),
              ),
            ),
            Positioned(
              bottom: 1.0,
              right: Utilities.language == 'en' ? 15.0 : null,
              left: Utilities.language == 'en' ? null : 15.0,
              child: GestureDetector(
                onTap: () {
                  isForProfileImage = true;
                  openGalleryCameraPickDialog();
                },
                child: Container(
                  padding: EdgeInsets.all(9),
                  height: 32.0,
                  width: 32.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Color(0xFFFFD700),
                  ),
                  child: Image.asset('assets/update_icon.png',
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 30.0,
        ),
      ],
    );
  }

  Widget buildAddImageBox() {
    return InkWell(
      onTap: () {
        isForProfileImage = false;
        openGalleryCameraPickDialog();
      },
      child: Container(
        height: 80,
        width: 100,
        //margin: EdgeInsets.only(top: 20.0,),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Color(0xFFEEEEEE), width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/add_icon.png',
              height: 20,
              width: 20,
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              AppLocalizations.of(context).trans('add_image'),
              style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 11,
                  fontFamily: 'regular'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildForm() {
    return Form(
      child: Column(
        children: <Widget>[
//          SizedBox(
//            height: Utilities.user.role.title.toLowerCase() == 'buyer' ? 0.0 :  30.0,
//          ),
          buildFirstLastName(),
          buildEmailField(),
        ],
      ),
    );
  }

  Widget buildFirstLastName() {
    TextEditingController firstNameController = TextEditingController();
    firstNameController.text = name;
    firstNameController.selection =
        TextSelection.fromPosition(TextPosition(offset: name.length));
    TextEditingController lastNameController = TextEditingController();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 7.0,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    FocusScope.of(context).requestFocus(firstNameNode);
                  },
                  child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border:
                            Border.all(color: Color(0xFF787777), width: 1.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              onSubmitted: (value) {
                                FocusScope.of(context)
                                    .requestFocus(lastNameNode);
                              },
                              focusNode: firstNameNode,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(0),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                hintText:
                                    AppLocalizations.of(context).trans('name'),
                                hintStyle: TextStyle(
                                  fontSize: 16.0,
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
                              onChanged: (value) {
                                name = value;
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(30),
                                FilteringTextInputFormatter.allow(
                                    RegExp("[a-z A-Z.]")),
                              ],
                              controller: firstNameController,
                            ),
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmailField() {
    TextEditingController emailController = TextEditingController();
    emailController.text = email;
    emailController.selection =
        TextSelection.fromPosition(TextPosition(offset: email.length));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 18.0,
          ),
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(emailNode);
            },
            child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Color(0xFF787777), width: 1.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (value) {
                          FocusScope.of(context).requestFocus(phoneNode);
                        },
                        focusNode: emailNode,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          hintText:
                              AppLocalizations.of(context).trans('email_hint'),
                          hintStyle: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'regular',
                            color: Color(0xFFA3A3A3),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: 'regular',
                          color: Color(0xFF666666),
                        ),
                        maxLines: 1,
                        onChanged: (value) {
                          email = value;
                        },
                        enabled: false,
                        inputFormatters: [
                          new FilteringTextInputFormatter.allow(
                              RegExp("[a-zA-Z0-9-_.@]")),
                        ],
                        controller: emailController,
                      ),
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }

  Widget buildSaveButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 23.0,
        ),
        Container(
          decoration: BoxDecoration(
              color: Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(30.0)),
          height: 60.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 15.0),
          child: FlatButton(
            onPressed: () {
              apiUpdateProfile();
            },
            child: Text(
              AppLocalizations.of(context).trans('update').toUpperCase(),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w900),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
          ),
        ),
      ],
    );
  }

  void validation() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (name.trim().isEmpty) {
      showToast(AppLocalizations.of(context).trans('enter_first_name'));
    } else {
      apiUpdateProfile();
    }
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  void showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget isLoadFromUrlOrFromFile() {
    if (image == null) {
      return Container(
        color: Colors.grey[300],
        child: FadeInImage.assetNetwork(
            placeholder: 'assets/user_icon.png',
            image: ApiUrl.user_image_url + Utilities.user.image,
            fit: BoxFit.contain),
      );
    } else {
      return Image.file(
        image,
        fit: BoxFit.contain,
      );
    }
  }

  void openGalleryCameraPickDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          type: MaterialType.transparency,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.pop(context);
            },
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 15.0),
                child: Center(
                  child: Container(
                    height: 145,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0)),
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          child: Text(
                            AppLocalizations.of(context).trans('select'),
                            style: TextStyle(
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
                            AppLocalizations.of(context)
                                .trans('select_the_source'),
                            style: TextStyle(
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
                              onTap: () {
                                Navigator.pop(context);
                                getImage(ImageSource.camera);
                              },
                              child: Container(
                                height: 32,
                                width: 105,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .trans('camera'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontFamily: 'medium',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                getImage(ImageSource.gallery);
                              },
                              child: Container(
                                height: 32,
                                width: 105,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Color(0xFFFFD700),
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .trans('gallery'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontFamily: 'medium',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  Future<void> apiUpdateProfile() async {
    showProgressDialog(true);
    Dio dio = new Dio();
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';
    Map<String, dynamic> params = Map();
    params['user_id'] = Utilities.user.user_id.toString();
    params['name'] = name.toString();
    params['email'] = email.toString();
    if (isForProfileImage) {
      ContentType contentType = ContentType(
          mime(image.path).split('/')[0], mime(image.path).split('/')[1]);
      if (image != null) {
//        formdata.add("image", UploadFileInfo(image, image.path, contentType: contentType));
        params['image'] = await MultipartFile.fromFile(image.path,
            filename: image.path.split('/').last,
            contentType: MediaType(mime(image.path).split('/')[0],
                mime(image.path).split('/')[1]));
      }
    }

    FormData formdata = FormData.fromMap(params);

    print(params);

    dio
        .post(ApiUrl.web_api_url + "api/update_profile",
            data: formdata,
            options: Options(
                method: 'POST',
                headers: header,
                responseType: ResponseType.json // or ResponseType.JSON
                ))
        .then((response) {
      Map mappedResponse = response.data;
      print('--------------------Form Data---------------------');
      print(response.data);
      print('--------------------Form Data---------------------');
      if (mappedResponse['status']) {
        apiGetProfile();
//          populateData(0);
        showToast(
            AppLocalizations.of(context).trans('profile_updated_successfully'));
      }
    }).catchError((error) {
      print(error);
      showProgressDialog(false);
    });
  }

  void apiGetProfile() {
    Map<String, String> header = Map();
    header['Accept'] = 'application/json';

    http
        .get(
            Uri.parse(ApiUrl.web_api_url +
                'api/user_profile/${Utilities.user.user_id}'),
            headers: header)
        .then((response) {
      Map mapppedResponse = jsonDecode(response.body);
      print('--------------------Profile Data---------------------');
      print(mapppedResponse);
      print('--------------------Profile Data---------------------');
      if (mapppedResponse['status']) {
        Utilities.user = MDUser.fromJson(mapppedResponse['data']);
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: 'Error',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      showProgressDialog(false);
    });
  }
}
