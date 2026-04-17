// pdf_viewer_simple.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewerSimple extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerSimple({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewerSimple> createState() => _PdfViewerSimpleState();
}

class _PdfViewerSimpleState extends State<PdfViewerSimple> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadAndShowPdf();
  }

  Future<void> downloadAndShowPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(response.bodyBytes);
      
      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : localPath != null
              ? SfPdfViewer.file(File(localPath!))
              : Center(child: Text('Failed to load PDF')),
    );
  }
}