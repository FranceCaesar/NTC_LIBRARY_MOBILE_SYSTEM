import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Import Firebase Auth
import '../../Home_Page/home_page.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers
  final TextEditingController _studentNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // State variables
  bool _isPasswordVisible = false;
  bool _isLoading = false; // 2. Add Loading State

  @override
  void dispose() {
    _studentNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Firebase Auth Logic ---
  Future<void> _signIn() async {
    // Basic Validation
    if (_studentNumberController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both Student Number and Password.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Handle Student Number to Email conversion
      // Firebase requires an email. If user enters "2023001", we append the domain.
      String input = _studentNumberController.text.trim();
      String email = input.contains('@') ? input : '$input@ntc.edu.ph'; // Change to your actual domain

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      // 4. Navigate on Success
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // 5. Handle Specific Firebase Errors
      String errorMessage = "Login failed. Please try again.";
      
      if (e.code == 'user-not-found') {
        errorMessage = "No student found with this number.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid ID format.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the common text theme
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground, // Consistent background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 const SizedBox(height: 20),

                Text(
                  "Login here",
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.headlineLarge?.copyWith(
                    fontSize: 35,
                    color: AppColors.primary, 
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                // --- Student Number Field ---
                _buildInputLabel("Student Number", textTheme),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _studentNumberController,
                  hintText: "e.g. 123456",
                  keyboardType: TextInputType.emailAddress, // Changed for better keyboard
                ),
                
                const SizedBox(height: 24),

                // --- Password Field ---
                _buildInputLabel("Password", textTheme),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  hintText: "Enter your password",
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.secondaryText,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                
                // --- Forgot Password Link ---
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                       if (kDebugMode) print("Forgot password tapped");
                       // Optional: Add password reset logic here
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppColors.tertiary,
                    ),
                    child: Text(
                      "Forgot your password?",
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ),
                ),
                 const SizedBox(height: 24),

                // --- Sign In Button ---
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn, // Disable if loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 24, 
                          width: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : Text(
                          "Sign in",
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Divider Text ---
                Text(
                  "Or continue with school email",
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),

                // --- Google Sign-in Button ---
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                        // Note: Google Sign-In requires the google_sign_in package
                        // and extra setup in Firebase Console & Android/iOS configs.
                        if (kDebugMode) print("Google sign-in tapped");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryBackground,
                      foregroundColor: AppColors.primaryText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.alternate),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png',
                          height: 24,
                          width: 24,
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.g_mobiledata, size: 40, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Sign in with Google",
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                 const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, TextTheme textTheme) {
    return Text(
      label,
      style: AppTypography.textTheme.titleSmall?.copyWith(
        color: AppColors.tertiary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.roboto(
        color: AppColors.primaryText, 
        fontWeight: FontWeight.w500
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.secondaryBackground,
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}