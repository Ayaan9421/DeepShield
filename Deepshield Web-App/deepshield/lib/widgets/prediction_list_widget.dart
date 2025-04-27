import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PredictionsListWidget extends StatefulWidget {
  const PredictionsListWidget({super.key});

  @override
  State<PredictionsListWidget> createState() => _PredictionsListWidgetState();
}

class _PredictionsListWidgetState extends State<PredictionsListWidget> {
  List<dynamic> _videos = [];
  bool _isLoading = true;
  String? _errorText;
  String? username;

  @override
  void initState() {
    super.initState();
    username = html.window.localStorage['username'];
    _fetchPredictions();
  }

  Future<void> _fetchPredictions() async {
    final token = html.window.localStorage['token'];
    if (token == null) {
      setState(() {
        _errorText = "You must be logged in to see predictions.";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/videos/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _videos = data['videos'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorText = "Failed to load predictions.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorText = "Error fetching predictions.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorText != null) {
      return Center(child: Text(_errorText!));
    }

    if (_videos.isEmpty) {
      return const Center(child: Text("No predictions yet."));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Past Predictions",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ..._videos.map((video) => _buildPredictionCard(video)).toList(),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(dynamic video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Left info part
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['video_name'] ?? "Unknown Video",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Uploaded: ${video['uploaded_at'] ?? "Unknown"}",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Prediction: ${video['prediction']} (${video['confidence']})",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to full prediction view maybe?
                      // TODO: Implement this
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Get Full Prediction'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Right thumbnail part
            Expanded(
              flex: 2,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                  image:
                      video['thumbnail_url'] != null
                          ? DecorationImage(
                            image: NetworkImage(video['thumbnail_url']),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    video['thumbnail_url'] == null
                        ? const Center(
                          child: Icon(
                            Icons.videocam,
                            size: 40,
                            color: Colors.black45,
                          ),
                        )
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
