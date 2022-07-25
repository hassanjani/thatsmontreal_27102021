import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:thats_montreal/Home/login.dart';
import 'package:thats_montreal/globals.dart';
import 'package:thats_montreal/helper/locolizations.dart';
import 'package:thats_montreal/helper/onboading_controller.dart';
import 'package:thats_montreal/utilities.dart';
class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final controller = Onboarding_controller();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              itemCount: controller.onboarding_pages.length,
              onPageChanged: controller.selectedpageindex,
                controller: controller.pagecontroller,
                itemBuilder: (context, index){
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(controller.onboarding_pages[index].imageAsset),
                        fit: BoxFit.fill,
                      ),
                      color: Colors.white,
                    ),
                  );
                }
            ),
               Obx(() {
                   return !controller.isLastpage?Positioned(
                     bottom: 50,
                     left: 25,
                     child: InkWell(
                       onTap: (){
                         controller.selectedpageindex.value = controller.onboarding_pages.length-1;
                         controller.pagecontroller.animateToPage(controller.onboarding_pages.length-1, duration: 300.milliseconds, curve: Curves.ease);
                       },
                       child: Text(
                         "Skip",
                         style: TextStyle(
                           color: Colors.white,
                           fontSize: 15,
                           fontWeight: FontWeight.w400,
                           fontFamily: 'medium',
                       ),
                       ),
                     ),
                   ):Container();
                 }
               ),
            Obx(() {
              return controller.selectedpageindex.value==0?Positioned(
                bottom: 300,
                left: 25,
                child: Image.asset(
                  "assets/logo.png",
                  scale: 8,
                ),
              ):Container();
            }
            ),
            Obx(() {
                return Container(
                  alignment: !controller.isLastpage?Alignment.bottomLeft:Alignment.bottomCenter,
                  margin:  !controller.isLastpage?EdgeInsets.only(bottom: 140, left: 25):EdgeInsets.only(bottom: 80),
                    child: Row(
                      mainAxisAlignment: !controller.isLastpage?MainAxisAlignment.start:MainAxisAlignment.center,
                      children: List.generate(
                          controller.onboarding_pages.length, (index) => Obx(() {
                          return Container(
                            margin: EdgeInsets.all(5),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: controller.selectedpageindex.value==index?Colors.white:Colors.transparent,
                               border: Border.all(color: Colors.white),
                               shape: BoxShape.circle,
                            ),

                          );
                        }
                      )),
                    ),
                  );
              }
            ),
            Obx (() {
                return !controller.isLastpage?Positioned(
                  bottom: 30,
                  right: 20,
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Color(0xffFCE860)
                      ),
                    ),
                    padding: EdgeInsets.all(1.5),
                    child: RaisedButton(
                      elevation: 5,
                      splashColor: Colors.white, onPressed: controller.forwardAction,
                      color: Color(0xffF94E0D),
                      padding: EdgeInsets.all(0),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 30,
                      )
                    ),
                  ),
                ):Container();
              }
            ),
            Obx(() {
                return controller.isLastpage?Positioned(
                  bottom: 150,
                  left: MediaQuery.of(context).size.width*0.1,
                  right: MediaQuery.of(context).size.width*0.1,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    height: 60.0,
                    width: MediaQuery.of(context).size.width*0.8,
                    child: FlatButton(
                      onPressed: () async{
                        await getLanguage();
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
                  ),
                ):Container();
              }
            )
           // Positioned(
           //   bottom: 20,
           //   right: 20,
           //   child: SizedBox(
           //     height: 70,
           //     width: 70,
           //     child: Obx(
           //             () {
           //         return controller.isLastpage?FloatingActionButton(
           //            elevation: 5,
           //           splashColor: Colors.grey,
           //           onPressed:(){
           //              Get.to(Welcome());
           //           },
           //           backgroundColor: Theme.of(context).primaryColor,
           //           child:Text("Get Start", textAlign: TextAlign.center,style: TextStyle(fontSize: 10),),
           //            ):Container();
           //       }
           //     ),
           //   ),
           // ),
          ],
        ),
      ),
    );
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
}
