import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import '../../Database/model/book_model.dart';
import 'booksuccessfullborrow.dart';

class QrTicketBook extends StatefulWidget {
  final Book book;

  const QrTicketBook({super.key, required this.book});

  @override
  State<QrTicketBook> createState() => _QrTicketBookState();
}

class _QrTicketBookState extends State<QrTicketBook> {
  late Timer _timer;
  int _remainingSeconds = 3600;
  late String _qrData;

  late DateTime _borrowDate;
  late DateTime _returnDate;
  String? _studentNumber;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _borrowDate = DateTime.now();
    _returnDate = _borrowDate.add(const Duration(days: 7));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      _studentNumber = user.email!.split('@')[0];
    } else {
      _studentNumber = "GUEST";
    }

    // Same QR structure as first code
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    _qrData =
        "BORROW:${widget.book.id}:$uid:${DateTime.now().millisecondsSinceEpoch}";

    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
      }
    });
  }

  String get _timerText {
    int minutes = (_remainingSeconds ~/ 60);
    int seconds = _remainingSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}/${date.year}";
  }

  String _formatTime(DateTime date) {
    int hour = date.hour > 12 ? date.hour - 12 : date.hour;
    String amPm = date.hour >= 12 ? "PM" : "AM";
    String minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute $amPm";
  }

  // ---------------------------
  // 🔥 SIMULATE LIBRARIAN SCAN
  // ---------------------------
  Future<void> _simulateLibrarianScan() async {
    setState(() => _isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final borrowDate = DateTime.now();
      final dueDate = borrowDate.add(const Duration(days: 7));

      // 1. Add to user active_borrows
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('active_borrows')
          .doc(widget.book.id)
          .set({
        'bookId': widget.book.id,
        'title': widget.book.title,
        'author': widget.book.author,
        'imageUrl': widget.book.imageUrl,
        'borrowDate': Timestamp.fromDate(borrowDate),
        'dueDate': Timestamp.fromDate(dueDate),
        'status': 'Borrowed',
        'copies': widget.book.copies,
      });

      // 2. Decrement bookCopies
      final bookRef =
          FirebaseFirestore.instance.collection('books').doc(widget.book.id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(bookRef);
        if (!snapshot.exists) return;

        int newCopies = (snapshot.data()?['bookCopies'] ?? 0) - 1;
        if (newCopies < 0) newCopies = 0;

        String newStatus = newCopies > 0 ? 'Available' : 'Borrowed';

        transaction.update(bookRef, {
          'bookCopies': newCopies,
          'status': newStatus,
        });
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BorrowSuccessPage()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ---------------------------------------------------
  // --------------------- UI BELOW --------------------
  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(
          "Borrowing Ticket",
          style: AppTypography.textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // SECTION 1
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.alternate),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person_outline, size: 16, color: AppColors.primaryText),
                                const SizedBox(width: 8),
                                Text("Student ID: $_studentNumber",
                                    style: AppTypography.textTheme.labelMedium?.copyWith(
                                        color: AppColors.primaryText, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),

                          // USE FIRST CODE TEXT
                          Text(
                            "Scan at the Librarian's Desk",
                            style: AppTypography.textTheme.labelMedium?.copyWith(
                              color: AppColors.secondaryText,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.alternate, width: 2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: QrImageView(
                              data: _qrData,
                              version: QrVersions.auto,
                              size: 180.0,
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined, color: AppColors.warning, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  "Expires in $_timerText min",
                                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildTicketDivider(),

                    // Book Info Section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.book.imageUrl,
                                  width: 55,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, o, s) => Container(
                                    width: 55,
                                    height: 80,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.book),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.book.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("By ${widget.book.author}",
                                        style: AppTypography.textTheme.labelSmall),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.secondaryBackground),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoColumn("Borrow Date", _formatDate(_borrowDate)),
                              _buildInfoColumn("Time", _formatTime(_borrowDate)),
                              _buildInfoColumn("Return Date", _formatDate(_returnDate), isHighlight: true),
                            ],
                          ),

                          const SizedBox(height: 24),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: AppColors.secondaryText),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Show this QR code to the librarian. Once scanned, the book will be added to your borrowed list.",
                                  style: AppTypography.textTheme.labelSmall?.copyWith(fontSize: 11),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              TextButton(
                onPressed: _isProcessing ? null : _simulateLibrarianScan,
                child: Text(
                  _isProcessing ? "Processing..." : "[DEV] Simulate Librarian Scan",
                  style: const TextStyle(color: Colors.white70, fontSize: 14, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.textTheme.labelSmall
                ?.copyWith(fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.error : AppColors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildTicketDivider() {
    return SizedBox(
      height: 20,
      child: Stack(
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    (constraints.constrainWidth() / 10).floor(),
                    (index) => SizedBox(
                      width: 5,
                      height: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: -10,
            top: 0,
            bottom: 0,
            child: Container(width: 20, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          ),
          Positioned(
            right: -10,
            top: 0,
            bottom: 0,
            child: Container(width: 20, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          ),
        ],
      ),
    );
  }
}
