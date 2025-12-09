import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';

// --- ENUMS & MODEL ---

enum ReservationStatus { pending, confirmed, canceled, noShow, completed }

class ReservationModel {
  String id;
  String assetId;
  String type; // 'ROOM' or 'PC'
  int personCount;
  String studentId;
  String purpose;
  DateTime startTime;
  DateTime endTime;
  ReservationStatus status;
  DateTime createdAt;

  ReservationModel({
    required this.id,
    required this.assetId,
    required this.type,
    required this.personCount,
    required this.studentId,
    required this.purpose,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'assetId': assetId,
    'type': type,
    'personCount': personCount,
    'studentId': studentId,
    'purpose': purpose,
    'startTime': Timestamp.fromDate(startTime),
    'endTime': Timestamp.fromDate(endTime),
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  static ReservationModel fromJson(Map<String, dynamic> j) {
    return ReservationModel(
      id: j['id'] as String? ?? '',
      assetId: j['assetId'] as String? ?? '',
      type: j['type'] as String? ?? 'ROOM',
      personCount: j['personCount'] as int? ?? 1,
      studentId: j['studentId'] as String? ?? '',
      purpose: j['purpose'] as String? ?? '',
      startTime: (j['startTime'] as Timestamp).toDate(),
      endTime: (j['endTime'] as Timestamp).toDate(),
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == j['status'] as String,
        orElse: () => ReservationStatus.pending,
      ),
      createdAt: (j['createdAt'] as Timestamp).toDate(),
    );
  }
}

// --- SHARED WIDGET: QR BOTTOM SHEET ---

class ReservationQrSheet extends StatelessWidget {
  final ReservationModel reservation;
  final String qrData;
  final VoidCallback onDone;

  const ReservationQrSheet({
    super.key,
    required this.reservation,
    required this.qrData,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.alternate,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Reservation Ticket',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Present this QR to the librarian',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText
            ),
          ),
          const Spacer(),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4)
                )
              ],
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),

          const Spacer(),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Asset", style: TextStyle(color: AppColors.secondaryText)),
                    Text(reservation.assetId, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Time", style: TextStyle(color: AppColors.secondaryText)),
                    Text(
                      DateFormat('h:mm a').format(reservation.startTime), 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Done', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }
}