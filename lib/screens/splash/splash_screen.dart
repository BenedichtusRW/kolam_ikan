import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Navigate after 3 seconds
    Timer(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[600],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.lightBlue[300]!,
                    Colors.blue[600]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.waves,
                size: 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            // App Name
            Text(
              'KOLAM IKAN',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Smart Fish Pond Management',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 50),
            // Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}