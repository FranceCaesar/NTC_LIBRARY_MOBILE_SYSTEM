import 'package:flutter/material.dart';
import 'package:ntc_library/Database/model/book_model.dart';
import 'package:ntc_library/Database/service/database_service.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import '../Book_page/bookselectedpage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  String _searchQuery = "";

  bool _filterAvailableOnly = false;
  String _selectedCategory = "All";

  // Mapped category names to icons
  final List<Map<String, dynamic>> _categories = [
    {"label": "All", "icon": Icons.all_inclusive},
    {"label": "Natural Science", "icon": Icons.science_outlined},
    {"label": "Social Science", "icon": Icons.public},
    {"label": "Math", "icon": Icons.calculate_outlined},
    {"label": "English Language", "icon": Icons.translate},
    {"label": "Computer Science", "icon": Icons.computer},
    {"label": "Art & Design", "icon": Icons.brush_outlined},
    {"label": "Business", "icon": Icons.business_center_outlined},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> _filterBooks(List<Book> allBooks) {
    return allBooks.where((book) {
      // 1. Search Text
      final matchesSearch = book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase());

      // 2. Stock Availability
      final matchesStock = !_filterAvailableOnly || (book.copies > 0);

      // 3. Category Match
      // Note: We use 'book.categoryName' getter from your model to match the label
      final matchesCategory = _selectedCategory == "All" || book.categoryName == _selectedCategory;

      return matchesSearch && matchesStock && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // --- HEADER & SEARCH ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryText),
                  ),
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBackground,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryText,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search any books",
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
                          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryText,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.tune, size: 24, color: AppColors.primaryText),
                    onPressed: _openFilterSheet,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- RECENT SEARCH HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    "Search Results",
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _searchController.clear();
                      _searchQuery = "";
                    }),
                    child: Text(
                      "Clear",
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- RESULTS LIST ---
            Expanded(
              child: StreamBuilder<List<Book>>(
                stream: _dbService.getBooks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  final books = _filterBooks(snapshot.data!);

                  if (books.isEmpty) {
                    return _buildEmptyState();
                    
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder: (_, index) {
                      final book = books[index];

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BookDetailsPage(book: book)),
                        ),
                        child: Container(
                          color: Colors.transparent, // Ensures the whole row is clickable
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Book Cover
                              Container(
                                width: 80,
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.alternate,
                                  image: DecorationImage(
                                    image: NetworkImage(book.imageUrl),
                                    fit: BoxFit.cover,
                                    onError: (e, s) {},
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(2, 2),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              
                              // Book Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      book.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.textTheme.titleMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book.author,
                                      style: AppTypography.textTheme.labelSmall?.copyWith(
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Rating & Stock Row
                                    Row(
                                      children: [
                                        // Used AppColors.secondary (Brand Yellow) for the star
                                        const Icon(Icons.star, color: AppColors.secondary, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          "4.9",
                                          style: AppTypography.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: 4, 
                                          height: 4, 
                                          decoration: const BoxDecoration(
                                            color: AppColors.alternate, 
                                            shape: BoxShape.circle
                                          )
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "${book.copies} books available",
                                          style: AppTypography.textTheme.labelSmall?.copyWith(
                                            color: AppColors.primary, // Brand Blue
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }

Widget _buildEmptyState() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- Illustration Image ---
          SizedBox(
            height: 200,
            child: Image.asset(
              "images/image_logo3.png",
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 20),

          // --- Title ---
          Text(
            "No matches data found",
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // --- Subtitle ---
          Text(
            "There is no matches data that you search.\nTry using different keyword!",
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
  // --- FILTER SHEET ---

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryBackground,
      isScrollControlled: true,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 350),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.alternate, // Gray handle
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Filter",
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Section: Stock
                  Text(
                    "Book stock",
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _stockChip("All stock", !_filterAvailableOnly, 
                        () => setModal(() => _filterAvailableOnly = false)),
                      const SizedBox(width: 12),
                      _stockChip("Available", _filterAvailableOnly, 
                        () => setModal(() => _filterAvailableOnly = true)),
                    ],
                  ),

                  const SizedBox(height: 30),
                  
                  // Section: Categories
                  Text(
                    "Categories",
                    style: AppTypography.textTheme.titleSmall?.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _categories.map((cat) {
                      return _categoryChip(
                        label: cat["label"],
                        icon: cat["icon"],
                        selected: _selectedCategory == cat["label"],
                        onTap: () => setModal(() => _selectedCategory = cat["label"]),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 35),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _filterAvailableOnly = false;
                              _selectedCategory = "All";
                            });
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.alternate),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            "Reset",
                            style: AppTypography.textTheme.titleSmall?.copyWith(
                              color: AppColors.primaryText
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary, // Brand Blue
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() {}); // Trigger rebuild on parent
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Apply",
                            style: AppTypography.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- WIDGET HELPERS ---

  Widget _stockChip(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.textTheme.labelMedium?.copyWith(
              color: selected ? Colors.white : AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip({required String label, required IconData icon, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          // Subtle blue tint for selected, plain white for unselected
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.alternate,
            width: 1.4
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 18, 
              color: selected ? AppColors.primary : AppColors.secondaryText
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: selected ? AppColors.primary : AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}