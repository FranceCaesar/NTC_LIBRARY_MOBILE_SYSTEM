import 'package:flutter/material.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground, // Was 0xFFF5F7FC
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifications",
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildBorrowReminder(),
          const SizedBox(height: 20),
          _buildAnnouncement(),
        ],
      ),
    );
  }

  Widget _buildBorrowReminder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground, // White
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1), // Light Red
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.campaign, color: AppColors.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Have fun reading the book? 😊",
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "You have 3 days left to return the book \"Mollie an Adventurous Cat\" you borrow.",
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryText.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 14),

          // BOOK CARD
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.alternate),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    "https://i.imgur.com/QCNbOAo.png",
                    width: 70,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 90,
                        color: AppColors.alternate,
                        child: const Icon(Icons.broken_image, color: AppColors.secondaryText),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mollie an Adventurous Cat",
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                           fontSize: 15,
                           fontWeight: FontWeight.w600
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Lana Grace",
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 8, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Text(
                            "On Borrow (Return in 3 days)",
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("November 15, 2025", style: AppTypography.textTheme.labelSmall),
              Text("08.20", style: AppTypography.textTheme.labelSmall),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAnnouncement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1), // Light Blue
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.layers, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Library Announcement",
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "There is a new faculty members",
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                         color: AppColors.primaryText.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("November 15, 2025", style: AppTypography.textTheme.labelSmall),
              Text("08.20", style: AppTypography.textTheme.labelSmall),
            ],
          )
        ],
      ),
    );
  }
}