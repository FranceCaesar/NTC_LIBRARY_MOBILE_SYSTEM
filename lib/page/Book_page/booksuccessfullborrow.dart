import 'package:flutter/material.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import '../Home_Page/home_page.dart';

class BorrowSuccessPage extends StatelessWidget {
  const BorrowSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 60),

                      // ****** CENTER CONTENT ******
                      Center(
                        child: Column(
                          children: [
                            // Illustration
                            SizedBox(
                              height: 220,
                              child: Image.asset(
                                "images/image_logo5.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Title
                            Text(
                              "Awesome! The book you\nsuccessfully borrowed.",
                              style: AppTypography.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 120),

                      // ****** BOTTOM BUTTONS ******
                      Column(
                        children: [
                          // "Check my library" Button -> Navigates to HomePage with Books tab selected
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to HomePage and set index to 1 (Books Tab)
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomePage(initialIndex: 1), // Pass index 2
                                  ),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: Text(
                                "Check my library",
                                style: AppTypography.textTheme.titleMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // "Go to homepage" Button -> Navigates to HomePage default (Home Tab)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomePage()),
                                  (route) => false,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                side:
                                    const BorderSide(color: AppColors.secondaryText),
                              ),
                              child: Text(
                                "Go to homepage",
                                style: AppTypography.textTheme.titleMedium
                                    ?.copyWith(
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}