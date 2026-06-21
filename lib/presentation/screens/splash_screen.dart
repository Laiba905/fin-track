import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/utils/responsive_helper.dart';
import 'dashboard_screen.dart';
import 'main_navigation_holder.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 Seconds ka timer jo automatically agli screen pr le jaye ga
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationHolder()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWeb = ResponsiveHelper.isWebOrDesktop(context);

    return Scaffold(
      body: Center(
        child: Container(
          width: isWeb ? 450 : screenSize.width,
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    width: isWeb ? 160 : (screenSize.width * 0.35),
                    fit: BoxFit.contain,
                  ),
                  // const SizedBox(height: 14),
                  // Text(
                  //   'FinTrack',
                  //   style: TextStyle(
                  //     fontSize: isWeb ? 40 : (screenSize.width * 0.08).clamp(28, 36),
                  //     fontWeight: FontWeight.bold,
                  //     color: Theme.of(context).primaryColor,
                  //     letterSpacing: -1,
                  //   ),
                  // ),
                  // const SizedBox(height: 10),
                  // Text(
                  //   'Smart way to manage your expenses',
                  //   textAlign: TextAlign.center,
                  //   style: TextStyle(
                  //     fontSize: isWeb ? 16 : (screenSize.width * 0.04).clamp(14, 18),
                  //     color: Colors.grey.shade600,
                  //     fontWeight: FontWeight.w500, fontStyle: FontStyle.italic,
                  //   ),
                  // ),
                ],
              )
                  .animate()
                  .fade(duration: 800.ms)
                  .scale(
                    delay: 200.ms,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
              //const SizedBox(height: 20),
              const Spacer(),
              SizedBox(
                width: 100,
                child: LinearProgressIndicator(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.2),
                  color: Theme.of(context).primaryColor,
                  minHeight: 4,
                ).animate().fade(delay: 600.ms, duration: 400.ms),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
