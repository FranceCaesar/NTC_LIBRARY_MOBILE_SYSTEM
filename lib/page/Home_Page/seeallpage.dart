import 'package:flutter/material.dart';
import 'package:ntc_library/Database/model/book_model.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import '../Book_page/bookselectedpage.dart';

class SeeAllPage extends StatelessWidget {
  final String title;
  final List<Book> books;

  const SeeAllPage({
    super.key, 
    required this.title, 
    required this.books
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
      ),
      body: books.isEmpty 
          ? Center(
              child: Text(
                "No books found", 
                style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 20,
                childAspectRatio: 0.60, // Optimized for book cover + text height
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailsPage(book: book),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Cover
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.alternate,
                            image: DecorationImage(
                              image: NetworkImage(book.imageUrl),
                              fit: BoxFit.cover,
                              onError: (e, s) {}, 
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1), 
                                blurRadius: 6, 
                                offset: const Offset(2, 4)
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Title
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.titleSmall?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Author
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.secondaryText
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}