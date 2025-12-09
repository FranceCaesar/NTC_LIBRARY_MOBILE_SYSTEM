import 'package:flutter/material.dart';
import 'package:ntc_library/Database/model/book_model.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';

class ReturnSuccessDetailed extends StatelessWidget {
  final Book book;
  // Ideally pass the transaction date/details here too
  final DateTime returnDate; 

  ReturnSuccessDetailed({
    super.key, 
    required this.book,
    DateTime? returnDate, // Optional, defaults to now if not passed
  }) : returnDate = returnDate ?? DateTime.now();

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Return History",
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        centerTitle: true,
      ),
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
                    children: [
                      const SizedBox(height: 40),

                      // ****** CENTER CONTENT ******
                      Center(
                        child: Column(
                          children: [
                            // Illustration (Reusing success image or book cover)
                            Container(
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  )
                                ]
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  book.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c,o,s) => Image.asset("images/image_logo5.png", fit: BoxFit.contain),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Title
                            Text(
                              "Book Returned Successfully",
                              style: AppTypography.textTheme.headlineSmall?.copyWith(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "You have successfully returned '${book.title}' on ${_formatDate(returnDate)}.",
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondaryText,
                                height: 1.5
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // ****** DETAILS CARD ******
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.alternate.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow("Book Title", book.title),
                            const Divider(height: 24),
                            _buildDetailRow("Author", book.author),
                            const Divider(height: 24),
                            _buildDetailRow("Status", "Returned", isSuccess: true),
                            const Divider(height: 24),
                            _buildDetailRow("Return Date", _formatDate(returnDate)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
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

  Widget _buildDetailRow(String label, String value, {bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isSuccess ? AppColors.success : AppColors.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}