// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'dashboard_screen.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Logo Animation (Halka sa bada hona)
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..forward();
//
//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeIn,
//     );
//
//     Timer(Duration(seconds: 40), () {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => DashboardScreen()),
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           // Gradient jo premium look deta hai
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
//           ),
//         ),
//         child: Center(
//           child: FadeTransition(
//             opacity: _animation,
//             child: ScaleTransition(
//               scale: _animation,
//               child: Container(
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Color(0xFFFFD700).withOpacity(0.2), // Halka sa gold glow
//                       blurRadius: 50,
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: Image.asset(
//                   'assets/logo/icon.png',
//                   width: 200,
//                   height: 200,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:async';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse aur Scale animation ka combo
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Ise repeat karenge "Breathing" effect ke liye

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 4 seconds baad next screen (40 seconds bohot zyada tha!)
    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Radial Gradient jo logo ko spotlight deta hai
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1E1E1E), // Center thora light
              Colors.black,      // Corners bilkul dark
            ],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _pulseAnimation, // Logo aahista se pulse karega
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  // Multiple shadows for deeper glow
                  BoxShadow(
                    color: Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: Color(0xFFFFD700).withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/logo/icon.png', // Image 2 wala transparent logo
                width: 220,
                height: 220,
              ),
            ),
          ),
        ),
      ),
    );
  }
}