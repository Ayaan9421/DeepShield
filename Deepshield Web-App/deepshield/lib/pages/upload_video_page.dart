import 'dart:html' as html;
import 'package:deepshield/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';
import 'dart:convert';

class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({super.key});

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  html.File? _selectedFile;
  String? _errorText;
  bool _isUploading = false;

  void _pickFile() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'video/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final file = uploadInput.files?.first;
      if (file != null) {
        if (file.size > 100 * 1024 * 1024) {
          setState(() {
            _errorText = "File too large! Must be less than 100MB.";
            _selectedFile = null;
          });
        } else {
          setState(() {
            _selectedFile = file;
            _errorText = null;
          });
        }
      }
    });
  }

  Future<void> _uploadVideo() async {
    if (_selectedFile == null) return;

    final token = html.window.localStorage['token'];
    if (token == null) {
      setState(() {
        _errorText = "You are not logged in!";
      });
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final reader = html.FileReader();
    reader.readAsArrayBuffer(_selectedFile!);

    await reader.onLoadEnd.first;

    final formData = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/predict'),
    );

    formData.headers['Authorization'] = 'Bearer $token';

    formData.files.add(
      http.MultipartFile.fromBytes(
        'file',
        reader.result as List<int>,
        filename: _selectedFile!.name,
      ),
    );

    try {
      final streamedResponse = await formData.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Prediction successful: $result');
        // You can navigate or show a success screen here
        Navigator.pushNamed(context, '/results', arguments: result);
      } else {
        print('Prediction failed: ${response.body}');
        setState(() {
          _errorText =
              'Prediction failed: ${jsonDecode(response.body)['detail']}';
        });
      }
    } catch (e) {
      print('Error uploading video: $e');
      setState(() {
        _errorText = 'Error uploading video.';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // your whole normal page content here
                // (you don't need to change your existing page widgets)
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Row(
                    children: [
                      Text(
                        'DeepShield',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      _NavItem(
                        title: 'Home',
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                      ),
                      SizedBox(width: 10),
                      _NavItem(title: 'How It Works', onTap: () {}),
                      SizedBox(width: 10),
                      _NavItem(
                        title: 'Upload Video',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadVideoPage(),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 10),
                      _NavItem(title: 'My Predictions', onTap: () {}),
                      SizedBox(width: 10),
                      _NavItem(title: 'About Us', onTap: () {}),
                      SizedBox(width: 10),
                      _NavItem(title: 'Contact', onTap: () {}),
                      SizedBox(width: 10),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.language, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Text(
                        'Upload Your Video',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _pickFile,
                        child: DottedBorder(
                          color: const Color(0xFF6C63FF),
                          strokeWidth: 2,
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(16),
                          dashPattern: [8, 4],
                          child: Container(
                            width: 400,
                            height: 250,
                            alignment: Alignment.center,
                            child:
                                _selectedFile == null
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.cloud_upload,
                                          size: 60,
                                          color: Color(0xFF6C63FF),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          'Drag & drop your video here\nor click to select',
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '(Max size: 100MB)',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    )
                                    : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          size: 60,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          _selectedFile!.name,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'File ready for upload!',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                      if (_errorText != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          _errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _isUploading ? null : _uploadVideo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Upload Now',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// Reusing _NavItem Widget
class _NavItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  const _NavItem({required this.title, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: TextButton(
        onPressed: widget.onTap,
        style: TextButton.styleFrom(
          foregroundColor:
              _isHovering ? const Color(0xFF6C63FF) : Colors.black54,
        ),
        child: Text(
          widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
