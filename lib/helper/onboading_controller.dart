import 'package:flutter/cupertino.dart';
import 'package:get/state_manager.dart';
import 'package:get/utils.dart';
import 'package:get/get.dart';
import 'package:thats_montreal/helper/onboarding_info.dart';

class Onboarding_controller extends GetxController {
  var selectedpageindex = 0.obs;
  var pagecontroller = PageController();
  bool get isLastpage => selectedpageindex.value == onboarding_pages.length-1;
  forwardAction()
  {
    if(isLastpage)
      {
          //Get.off(Welcome());
      }
    else
      {
        pagecontroller.nextPage(duration: 300.milliseconds, curve: Curves.ease);
      }

  }
  List<Onboarding_info> onboarding_pages = [
    Onboarding_info('assets/onboarding1.jpg', 'Murah dan Mudah', "Emberikan Makanan yang murah dan"*3),
    Onboarding_info('assets/onboarding2.jpg', 'KirimKan Penumpang', "Emberikan Makanan yang murah dan"*3),
    Onboarding_info('assets/onboarding3.jpg', 'Pesanan Cepat', "Emberikan Makanan yang murah dan"*3),
    Onboarding_info('assets/onboarding4.jpg', 'Pesanan Cepat', "Emberikan Makanan yang murah dan"*3),
  ];
}