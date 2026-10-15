import 'package:flutter/material.dart';
import 'game/heart_power_up.dart';

/// Optional demo entry point. To run it, temporarily copy this file's content
/// into lib/main.dart, or change the package's entry-point command as noted in README.md.
void main() => runApp(const HeartDemoApp());

class HeartDemoApp extends StatelessWidget {
  const HeartDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF050816),
        appBar: AppBar(
          title: const Text('Neon Energy Core'),
          backgroundColor: const Color(0xFF071426),
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeartPowerUp(),
              SizedBox(height: 24),
              Text(
                'CYBER ENERGY CORE',
                style: TextStyle(
                  color: Color(0xFF39FF14),
                  fontSize: 16,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'PARAMETRIC ANIMATION',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
