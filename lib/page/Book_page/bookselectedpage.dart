import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ntc_library/Database/model/book_model.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import 'qrticket_book.dart';
import 'package:ntc_library/Database/service/database_service.dart';
import '../Home_Page/seeallpage.dart';

class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  // State to manage text expansion
  bool _isExpanded = false;

  // State for bookmark icon
  bool _isSaved = false;
  bool _isLoadingStatus = true;

  // Firestore Helpers
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  CollectionReference get _userListsRef => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('book_lists');

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  // --- CHECK SAVED STATUS ---
  Future<void> _checkIfSaved() async {
    if (uid.isEmpty) return;

    try {
      final listsSnapshot = await _userListsRef.get();
      bool found = false;

      for (var doc in listsSnapshot.docs) {
        final itemDoc = await doc.reference
            .collection('items')
            .doc(widget.book.id)
            .get();
        if (itemDoc.exists) {
          found = true;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _isSaved = found;
          _isLoadingStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStatus = false);
      }
    }
  }

  String _getCategoryName(String id) {
    if (id.startsWith("1")) return "Computer Science";
    if (id.startsWith("2")) return "Natural Science";
    if (id.startsWith("3")) return "Social Science";
    if (id.startsWith("4")) return "Math";
    if (id.startsWith("5")) return "English Language";
    if (id.startsWith("6")) return "Art & Design";
    if (id.startsWith("7")) return "Business";
    return "General";
  }

  // --- SAVE TO LIST LOGIC ---

  Future<void> _createNewList(BuildContext sheetContext) async {
    final TextEditingController nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.primaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "New Booklist",
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: "List Name (e.g. Favorites)",
                  hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.alternate),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    await _userListsRef.add({
                      "name": nameController.text.trim(),
                      "count": 0,
                      "previewImage": "",
                      "createdAt": FieldValue.serverTimestamp(),
                    });
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Create",
                  style: AppTypography.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBookToSelectedList(String listId) async {
    try {
      final itemRef = _userListsRef
          .doc(listId)
          .collection('items')
          .doc(widget.book.id);

      await itemRef.set({
        'bookId': widget.book.id,
        'title': widget.book.title,
        'author': widget.book.author,
        'imageUrl': widget.book.imageUrl,
        'savedAt': FieldValue.serverTimestamp(),
        'uid': uid,
      });

      final listRef = _userListsRef.doc(listId);
      final listDoc = await listRef.get();

      if (listDoc.exists) {
        int currentCount =
            (listDoc.data() as Map<String, dynamic>)['count'] ?? 0;
        await listRef.update({
          'count': currentCount + 1,
          'previewImage': widget.book.imageUrl,
        });
      }

      setState(() {
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Saved to list!",
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to save: $e",
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    }
  }

  void _showSaveToListSheet() {
    String? selectedListId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primaryBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.alternate,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Save to...",
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  StreamBuilder<QuerySnapshot>(
                    stream: _userListsRef
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Text(
                                "No booklists found.",
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.secondaryText),
                              ),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: () => _createNewList(context),
                                icon: const Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                ),
                                label: Text(
                                  "Create New List",
                                  style: AppTypography.textTheme.labelLarge
                                      ?.copyWith(color: AppColors.primary),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        );
                      }

                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final isSelected = selectedListId == doc.id;

                            return GestureDetector(
                              onTap: () {
                                setSheetState(() => selectedListId = doc.id);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : AppColors.primaryBackground,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.alternate,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.secondaryText,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        data['name'] ?? 'Untitled',
                                        style: AppTypography.textTheme.bodyLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.primaryText,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${data['count'] ?? 0} items",
                                      style: AppTypography.textTheme.labelSmall
                                          ?.copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: AppColors.alternate),
                          ),
                          child: Text(
                            "Cancel",
                            style: AppTypography.textTheme.labelLarge?.copyWith(
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedListId == null
                              ? null
                              : () {
                                  _saveBookToSelectedList(selectedListId!);
                                  Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.alternate,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Proceed",
                            style: AppTypography.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBorrowConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: const BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.alternate,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 140,
                child: Image.asset(
                  "images/image_logo1.png",
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Borrow this book now?",
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to borrow '${widget.book.title}'? You will have 7 days to return it.",
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: const BorderSide(color: AppColors.alternate),
                      ),
                      child: Text(
                        "Cancel",
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QrTicketBook(book: widget.book),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Yes, borrow",
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // --- HELPER: Build Similar Book Card ---
  Widget _buildSimilarBookCard(Book book) {
    return Container(
      width: 120, // Adjusted width for 3 cards in view
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              book.imageUrl,
              height: 160,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Container(
                height: 160,
                width: 120,
                color: AppColors.secondaryBackground,
                child: const Icon(
                  Icons.broken_image,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.titleSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: Build Detail Row ---
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                      fontSize: 14, color: AppColors.secondaryText))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final descriptionText =
        (widget.book.description.isNotEmpty &&
            widget.book.description != 'No description available.')
        ? widget.book.description
        : "This book provides a comprehensive overview of ${_getCategoryName(widget.book.categoryId)} concepts. Written by ${widget.book.author}, published by ${widget.book.publisher}. It is an essential resource for students.";

    final Color statusColor = widget.book.isAvailable
        ? AppColors.success
        : AppColors.error;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (Back Button) ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryText,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // --- SCROLLABLE CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // --- 1. FULL WIDTH BACKGROUND SECTION ---
                    Container(
                      width: double.infinity, // Full Screen Width
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryBackground, // Grey Background
                      ),
                      child: Center(
                        child: Container(
                          height: 260,
                          width: 170,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            // Image goes inside the decoration
                            image: DecorationImage(
                              image: NetworkImage(widget.book.imageUrl),
                              fit: BoxFit.cover,
                              onError: (e, s) {},
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryText.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: widget.book.imageUrl.isEmpty ||
                                  widget.book.imageUrl.contains('placehold')
                              ? const Center(
                                  child: Icon(
                                    Icons.book,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- 2. PADDED CONTENT SECTION ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CATEGORY TAG
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.alternate),
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.primaryBackground,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.category_outlined,
                                    size: 16,
                                    color: AppColors.primaryText,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getCategoryName(widget.book.categoryId),
                                    style: AppTypography.textTheme.labelMedium
                                        ?.copyWith(
                                      color: AppColors.primaryText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // TITLE
                          Text(
                            widget.book.title,
                            textAlign: TextAlign.center,
                            style: AppTypography.textTheme.headlineMedium
                                ?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              color: AppColors.primaryText,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // STATUS & DETAILS
                          _buildDetailRow("Status", widget.book.status),
                          _buildDetailRow(
                            "Shelf position",
                            widget.book.shelfPosition,
                          ),
                          _buildDetailRow(
                            "Book Copy",
                            widget.book.copies.toString(),
                          ),
                          _buildDetailRow("Publisher", widget.book.publisher),
                          _buildDetailRow("Writer", widget.book.author),
                          _buildDetailRow("Language", widget.book.language),

                          const SizedBox(height: 20),

                          // SYNOPSIS
                          Text(
                            "Synopsis",
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                style: AppTypography.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppColors.secondaryText,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: _isExpanded
                                        ? descriptionText
                                        : (descriptionText.length > 150
                                            ? "${descriptionText.substring(0, 150)}... "
                                            : "$descriptionText "),
                                  ),
                                  if (descriptionText.length > 150)
                                    TextSpan(
                                      text: _isExpanded
                                          ? " Show less"
                                          : "Read more",
                                      style: AppTypography.textTheme.labelMedium
                                          ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),
                          const Divider(color: AppColors.alternate),
                          const SizedBox(height: 20),

                          // SIMILAR BOOKS SECTION
                          StreamBuilder<List<Book>>(
                            stream: DatabaseService().getBooks(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                );
                              }

                              final similarBooks = snapshot.data!
                                  .where(
                                    (b) =>
                                        b.categoryId ==
                                            widget.book.categoryId &&
                                        b.id != widget.book.id,
                                  )
                                  .toList();

                              if (similarBooks.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Similar like this book",
                                        style: AppTypography
                                            .textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SeeAllPage(
                                                title: "Similar Books",
                                                books: similarBooks,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "See All",
                                          style: AppTypography
                                              .textTheme.labelMedium
                                              ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 220,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: similarBooks.length > 3
                                          ? 3
                                          : similarBooks.length,
                                      itemBuilder: (context, index) {
                                        final similarBook = similarBooks[index];
                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BookDetailsPage(
                                                  book: similarBook,
                                                ),
                                              ),
                                            );
                                          },
                                          child: _buildSimilarBookCard(
                                            similarBook,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTTOM ACTIONS ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Bookmark Button
                  GestureDetector(
                    onTap: () {
                      if (_isSaved) {
                        // Already saved, maybe remove? (Optional logic)
                      } else {
                        _showSaveToListSheet();
                      }
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.alternate),
                        color: _isSaved
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: _isLoadingStatus
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: _isSaved
                                  ? AppColors.primary
                                  : AppColors.primaryText,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Borrow Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.book.isAvailable
                          ? () {
                              _showBorrowConfirmation(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.alternate,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.book.isAvailable ? "Borrow now" : "Unavailable",
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
