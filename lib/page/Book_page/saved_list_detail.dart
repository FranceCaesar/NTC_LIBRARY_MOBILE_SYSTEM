import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import 'package:ntc_library/Database/model/book_model.dart'; // Import Book Model
import 'bookselectedpage.dart'; // Import Book Details Page

class SavedListDetail extends StatefulWidget {
  final String listId;
  final String listName;

  const SavedListDetail({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<SavedListDetail> createState() => _SavedListDetailState();
}

class _SavedListDetailState extends State<SavedListDetail> {
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference get _listItemsRef => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('book_lists')
      .doc(widget.listId)
      .collection('items');

  // --- REMOVE BOOK LOGIC ---
  Future<void> _removeBook(String itemId) async {
    await _listItemsRef.doc(itemId).delete();
    
    final listDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('book_lists')
        .doc(widget.listId);
        
    final listSnapshot = await listDocRef.get();
    
    if (listSnapshot.exists) {
        int currentCount = (listSnapshot.data() as Map<String, dynamic>)['count'] ?? 0;
        int newCount = (currentCount > 0) ? currentCount - 1 : 0;

        if (newCount == 0) {
           await listDocRef.update({
             'count': newCount,
             'previewImage': '', 
           });
        } else {
           await listDocRef.update({'count': newCount});
        }
    }
  }

  // --- NAVIGATION LOGIC ---
  Future<void> _navigateToBookDetails(String bookId) async {
    try {
      // Fetch the latest book data from the main 'books' collection
      final docSnapshot = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
      
      if (docSnapshot.exists && context.mounted) {
        // Create Book object
        final book = Book.fromMap(docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
        
        // Navigate
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailsPage(book: book)),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Book details are no longer available.", style: AppTypography.textTheme.bodyMedium?.copyWith(color: Colors.white)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching book: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.listName,
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _listItemsRef.orderBy('savedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bookmark_border, size: 80, color: AppColors.alternate),
                  const SizedBox(height: 16),
                  Text(
                    "No books in this list yet",
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String title = data['title'] ?? 'Unknown Title';
              final String author = data['author'] ?? 'Unknown Author';
              final String imageUrl = data['imageUrl'] ?? '';
              final String itemId = docs[index].id;
              // Use stored bookId or fallback to document ID
              final String bookId = data['bookId'] ?? itemId;

              return GestureDetector(
                onTap: () => _navigateToBookDetails(bookId),
                behavior: HitTestBehavior.opaque, // Ensures the entire row area is clickable
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.alternate.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryText.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 60,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 80,
                              color: AppColors.secondaryBackground,
                              child: const Icon(Icons.broken_image, color: AppColors.secondaryText),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              author,
                              style: AppTypography.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Remove Button (Wrapped in GestureDetector to prevent triggering row tap)
                      GestureDetector(
                        onTap: () => _removeBook(itemId),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}