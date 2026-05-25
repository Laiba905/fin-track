import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/utils/responsive_helper.dart';
import 'dashboard_screen.dart';

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
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
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
              Image.asset(
                    'assets/images/logo.png',
                    width: isWeb ? 160 : screenSize.width * 0.55,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 100,
                        color: Theme.of(context).primaryColor,
                      );
                    },
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
