import 'package:deepshield/pages/login_page.dart';
import 'package:deepshield/pages/register_page.dart';
import 'package:deepshield/pages/results_page.dart';
import 'package:deepshield/pages/upload_video_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUrlStrategy(PathUrlStrategy()); // For removing # from URLs
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepShield',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      debugShowCheckedModeBanner: false,

      // 👇 Set default page
      home: LoginPage(),

      // 👇 All your routes in one place
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/upload': (context) => UploadVideoPage(),
        // '/results': defined below because it needs arguments
      },

      // 👇 Handle routes with arguments separately
      onGenerateRoute: (settings) {
        if (settings.name == '/results') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => ResultPage(results: args),
          );
        }
        // fallback
        return MaterialPageRoute(builder: (_) => LoginPage());
      },
    );
  }
}
