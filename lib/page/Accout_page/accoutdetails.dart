import 'package:flutter/material.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';

class PersonalDetailsPage extends StatelessWidget {
  const PersonalDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      "Personal Details",
                      textAlign: TextAlign.center,
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance for centered title
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ---------------- PROFILE IMAGE ----------------
            Hero(
              tag: "profile_image",
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: const CircleAvatar(
                  radius: 75,
                  backgroundImage: AssetImage("images/profile.jpg"),
                  backgroundColor: AppColors.alternate,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- DETAILS LIST ----------------
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    InfoRow(label: "Name", value: "France Jefferson Sulibio"),
                    InfoRow(label: "Year Level", value: "3rd Year"),
                    InfoRow(label: "Student Type", value: "College"),
                    InfoRow(label: "School Number", value: "422000391"),
                    InfoRow(label: "Year", value: "2025 - 2026"),
                    InfoRow(label: "Gender", value: "Male"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: AppTypography.textTheme.bodyLarge?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}