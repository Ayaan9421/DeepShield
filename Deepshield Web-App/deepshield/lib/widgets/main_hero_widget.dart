import 'package:flutter/material.dart';

class MainHeroWidget extends StatelessWidget {
  const MainHeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height * 0.8,
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 48.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LEFT COLUMN
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detect Deepfakes with DeepShield',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'AI-powered detection of manipulated videos, synthetic voices, and altered faces. Stay informed, stay protected.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Upload or Analysis
                      Navigator.pushNamed(context, '/upload');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(MaterialState.hovered)) {
                            return const Color(
                              0xFF7C73FF,
                            ); // Slightly brighter on hover
                          }
                          return const Color(0xFF6C63FF); // Default purple
                        },
                      ),
                      elevation: MaterialStateProperty.resolveWith<double>(
                        (states) =>
                            states.contains(MaterialState.hovered) ? 8.0 : 4.0,
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 18,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Unmask the Truth',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 60),

            // RIGHT COLUMN - IMAGE
            Expanded(
              flex: 2,
              child: Image.asset(
                'assets/images/hero_page_image.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
