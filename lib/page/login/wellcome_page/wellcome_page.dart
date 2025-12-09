import 'package:flutter/material.dart';
// 1. Imported your custom theme files
import 'package:ntc_library/theme/colorpallet.dart'; 
import 'package:ntc_library/theme/text.dart';
import 'login_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {

  late AnimationController logoController;
  late Animation<double> logoScale;
  late Animation<double> logoOpacity;

  late AnimationController titleController;
  late Animation<Offset> titleSlide;

  late AnimationController buttonController;
  late Animation<double> buttonOpacity;

  @override
  void initState() {
    super.initState();

    // LOGO ANIMATION
    logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeOutBack),
    );

    logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeIn),
    );

    // TITLE ANIMATION
    titleController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: titleController, curve: Curves.easeOut),
    );

    // BUTTON ANIMATION
    buttonController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    buttonOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: buttonController, curve: Curves.easeIn),
    );

    // Run animations sequence
    logoController.forward().then((_) {
      titleController.forward().then((_) {
        buttonController.forward();
      });
    });
  }

  @override
  void dispose() {
    logoController.dispose();
    titleController.dispose();
    buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          // 2. Updated Gradient to use AppColors
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.secondaryBackground, // Light grey/blue from your palette
              AppColors.primaryBackground,   // White
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Spacer(),

            // LOGO ANIMATED
            FadeTransition(
              opacity: logoOpacity,
              child: ScaleTransition(
                scale: logoScale,
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: Image.asset(
                    "images/NTC_LOGO.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // TITLE ANIMATED
            SlideTransition(
              position: titleSlide,
              child: Text(
                "NTC LIBRARY",
                style: AppTypography.textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary, // Brand Blue (0xFF0033A0)
                  fontWeight: FontWeight.bold, // Overriding w600 to Bold if desired
                ),
              ),
            ),
            
            const Spacer(),
            
            // BUTTON ANIMATED
            FadeTransition(
              opacity: buttonOpacity,
              child: SizedBox(
                width: screenWidth * 0.45,
                height: screenHeight * 0.065,
                child: ElevatedButton(
                  onPressed: () {
                    // 4. UX Fix: Use pushReplacement so users can't "back" into the splash screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },     
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Brand Blue
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: Text(
                    "Get Started",
                    // 5. Implemented AppTypography
                    // Matches 'titleLarge' (Roboto, size 20, w600)
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      color: Colors.white, // Keep white for contrast on blue button
                    ),
                  ),
                ),
              ),
            ),
           const SizedBox(height: 40),

          ],
        ),
      ),
    );
  }
}