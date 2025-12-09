import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntc_library/Database/model/book_model.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import 'package:ntc_library/page/Book_page/bookreturn_book_detail.dart'; 

class BorrowedTab extends StatelessWidget {
  const BorrowedTab({super.key});

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  String _calculateDaysLeft(Timestamp? dateAdded) {
    if (dateAdded == null) return "Unknown Date";
    
    // Convert Firestore Timestamp to DateTime
    final borrowDate = dateAdded.toDate();
    final dueDate = borrowDate.add(const Duration(days: 7));
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return "Overdue by ${difference.abs()} days";
    } else if (difference == 0) {
      return "Return today";
    } else {
      return "Return in $difference days";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to users/{uid}/active_borrows
    final Query<Map<String, dynamic>> borrowsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('active_borrows')
        .orderBy('borrowDate', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: borrowsRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final docs = snapshot.data?.docs ?? [];

        // ------------------------------------------------------
        // EMPTY STATE UI  → MATCHES YOUR 2nd PICTURE
        // ------------------------------------------------------
        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "images/image_logo2.png", // <--- image
                    height: 180,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "No borrowed books",
                    style: AppTypography.textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "There is no borrowed book that you have. You can borrow a new book first.",
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),

                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            
            // Reconstruct Book object from the simplified transaction data
            // We use default values because the transaction might not store everything a full Book object has
            final book = Book(
              id: data['bookId'] ?? '',
              title: data['title'] ?? 'Unknown',
              author: data['author'] ?? 'Unknown',
              imageUrl: data['imageUrl'] ?? '',
              categoryId: '', // Not needed for display here
              publisher: '',
              description: '',
              shelfPosition: '',
              status: data['status'] ?? 'Borrowed',
              language: '',
              isbn: '',
              copies: 1,
              publishYear: '',
              dateAdded: (data['borrowDate'] as Timestamp).toDate().toString(), // Used for logic
            );

            return _buildBorrowCard(
              context,
              book,
              _calculateDaysLeft(data['borrowDate'] as Timestamp?),
            );
          },
        );
      },
    );
  }

  Widget _buildBorrowCard(BuildContext context, Book book, String dueText) {
    final isOverdue = dueText.contains("Overdue");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReturnBookDetail(book: book),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.alternate.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      book.imageUrl,
                      height: 120,
                      width: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Container(
                        height: 120,
                        width: 90,
                        color: AppColors.secondaryBackground,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: AppColors.secondaryText),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isOverdue ? AppColors.error.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, 
                                size: 14, 
                                color: isOverdue ? AppColors.error : AppColors.warning
                              ),
                              const SizedBox(width: 6),
                              Text(
                                dueText,
                                style: AppTypography.textTheme.labelSmall?.copyWith(
                                  color: isOverdue ? AppColors.error : AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.alternate),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}