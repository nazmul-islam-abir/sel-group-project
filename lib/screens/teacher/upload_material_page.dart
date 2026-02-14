import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../connectors/supabase_connector.dart';

class UploadMaterialPage extends StatefulWidget {
  final Map<String, dynamic> course;
  
  const UploadMaterialPage({super.key, required this.course});

  @override
  State<UploadMaterialPage> createState() => _UploadMaterialPageState();
}

class _UploadMaterialPageState extends State<UploadMaterialPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  String selectedType = 'announcement';
  
  // For web - store file bytes and name
  Uint8List? selectedFileBytes;
  String? fileName;
  bool isUploading = false;

  final List<String> materialTypes = ['announcement', 'assignment', 'file'];

  @override
  Widget build(BuildContext context) {
    final courseCode = widget.course['course_code'] ?? widget.course['code'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload to $courseCode'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course['course_name'] ?? widget.course['name'] ?? 'Course',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Code: $courseCode'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Material Type
            const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: materialTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedType = value!),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Title
            const Text('Title:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Enter title',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter description',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // File upload buttons
            const Text('Attachment:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo),
                    label: const Text('Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            
            // Show selected file
            if (fileName != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      fileName!.toLowerCase().endsWith('.pdf') 
                          ? Icons.picture_as_pdf 
                          : Icons.image,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(fileName!)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() {
                        selectedFileBytes = null;
                        fileName = null;
                      }),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Upload button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isUploading ? null : _uploadMaterial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('UPLOAD', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pick PDF file (works on web and mobile)
  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      
      if (result != null) {
        setState(() {
          // For web, use bytes
          selectedFileBytes = result.files.single.bytes;
          fileName = result.files.single.name;
        });
      }
    } catch (e) {
      _showError('Error picking PDF: $e');
    }
  }

  // Pick Image (works on web and mobile)
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // Read bytes for web
        final bytes = await image.readAsBytes();
        setState(() {
          selectedFileBytes = bytes;
          fileName = image.name;
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  // Upload material
  Future<void> _uploadMaterial() async {
    if (titleController.text.isEmpty) {
      _showError('Please enter a title');
      return;
    }

    setState(() => isUploading = true);

    try {
      final courseCode = widget.course['course_code'] ?? widget.course['code'];
      
      String? fileUrl;
      
      // Upload file to Supabase Storage if a file is selected
      if (selectedFileBytes != null && fileName != null) {
        // Use web upload method
        fileUrl = await SupabaseConnector.uploadFileWeb(
          fileBytes: selectedFileBytes!,
          fileName: fileName!,
          courseCode: courseCode,
        );
      }

      // Save material info to course_materials table
      await SupabaseConnector.uploadCourseMaterial({
        'course_code': courseCode,
        'title': titleController.text,
        'description': descriptionController.text,
        'material_type': selectedType,
        'file_url': fileUrl,
        'file_name': fileName,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      _showError('Upload failed: $e');
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}