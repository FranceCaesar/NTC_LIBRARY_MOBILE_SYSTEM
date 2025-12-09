import 'package:flutter/material.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import '../Home_Page/home_page.dart';

class ReturnSuccessPage extends StatelessWidget {
  const ReturnSuccessPage({super.key});

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
                                "images/image_logo5.png", // Reusing the success image
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Title
                            Text(
                              "Awesome! The book was\nsuccessfully returned.",
                              style: AppTypography.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Thank you for returning the book on time!",
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondaryText,
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
                          // "Check my library" Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    // Navigate to Books Page -> Returned Tab (Index 2)
                                    builder: (_) => const HomePage(
                                      initialIndex: 1,  
                                    ), 
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
                                "Check my history",
                                style: AppTypography.textTheme.titleMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // "Go to homepage" Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomePage(initialIndex: 0)),
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