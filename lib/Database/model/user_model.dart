import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String studentNumber;
  final String grade;
  final String section;
  
  // NOTE: Saved Books and Borrowed Books are typically stored in subcollections 
  // (users/{uid}/book_lists and users/{uid}/active_borrows) to avoid document size limits.
  // This model represents the main user profile document.

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.studentNumber,
    required this.grade,
    required this.section,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email']?.toString() ?? '',
      fullName: data['fullName']?.toString() ?? 'NTC Student',
      studentNumber: data['studentNumber']?.toString() ?? '',
      grade: data['grade']?.toString() ?? '',
      section: data['section']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'studentNumber': studentNumber,
      'grade': grade,
      'section': section,
    };
  }
}

// Model for "Active Borrows" Subcollection
class BorrowTransaction {
  final String bookId;
  final String title;
  final String author;
  final String imageUrl;
  final DateTime borrowDate;
  final DateTime dueDate;
  final String status; // e.g., "Borrowed", "Returned", "Overdue"

  BorrowTransaction({
    required this.bookId,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.borrowDate,
    required this.dueDate,
    this.status = 'Borrowed',
  });

  factory BorrowTransaction.fromMap(Map<String, dynamic> data) {
    return BorrowTransaction(
      bookId: data['bookId']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Unknown Title',
      author: data['author']?.toString() ?? 'Unknown Author',
      imageUrl: data['imageUrl']?.toString() ?? '',
      borrowDate: (data['borrowDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
      status: data['status']?.toString() ?? 'Borrowed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'borrowDate': Timestamp.fromDate(borrowDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
    };
  }
}