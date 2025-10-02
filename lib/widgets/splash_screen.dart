import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'package:musice/constants/app_constants.dart';

/// Splash screen with a full-screen blurred background image and a simple loader.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.nextPageBuilder});

  /// Builder for the page to navigate to after the splash delay.
  final WidgetBuilder nextPageBuilder;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Small delay to show the loader, then navigate to the next page
    Future<void>.delayed(kSplashDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: widget.nextPageBuilder),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Solid background fallback
          Container(color: Colors.black),

          // Full-screen blurred background image, adaptive with BoxFit.cover
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Image.asset(
                'lib/assets/bgsplash.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => Container(color: Colors.black),
              ),
            ),
          ),

          // Slight dark overlay to keep content readable on bright images
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.25)),
          ),

          // Centered circular loader
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 112,
                    height: 112,
                    child: CircularProgressIndicator(
                      strokeWidth: 12,
                      valueColor: AlwaysStoppedAnimation<Color>(kIconColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
