import 'package:flutter/material.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import 'reservation_tab.dart';
import 'my_tickets_tab.dart';

class Reservation extends StatefulWidget {
  const Reservation({super.key});

  @override
  State<Reservation> createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text('Reservations', style: AppTypography.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.secondaryText,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'New Reservation'),
            Tab(text: 'My Tickets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NewReservationTab(onSwitchTab: _switchTab),
          const MyTicketsTab(),
        ],
      ),
    );
  }
}