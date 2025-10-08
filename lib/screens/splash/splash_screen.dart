import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../utils/routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fishController;
  late AnimationController _bubbleController;
  late AnimationController _logoController;
  late Animation<double> _fishAnimation;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation controllers
    _fishController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _bubbleController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    // Animations
    _fishAnimation = CurvedAnimation(
      parent: _fishController,
      curve: Curves.easeInOut,
    );
    
    _bubbleAnimation = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeInOut,
    );
    
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    // Start animations
    _startAnimations();
    
    // Navigate after splash
    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, Routes.login);
    });
  }

  void _startAnimations() {
    _logoController.forward();
    
    Timer(Duration(milliseconds: 500), () {
      _bubbleController.repeat();
    });
    
    Timer(Duration(milliseconds: 800), () {
      _fishController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _fishController.dispose();
    _bubbleController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[300]!,
              Colors.blue[500]!,
              Colors.blue[700]!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background bubbles
            ...List.generate(8, (index) => _buildBubble(index)),
            
            // Water waves effect
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _bubbleAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(double.infinity, 100),
                    painter: WavePainter(_bubbleAnimation.value),
                  );
                },
              ),
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animation
                  AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoAnimation.value,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Kolam ikan container
                              Container(
                                width: 80,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: Colors.blue[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Swimming fish
                                    AnimatedBuilder(
                                      animation: _fishAnimation,
                                      builder: (context, child) {
                                        return Positioned(
                                          left: 10 + (50 * _fishAnimation.value),
                                          top: 15,
                                          child: Transform.scale(
                                            scaleX: _fishAnimation.value > 0.5 ? -1 : 1,
                                            child: Container(
                                              width: 10,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.orange[400],
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  bottomLeft: Radius.circular(8),
                                                  topRight: Radius.circular(4),
                                                  bottomRight: Radius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                'KOLAM IKAN',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 30),
                  
                  // App title
                  AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              'Kolam Ikan Monitor',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Smart Aquaculture Monitoring',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Loading indicator
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _bubbleAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoAnimation.value,
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Memuat...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(int index) {
    final random = Random();
    final size = 20.0 + random.nextDouble() * 30;
    final left = random.nextDouble() * 400;
    final animationDelay = random.nextDouble() * 2;
    
    return AnimatedBuilder(
      animation: _bubbleAnimation,
      builder: (context, child) {
        final progress = (_bubbleAnimation.value + animationDelay) % 1.0;
        return Positioned(
          left: left,
          bottom: -size + (MediaQuery.of(context).size.height * progress),
          child: Opacity(
            opacity: 1.0 - progress,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  
  WavePainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 2;
    
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height - waveHeight + 
          sin((x / waveLength + animationValue * 2) * 2 * pi) * waveHeight;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}