import 'dart:io';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thats_montreal/globals.dart';
class PdfViewer extends StatefulWidget {
  final PDFDocument document;
  PdfViewer(this.document);
  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(Globals.textData['prices_and_services'].toString()??"",), backgroundColor: Colors.black),
        body: PDFViewer(
        document: widget.document,
        zoomSteps: 1,
        progressIndicator: CircularProgressIndicator(),
      )
    );
  }
}
