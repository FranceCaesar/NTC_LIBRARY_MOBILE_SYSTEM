import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ntc_library/Database/model/book_model.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import '../return_success_detailed.dart';

class ReturnedTab extends StatelessWidget {
  const ReturnedTab({super.key});

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // --- DELETE LOGIC ---
  Future<void> _deleteHistoryItem(BuildContext context, String docId) async {
    // Show Confirmation Dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryBackground,
        title: Text(
          "Remove History",
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        content: Text(
          "Are you sure you want to remove this record from your history?",
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.primaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              "Remove",
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('returned_books')
            .doc(docId)
            .delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("History item removed"),
              backgroundColor: AppColors.primaryText,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint("Error deleting history: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Query<Map<String, dynamic>> returnedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('returned_books')
        .orderBy('returnDate', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: returnedRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
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
                    "No returned books",
                    style: AppTypography.textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "There are no returned books in your history. Once you return books, they will appear here.",
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['returnDate'] as Timestamp?;
            final returnDate = timestamp?.toDate() ?? DateTime.now();

            final book = Book(
              id: data['bookId'] ?? '',
              title: data['title'] ?? 'Unknown',
              author: data['author'] ?? 'Unknown',
              imageUrl: data['imageUrl'] ?? '',
              categoryId: '',
              publisher: '',
              description: '',
              shelfPosition: '',
              status: 'Returned',
              language: '',
              isbn: '',
              copies: 0,
              publishYear: '',
              dateAdded: '',
            );

            return _buildReturnedCard(context, book, returnDate, doc.id);
          },
        );
      },
    );
  }

  Widget _buildReturnedCard(
    BuildContext context,
    Book book,
    DateTime returnDate,
    String docId,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ReturnSuccessDetailed(book: book, returnDate: returnDate),
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
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          book.imageUrl,
                          height: 100,
                          width: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(
                            height: 100,
                            width: 70,
                            color: AppColors.secondaryBackground,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.secondaryText),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Returned on ${_formatDate(returnDate)}",
                                  style: AppTypography.textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReturnSuccessDetailed(
                              book: book,
                              returnDate: returnDate,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "View Details",
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delete Icon (Top Right)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.alternate,
                ),
                onPressed: () => _deleteHistoryItem(context, docId),
                tooltip: "Remove from history",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
