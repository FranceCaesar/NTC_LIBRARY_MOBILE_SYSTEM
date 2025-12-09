import 'package:flutter/material.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import '../search_page/search_page.dart';

import 'mybooks_tabs/saved_list_tab.dart';
import 'mybooks_tabs/borrowed_tab.dart';
import 'mybooks_tabs/returned_tab.dart';

class mybooks extends StatefulWidget {
  final int initialTab; 

  const mybooks({super.key, this.initialTab = 0});

  @override
  State<mybooks> createState() => _mybooksState();
}

class _mybooksState extends State<mybooks> {
  late int selectedTab;

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Books",
                    style: AppTypography.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),

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
                ],
              ),
            ),

            // ---------------- TABS ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTabButton("Saved list", 0),
                  _buildTabButton("On borrow", 1),
                  _buildTabButton("Returned", 2),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ---------------- TAB CONTENT ----------------
            Expanded(
              child: IndexedStack(
                index: selectedTab,
                children: const [
                  // Tab 0: Saved List
                  SavedListTab(),

                  // Tab 1: On Borrow
                  BorrowedTab(),

                  // Tab 2: Returned (Fetches history from users/{uid}/returned_books)
                  ReturnedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.alternate),
          ),
          child: Center(
            child: Text(
              title,
              style: AppTypography.textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : AppColors.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}