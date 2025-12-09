import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import 'package:ntc_library/Database/model/book_model.dart';
import 'package:ntc_library/Database/service/database_service.dart';
import '../Book_page/bookselectedpage.dart'; 
import '../search_page/search_page.dart';
import 'seeallpage.dart';
import 'notification.dart'; 

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _selectedCategoryIndex = 0; 
  late Timer _timer;
  late DateTime _phTime;
  
  late Stream<List<Book>> _booksStream;

  final List<Map<String, dynamic>> _categories = [
    {'title': 'All', 'icon': Icons.all_inbox},
    {'title': 'Natural\nScience', 'icon': Icons.science_outlined}, 
    {'title': 'Social\nScience', 'icon': Icons.public},           
    {'title': 'Math', 'icon': Icons.calculate_outlined},          
    {'title': 'English\nLanguage', 'icon': Icons.translate},      
    {'title': 'Computer\nScience', 'icon': Icons.computer},       
    {'title': 'Art &\nDesign', 'icon': Icons.palette_outlined},   
  ];

  @override
  void initState() {
    super.initState();
    _phTime = DateTime.now().toUtc().add(const Duration(hours: 8)); 
    _booksStream = DatabaseService().getBooks();

    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _phTime = DateTime.now().toUtc().add(const Duration(hours: 8));
      });
    }
  }

  String _formatDate(DateTime date) {
    final List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final List<String> weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    String dayName = weekdays[date.weekday - 1];
    String monthName = months[date.month - 1];
    return '$dayName, ${date.day} $monthName';
  }

  String _formatTime(DateTime date) {
    int hour = date.hour;
    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;
    String minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hi, Sulibio ',
                        style: AppTypography.textTheme.displaySmall,
                      ),
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(Icons.waving_hand, color: AppColors.secondary, size: 24),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search_rounded, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchPage(),
                          ),
                        );
                      },
                    ),

                    // Navigation to Notification.dart
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_outlined, size: 28, color: AppColors.primaryText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),

          // --- Library Occupation Card ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Library Occupation',
                            style: AppTypography.textTheme.headlineSmall
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '0/250',
                            style: AppTypography.textTheme.labelMedium
                          ),
                        ],
                      ),
                      const Icon(Icons.group, color: Colors.white, size: 50),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.white.withOpacity(0.2), height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(_phTime),
                            style: AppTypography.textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(_phTime),
                            style: AppTypography.textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --- Categories ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            // Pass null to hide "See All"
            child: _buildSectionHeader('Explore books by categories', textTheme, null),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = index == _selectedCategoryIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 120,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.primaryBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.alternate,
                        width: 1,
                      ),
                      boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                      ] : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category['title'],
                          style: AppTypography.textTheme.labelMedium?.copyWith(
                            color: isSelected ? Colors.white : AppColors.primaryText,
                            height: 1.2,
                          ),
                          maxLines: 2,
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Icon(
                            category['icon'],
                            size: 26,
                            color: isSelected ? Colors.white : AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          // --- MAIN CONTENT AREA ---
          StreamBuilder<List<Book>>(
            stream: _booksStream, 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                if (!snapshot.hasData) {
                   return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No books available"));
              }

              final allBooks = snapshot.data!;

              // 1. IF "ALL" IS SELECTED -> Show Default Dashboard
              if (_selectedCategoryIndex == 0) {
                final mostBorrowedList = List<Book>.from(allBooks);
                final newBooksList = List<Book>.from(allBooks).reversed.toList();

                return Column(
                  children: [
                    // Most Borrowed
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildSectionHeader(
                        'Most borrowed books', 
                        textTheme, 
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SeeAllPage(title: "Most Borrowed Books", books: mostBorrowedList)
                            )
                          );
                        }
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBookHorizontalList(allBooks, isReversed: false), 

                    const SizedBox(height: 10),
                    _buildSectionDivider(),
                    const SizedBox(height: 10),

                    // New Books
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildSectionHeader(
                        'New books in library', 
                        textTheme, 
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SeeAllPage(title: "New Books", books: newBooksList)
                            )
                          );
                        }
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBookHorizontalList(allBooks, isReversed: true), 
                  ],
                );
              } 
              
              // 2. IF A CATEGORY IS SELECTED -> Show Filtered Grid
              else {
                final filteredBooks = allBooks.where((book) {
                  return _doesBookMatchCategory(book, _selectedCategoryIndex);
                }).toList();

                final categoryTitle = _categories[_selectedCategoryIndex]['title'].toString().replaceAll('\n', ' ');

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$categoryTitle Books (${filteredBooks.length})",
                        style: AppTypography.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      if (filteredBooks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: Text("No books found in this category yet.")),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true, 
                          physics: const NeverScrollableScrollPhysics(), 
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.60,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            return _buildBookCard(filteredBooks[index]);
                          },
                        ),
                    ],
                  ),
                );
              }
            },
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- Helpers ---

  bool _doesBookMatchCategory(Book book, int index) {
    String id = book.categoryId.toString();
    switch (index) {
      case 1: return id.startsWith('2');
      case 2: return id.startsWith('3');
      case 3: return id.startsWith('4');
      case 4: return id.startsWith('5');
      case 5: return id.startsWith('1');
      case 6: return id.startsWith('6');
      default: return false;
    }
  }

  Widget _buildBookHorizontalList(List<Book> books, {bool isReversed = false}) {
    List<Book> displayList = List.from(books);
    if (isReversed) displayList = displayList.reversed.toList();
    if (displayList.length > 5) displayList = displayList.sublist(0, 5);

    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          return _buildBookCard(displayList[index]);
        },
      ),
    );
  }

  Widget _buildSectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: Color.fromARGB(255, 238, 238, 238),
        thickness: 8,
        height: 8
      ),
    );
  }

  // --- UPDATED WIDGET: Nullable onSeeAll hides the button ---
  Widget _buildSectionHeader(String title, TextTheme textTheme, VoidCallback? onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.textTheme.titleSmall),
        if (onSeeAll != null) // Only show if callback is provided
          GestureDetector(
            onTap: onSeeAll,
            child: Text('See All', style: AppTypography.textTheme.labelSmall),
          ),
      ],
    );
  }

  Widget _buildBookCard(Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsPage(book: book),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.alternate,
                  image: DecorationImage(
                    image: NetworkImage(book.imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {},
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(2, 4)),
                  ],
                ),
                child: book.imageUrl.contains('placehold') || book.imageUrl.isEmpty
                    ? const Center(child: Icon(Icons.book, size: 40, color: Colors.white))
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, 
              children: [
                Text(
                  book.title, 
                  style: AppTypography.textTheme.bodyMedium, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis
                ),
                const SizedBox(height: 4),
                Text(
                  book.author, 
                  style: AppTypography.textTheme.labelSmall, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}