import 'package:deepshield/pages/home_page.dart';
import 'package:deepshield/pages/upload_video_page.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// ------- Result Page -------
class ResultPage extends StatefulWidget {
  final Map<String, dynamic> results;
  const ResultPage({super.key, required this.results});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late VideoPlayerController _controller;

  // Sample data
  late int totalFaces;
  late int realFaces;
  late int fakeFaces;
  late double fakePercentage;
  late String verdict;
  late String videoUrl;
  late List<dynamic> faceUrls;

  final ScrollController _scrollController = ScrollController();
  bool _showLeftButton = false;
  bool _showRightButton = true;

  @override
  void initState() {
    super.initState();

    videoUrl = widget.results['video_url'];
    faceUrls = widget.results['face_url'];
    totalFaces = widget.results['total_faces'];
    realFaces = widget.results['real_faces'];
    fakeFaces = widget.results['fake_faces'];
    fakePercentage = widget.results['fake_percentage'];
    verdict = widget.results['verdict'];

    _controller = VideoPlayerController.network(videoUrl);

    // Initialize the controller
    _controller
        .initialize()
        .then((_) {
          // Ensure the widget is still mounted before calling setState
          if (mounted) {
            setState(() {});
          }
        })
        .catchError((error) {
          // Handle initialization errors
          debugPrint("Video player initialization error: $error");
        });

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    setState(() {
      _showLeftButton = currentScroll > 0;
      _showRightButton = currentScroll < maxScroll;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300, // adjust scroll step
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildNavbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 20),
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
                MaterialPageRoute(builder: (context) => UploadVideoPage()),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavbar(), // Navbar stays at full width
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prediction Results',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildStatItem(
                                'Total Faces',
                                totalFaces.toString(),
                              ),
                              _buildStatItem(
                                'Real Faces',
                                realFaces.toString(),
                              ),
                              _buildStatItem(
                                'Fake Faces',
                                fakeFaces.toString(),
                              ),
                              _buildStatItem(
                                'Fake Percentage',
                                '$fakePercentage%',
                              ),
                              _buildStatItem('Verdict', verdict),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        // Video
                        Expanded(
                          flex: 6,
                          child:
                              _controller.value.isInitialized
                                  ? ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 400,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio:
                                          _controller.value.aspectRatio,
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: VideoPlayer(_controller),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: FloatingActionButton(
                                              onPressed: () {
                                                setState(() {
                                                  _controller.value.isPlaying
                                                      ? _controller.pause()
                                                      : _controller.play();
                                                });
                                              },
                                              backgroundColor: const Color(
                                                0xFF6C63FF,
                                              ),
                                              mini: true,
                                              child: Icon(
                                                _controller.value.isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  : Container(
                                    height: 250,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Detected Faces',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      children: [
                        SizedBox(
                          height: 150,
                          child: ListView.separated(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: faceUrls.length,
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  faceUrls[index],
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),

                        if (_showLeftButton)
                          Positioned(
                            left: 10,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: _buildArrowButton(
                                Icons.arrow_back_ios_new,
                                _scrollLeft,
                              ),
                            ),
                          ),
                        // Right button
                        if (_showRightButton)
                          Positioned(
                            right: 10,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: _buildArrowButton(
                                Icons.arrow_forward_ios,
                                _scrollRight,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

Widget _buildStatItem(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        Text(
          "$title: ",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Text(value, style: TextStyle(fontSize: 18)),
      ],
    ),
  );
}

// Simple NavItem (same as HomePage)
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
