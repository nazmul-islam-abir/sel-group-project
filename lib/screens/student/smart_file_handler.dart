// Update smart_file_handler.dart - add PPTX support
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'pdf_viewer_simple.dart';

class SmartFileHandler {
  static Future<void> openFile({
    required BuildContext context,
    required String fileUrl,
    required String fileName,
  }) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening file...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Check file type
    final lowerUrl = fileUrl.toLowerCase();
    final lowerName = fileName.toLowerCase();
    
    if (lowerUrl.contains('.pdf') || lowerName.contains('.pdf')) {
      // PDF: Open IN APP
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerSimple(
            pdfUrl: fileUrl,
            title: fileName,
          ),
        ),
      );
    } else if (lowerUrl.contains('.jpg') || lowerUrl.contains('.jpeg') || 
               lowerUrl.contains('.png') || lowerUrl.contains('.gif')) {
      // Image: Open in app
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(fileName)),
            body: Center(
              child: Image.network(fileUrl),
            ),
          ),
        ),
      );
    } else if (lowerUrl.contains('.pptx') || lowerName.contains('.pptx') ||
               lowerUrl.contains('.ppt') || lowerName.contains('.ppt')) {
      // PPTX: Download and open with device app
      await _downloadAndOpenOfficeFile(context, fileUrl, fileName, 'PPT');
    } else if (lowerUrl.contains('.docx') || lowerName.contains('.docx') ||
               lowerUrl.contains('.doc') || lowerName.contains('.doc')) {
      // DOCX: Download and open with device app
      await _downloadAndOpenOfficeFile(context, fileUrl, fileName, 'DOC');
    } else if (lowerUrl.contains('.xlsx') || lowerName.contains('.xlsx') ||
               lowerUrl.contains('.xls') || lowerName.contains('.xls')) {
      // XLSX: Download and open with device app
      await _downloadAndOpenOfficeFile(context, fileUrl, fileName, 'Excel');
    } else {
      // Other files: Open in browser
      try {
        await launchUrl(
          Uri.parse(fileUrl),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot open file")),
        );
      }
    }
  }
  
  /// 📥 Download and open office files (PPTX, DOCX, XLSX)
  static Future<void> _downloadAndOpenOfficeFile(
    BuildContext context, 
    String url, 
    String fileName,
    String fileType
  ) async {
    try {
      // Show downloading message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading $fileType file...'),
          backgroundColor: Colors.blue,
        ),
      );
      
      // Download file
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Get file extension
        String extension = 'file';
        if (url.contains('.')) {
          extension = url.split('.').last;
          if (extension.length > 5) extension = 'file';
        }
        
        // Save to local storage
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.$extension');
        await file.writeAsBytes(response.bodyBytes);
        
        // Open with device's default app
        final result = await OpenFile.open(file.path);
        
        if (result.type != ResultType.done) {
          // If opening fails, try browser
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        throw Exception('Failed to download file');
      }
      
    } catch (e) {
      print("Error opening office file: $e");
      
      // Fallback: Open in browser
      try {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cannot open $fileType file"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}