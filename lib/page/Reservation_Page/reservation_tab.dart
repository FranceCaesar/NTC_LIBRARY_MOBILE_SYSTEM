import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Added for QR Generation

// Imports from your project structure
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import 'package:ntc_library/Database/model/reservation_model.dart';

class NewReservationTab extends StatefulWidget {
  final Function(int) onSwitchTab; // Callback to switch to "My Tickets"

  const NewReservationTab({super.key, required this.onSwitchTab});

  @override
  State<NewReservationTab> createState() => _NewReservationTabState();
}

class _NewReservationTabState extends State<NewReservationTab> {
  // Form Data
  DateTime _selectedDate = DateTime.now();
  
  // Hardcoded Time Slots
  final List<String> _timeSlots = const [
    "7:00 - 8:00",
    "8:00 - 9:00",
    "9:00 - 10:00",
    "10:00 - 11:00",
    "11:00 - 12:00",
    "12:00 - 1:00",
    "1:00 - 2:00",
    "2:00 - 3:00",
    "3:00 - 4:00",
  ];

  int? _selectedSlotIndex;
  String? _selectedAsset;
  int _personCount = 1;
  bool _isBookingRoom = true;
  
  final TextEditingController _purposeCtrl = TextEditingController();
  final TextEditingController _studentIdCtrl = TextEditingController();

  // Assets
  final List<String> _rooms = ['Room 1', 'Room 2', 'Room 3'];
  final List<String> _pcs = ['PC 1', 'PC 2', 'PC 3'];

