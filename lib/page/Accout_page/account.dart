import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import '../login/wellcome_page/login_page.dart'; 
import '../Home_Page/notification.dart';
import 'accoutdetails.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  // --- LOGOUT LOGIC ---
  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // --- CONFIRMATION SHEET ---
 void _showLogoutConfirmation(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(height: 24),

            // Center Illustration
            SizedBox(
              height: 150,
              child: Image.asset(
                "images/image_logo4.png", // <-- replace with your actual asset
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              "Logout from this account?",
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              "Are you sure you want to logout from this account?\nYou can login again to this account!",
              textAlign: TextAlign.center,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 28),

            // Buttons Row
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "No, Cancel",
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Logout Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleLogout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primary, // Blue like screenshot
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Yes, Logout",
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Profile Header ---
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 32,
                        backgroundImage: AssetImage('images/profile.jpg'),
                        backgroundColor: AppColors.alternate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "France Jefferson Sulibio",
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "422000391",
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              // --- Account Settings ---
              Text(
                "Account",
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.alternate.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    _settingsTile(
                    Icons.person_outline, 
                    "Personal details",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PersonalDetailsPage()),
                      );
                    },
                    ),
                    _divider(),
                    
                    // --- Notification Tile (Now Navigates) ---
                    _settingsTile(
                      Icons.notifications_none, 
                      "Notifications",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationPage()),
                        );
                      }
                    ),
                    
                    _divider(),
                    
                    // --- Logout Tile ---
                    _settingsTile(
                      Icons.logout, 
                      "Logout", 
                      isDestructive: true,
                      onTap: () => _showLogoutConfirmation(context), 
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- General Settings ---
              Text(
                "General",
                style: AppTypography.textTheme.titleSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.alternate.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    _settingsTile(Icons.help_outline, "FAQs & Help"),
                    _divider(),
                    _settingsTile(Icons.article_outlined, "Policies & Terms"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget
  Widget _settingsTile(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Icon(
              icon, 
              color: isDestructive ? AppColors.error : AppColors.primaryText, 
              size: 22
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.error : AppColors.primaryText,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios, 
              size: 14, 
              color: AppColors.secondaryText
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.alternate.withOpacity(0.5),
    );
  }
}