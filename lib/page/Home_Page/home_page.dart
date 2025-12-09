import 'package:flutter/material.dart';
import 'package:ntc_library/theme/colorpallet.dart';

// UI Pages
import 'home_dashboard.dart';
import '../Reservation_Page/reservation.dart';
import '../Accout_page/account.dart';
import '../Book_page/mybooks.dart';

class HomePage extends StatefulWidget {
  final int initialIndex; // Add this parameter

  const HomePage({super.key, this.initialIndex = 0}); // Default is 0 (Home)

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set initial index from constructor
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      
      // Body content switches based on index
      body: SafeArea(
        child: _getPageContent(),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: textTheme.labelSmall,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: 'Books',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Appoint',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  // Helper to switch views
  Widget _getPageContent() {
    switch (_selectedIndex) {
      
      case 0:
        return const HomeDashboard(); 
      case 1:
        return const mybooks(); 
      case 2:
        return const Reservation(); 
      case 3:
        return const Account();

      default:
        return const HomeDashboard();
    }
  }
}