  // Firestore
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  final CollectionReference _globalRes = FirebaseFirestore.instance.collection('reservations_global');
  CollectionReference get _myRes => FirebaseFirestore.instance.collection('users').doc(_uid).collection('my_reservations');

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), 
      lastDate: DateTime(2100), // Simple future date selection
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlotIndex = null;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedSlotIndex == null || _selectedAsset == null || _purposeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all fields')));
      return;
    }

    // Logic: Index 0 is 7:00, Index 1 is 8:00, etc.
    final startHour = 7 + _selectedSlotIndex!;
    final startTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, startHour);
    final endTime = startTime.add(const Duration(hours: 1));
    final String dateDocId = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final String slotKey = "${_selectedAsset}_$startHour";
    
    // String representation for the ticket UI
    final String timeSlotString = _timeSlots[_selectedSlotIndex!];

    // 1. Check Availability
    final daySnapshot = await _globalRes.doc(dateDocId).get();
    if (daySnapshot.exists) {
      final data = daySnapshot.data() as Map<String, dynamic>;
      if (data.containsKey(slotKey)) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Slot already booked.')));
        return;
      }
    }

    // 2. Prepare Data
    final res = ReservationModel(
      id: '',
      assetId: _selectedAsset!,
      type: _isBookingRoom ? 'ROOM' : 'PC',
      personCount: _isBookingRoom ? _personCount : 1,
      studentId: _studentIdCtrl.text,
      purpose: _purposeCtrl.text,
      startTime: startTime,
      endTime: endTime,
      status: ReservationStatus.pending,
      createdAt: DateTime.now(),
    );

    // 3. Save
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      final myDoc = _myRes.doc();
      res.id = myDoc.id;
      batch.set(myDoc, res.toJson());
      batch.set(_globalRes.doc(dateDocId), {slotKey: _uid}, SetOptions(merge: true));

      await batch.commit();

      // Reset Form
      setState(() {
        _selectedSlotIndex = null;
        _purposeCtrl.clear();
      });

      // 4. Show QR Bottom Sheet (Logic from First Code)
      if (!mounted) return;
      
      // Generate QR Data String
      final qrData = jsonEncode({'id': res.id, 'asset': res.assetId, 'student': res.studentId, 'date': dateDocId});
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: AppColors.primaryBackground, // Matches AppTheme.background
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Handle bar
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 24),
                
                // Title
                const Text("Reservation Ticket", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                const SizedBox(height: 8),
                const Text("Present to Librarian for confirmation", style: TextStyle(color: AppColors.secondaryText)),
                
                const Spacer(),
                
                // QR Code Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Details Rows
                _buildTicketDetailRow("Type", res.type),
                _buildTicketDetailRow("Asset", res.assetId),
                _buildTicketDetailRow("Date", DateFormat('EEE, MMM dd').format(res.startTime)),
                _buildTicketDetailRow("Time", timeSlotString),
                
                const Spacer(),
                
                // Done Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSwitchTab(1); // Switch to "My Tickets"
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Helper for Bottom Sheet Rows
  Widget _buildTicketDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.secondaryText)),
          Text(value, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assets = _isBookingRoom ? _rooms : _pcs;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Toggle Type
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.alternate),
            ),
            child: Row(
              children: [
                Expanded(child: _buildTypeOption("Study Room", true, Icons.meeting_room)),
                Expanded(child: _buildTypeOption("Computer", false, Icons.computer)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. DATE PICKER
          Text("Date & Time", style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.alternate),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(DateFormat('EEE, MMM d, y').format(_selectedDate), style: AppTypography.textTheme.bodyLarge),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: AppColors.secondaryText),
                ],
              ),
            ),
          ),
          
          // 3. TIME SLOTS
          const SizedBox(height: 12),
          StreamBuilder<DocumentSnapshot>(
            stream: _globalRes.doc(DateFormat('yyyy-MM-dd').format(_selectedDate)).snapshots(),
            builder: (context, snapshot) {
              Map<String, dynamic> bookedData = {};
              if (snapshot.hasData && snapshot.data!.exists) {
                bookedData = snapshot.data!.data() as Map<String, dynamic>;
              }

              return Wrap(
                spacing: 8, runSpacing: 8,
                children: List.generate(_timeSlots.length, (i) {
                  final startHour = 7 + i;
                  final slotKey = _selectedAsset != null ? "${_selectedAsset}_$startHour" : "NONE";
                  final isTaken = _selectedAsset != null && bookedData.containsKey(slotKey);
                  
                  bool isPast = false;
                  if (_selectedDate.year == DateTime.now().year && _selectedDate.day == DateTime.now().day) {
                    if (startHour <= DateTime.now().hour) isPast = true;
                  }

                  final isSelected = _selectedSlotIndex == i;
                  final isDisabled = isTaken || isPast;

                  return ChoiceChip(
                    label: Text(_timeSlots[i]),
                    selected: isSelected,
                    onSelected: isDisabled ? null : (v) => setState(() => _selectedSlotIndex = v ? i : null),
                    selectedColor: AppColors.primary,
                    disabledColor: AppColors.secondaryBackground,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDisabled ? AppColors.secondaryText : AppColors.primaryText),
                      fontSize: 12,
                    ),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 24),

          // 4. ASSET SELECTION
          Text(_isBookingRoom ? "Select Room" : "Select PC", style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 1.2, crossAxisSpacing: 12, mainAxisSpacing: 12
            ),
            itemBuilder: (context, index) {
              final label = assets[index];
              final isSelected = _selectedAsset == label;
              return GestureDetector(
                onTap: () => setState(() => _selectedAsset = label),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.alternate),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isBookingRoom ? Icons.meeting_room : Icons.computer, 
                        color: isSelected ? Colors.white : AppColors.secondaryText
                      ),
                      Text(
                        label, 
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.primaryText, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 5. PERSON COUNT (Rooms Only)
          if (_isBookingRoom) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Persons (Max 10)", style: AppTypography.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(onPressed: () => setState(() { if(_personCount>1) _personCount--; }), icon: const Icon(Icons.remove_circle_outline)),
                    Text('$_personCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => setState(() { if(_personCount<10) _personCount++; }), icon: const Icon(Icons.add_circle_outline, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          TextField(
            controller: _purposeCtrl,
            decoration: InputDecoration(
              labelText: "Purpose",
              hintText: "e.g. Thesis Research",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 32),

          // 7. BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: const Text("Generate Ticket", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String title, bool isRoomOption, IconData icon) {
    final selected = _isBookingRoom == isRoomOption;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isBookingRoom = isRoomOption;
          _selectedAsset = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : AppColors.secondaryText, size: 20),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: selected ? Colors.white : AppColors.secondaryText, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}