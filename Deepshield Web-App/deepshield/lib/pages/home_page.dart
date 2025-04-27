import 'package:deepshield/pages/upload_video_page.dart';
import 'package:deepshield/widgets/main_hero_widget.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;

  @override
  void initState() {
    super.initState();
    username = html.window.localStorage['username'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Top Navbar Custom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Row(
                children: [
                  Text(
                    'DeepShield',
                    style: TextStyle(
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
                  SizedBox(width: 30),
                  // 🌟 New: Login Button or Username
                  if (username == null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C63FF),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.black87),
                        SizedBox(width: 8),
                        Text(
                          username!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const MainHeroWidget(),
          ],
        ),
      ),
    );
  }
}

// Simple NavItem Widget
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
          foregroundColor: _isHovering ? Color(0xFF6C63FF) : Colors.black54,
        ),
        child: Text(
          widget.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
