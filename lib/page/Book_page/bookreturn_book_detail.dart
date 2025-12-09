import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntc_library/Database/model/book_model.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import 'bookreturnsuccess.dart';

class ReturnBookDetail extends StatefulWidget {
  final Book book;

  const ReturnBookDetail({super.key, required this.book});

  @override
  State<ReturnBookDetail> createState() => _ReturnBookDetailState();
}

class _ReturnBookDetailState extends State<ReturnBookDetail> {
  late String _qrData;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _qrData = "RETURN:${widget.book.id}:$_uid:${DateTime.now().millisecondsSinceEpoch}";
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showReturnQrSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.alternate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Return Ticket",
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Present this QR code to the librarian",
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText
              ),
            ),
            const Spacer(),
            
            // QR CODE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4)
                  )
                ]
              ),
              child: QrImageView(
                data: _qrData,
                version: QrVersions.auto,
                size: 220.0,
                backgroundColor: Colors.white,
              ),
            ),
            
            const Spacer(),
            
            // Status/Instruction
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2))
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Please wait for the librarian to scan and confirm your return.",
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryText
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Simulation Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // 1. Get the Active Borrow Record
                    final activeBorrowRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(_uid)
                        .collection('active_borrows')
                        .doc(widget.book.id);

                    final docSnapshot = await activeBorrowRef.get();

                    if (docSnapshot.exists) {
                      final data = docSnapshot.data()!;
                      
                      // 2. Move to 'returned_books' History
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_uid)
                          .collection('returned_books')
                          .add({
                        ...data,
                        'returnDate': FieldValue.serverTimestamp(),
                        'status': 'Returned',
                        'bookId': widget.book.id, 
                      });

                      // 3. Remove from 'active_borrows'
                      await activeBorrowRef.delete();

                      // 4. Update Book Inventory (Increment Copies)
                      final bookRef = FirebaseFirestore.instance.collection('books').doc(widget.book.id);
                      await FirebaseFirestore.instance.runTransaction((transaction) async {
                        final bookSnapshot = await transaction.get(bookRef);
                        if (bookSnapshot.exists) {
                          int currentCopies = (bookSnapshot.data()?['bookCopies'] ?? 0);
                          transaction.update(bookRef, {
                            'bookCopies': currentCopies + 1,
                            'status': 'Available' // Ensure status is available if returned
                          });
                        }
                      });
                    }

                    if (context.mounted) {
                      Navigator.pop(context); // Close sheet
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (_) => const ReturnSuccessPage())
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error returning book: $e")));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Simulate Successful Scan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Stream to listen to real-time updates
    final transactionStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('active_borrows')
        .doc(widget.book.id)
        .snapshots();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Return Details",
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: transactionStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "No active borrow record found.", 
                style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)
              )
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final borrowTimestamp = data['borrowDate'] as Timestamp?;
          final dueTimestamp = data['dueDate'] as Timestamp?;
          
          final borrowDate = borrowTimestamp?.toDate() ?? DateTime.now();
          final dueDate = dueTimestamp?.toDate() ?? DateTime.now().add(const Duration(days: 7));
          final now = DateTime.now();

          final isOverdue = now.isAfter(dueDate);
          final penaltyAmount = isOverdue ? "PHP 50.00" : "PHP 0.00";

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Book Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                    border: Border.all(color: AppColors.alternate.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.book.imageUrl,
                          width: 80,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(width: 80, height: 110, color: Colors.grey.shade200),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book.title,
                              style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(widget.book.author, style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOverdue ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isOverdue ? "Overdue" : "On Time",
                                style: AppTypography.textTheme.labelSmall?.copyWith(
                                  color: isOverdue ? AppColors.error : AppColors.success,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Details Table
                _buildInfoRow("Borrow Date", _formatDate(borrowDate)),
                _buildDivider(),
                _buildInfoRow("Due Date", _formatDate(dueDate)),
                
                if (isOverdue) ...[
                  _buildDivider(),
                  _buildInfoRow("Penalty", penaltyAmount, isPenalty: true),
                ],
                
                const Spacer(),

                // Return Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showReturnQrSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: Text(
                      "Return Book",
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPenalty = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.textTheme.bodyLarge?.copyWith(color: AppColors.secondaryText)),
          Text(
            value, 
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPenalty ? AppColors.error : AppColors.primaryText
            )
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppColors.alternate);
  }
}