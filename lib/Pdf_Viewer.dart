import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'helper/locolizations.dart';

import 'package:get/get.dart';

class PdfMapViewer extends StatefulWidget {
  @override
  _PdfMapViewerState createState() => _PdfMapViewerState();
}

class _PdfMapViewerState extends State<PdfMapViewer> {
  String pageName = Get.arguments[0];
  String pdf = Get.arguments[1];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).trans(pageName),), backgroundColor: Colors.black),
      body: SfPdfViewer.asset(
         pdf
      ),
    );
  }
}
