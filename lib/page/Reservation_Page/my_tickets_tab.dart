import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/Database/model/reservation_model.dart'; // Import Model
import 'package:ntc_library/theme/text.dart';

class MyTicketsTab extends StatelessWidget {
  const MyTicketsTab({super.key});

  // Firestore
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  CollectionReference get _myRes => FirebaseFirestore.instance.collection('users').doc(_uid).collection('my_reservations');

  void _cancelReservation(BuildContext context, ReservationModel r) async {
    // 1. Update User Status
    await _myRes.doc(r.id).update({'status': 'canceled'});
    
    // 2. Free up Global Slot
    final dateStr = DateFormat('yyyy-MM-dd').format(r.startTime);
    final startHour = r.startTime.hour;
    final slotKey = "${r.assetId}_$startHour";
    
    await FirebaseFirestore.instance
        .collection('reservations_global')
        .doc(dateStr)
        .update({
          slotKey: FieldValue.delete()
        });
        
    if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reservation Canceled")));
  }

  void _deleteReservation(BuildContext context, String id) async {
    await _myRes.doc(id).delete();
    if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from history")));
  }

  void _showCancelDialog(BuildContext context, ReservationModel r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Reservation?"),
        content: const Text("Are you sure you want to cancel this slot?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelReservation(context, r);
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _myRes.orderBy('startTime', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
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
                    "No saved list",
                    style: AppTypography.textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "There is no saved list that you have. You can create a new saved list first.",
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
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            // Ensure ID is passed from doc ID if missing in data
            data['id'] = docs[index].id; 
            
            final r = ReservationModel.fromJson(data);
            final isPending = r.status == ReservationStatus.pending;
            
            Color statusColor = Colors.grey;
            if (isPending) statusColor = AppColors.warning;
            if (r.status == ReservationStatus.confirmed) statusColor = AppColors.success;
            if (r.status == ReservationStatus.canceled) statusColor = AppColors.error;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.secondaryBackground, borderRadius: BorderRadius.circular(10)),
                          child: Icon(
                            r.type == 'ROOM' ? Icons.meeting_room : Icons.computer, 
                            color: AppColors.primary
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${r.assetId} (${r.personCount}p)",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${DateFormat('MMM dd').format(r.startTime)} • ${DateFormat('h:mm a').format(r.startTime)} - ${DateFormat('h:mm a').format(r.endTime)}",
                                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            r.status.name.toUpperCase(), 
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10)
                          ),
                        )
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isPending)
                          TextButton.icon(
                            onPressed: () {
                              final qrData = jsonEncode({'id': r.id, 'asset': r.assetId, 'student': r.studentId});
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (_) => ReservationQrSheet(reservation: r, qrData: qrData, onDone: () => Navigator.pop(context)),
                              );
                            },
                            icon: const Icon(Icons.qr_code, size: 18),
                            label: const Text("View QR"),
                          )
                        else
                          const Text("Ticket Closed", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),

                        // Actions
                        if (isPending)
                          OutlinedButton.icon(
                            onPressed: () => _showCancelDialog(context, r),
                            icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                            label: const Text("Cancel", style: TextStyle(color: AppColors.error)),
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                          )
                        else
                          IconButton(
                            onPressed: () => _deleteReservation(context, r.id),
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            tooltip: "Remove from history",
                          )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}