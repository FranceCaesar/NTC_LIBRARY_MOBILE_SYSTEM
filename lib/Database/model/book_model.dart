import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String categoryId;
  final String imageUrl;
  final String publisher;
  final String description;
  final String shelfPosition;
  final String status;
  final String language;
  final String isbn;
  final int copies;
  final String publishYear;
  final bool isAvailable;
  final String dateAdded; // Kept as String for UI consistency, but parsed safely

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.categoryId,
    required this.imageUrl,
    required this.publisher,
    required this.description,
    required this.shelfPosition,
    required this.status,
    required this.language,
    required this.isbn,
    required this.copies,
    required this.publishYear,
    required this.dateAdded,
    this.isAvailable = true,
  });

  factory Book.fromMap(Map<String, dynamic> data, String documentId) {
    // Helper to safely parse date
    String parseDate(dynamic dateVal) {
      if (dateVal == null) return '2023-01-01';
      if (dateVal is Timestamp) {
        DateTime d = dateVal.toDate();
        return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      }
      return dateVal.toString();
    }

    return Book(
      id: documentId,
      title: data['title']?.toString() ?? 'No Title',
      author: data['author']?.toString() ?? 'Unknown',
      categoryId: data['categoryId']?.toString() ?? '0',
      imageUrl: data['imageUrl']?.toString() ?? '',
      publisher: data['publisher']?.toString() ?? 'Unknown',
      description: data['description']?.toString() ?? 'No description available.',
      shelfPosition: data['shelfPosition']?.toString() ?? 'Unknown',
      status: data['status']?.toString() ?? 'Unknown',
      language: data['language']?.toString() ?? 'English',
      isbn: data['isbn']?.toString() ?? 'N/A',
      copies: int.tryParse(data['bookCopies'].toString()) ?? 0,
      publishYear: data['publishYear']?.toString() ?? 'N/A',
      dateAdded: parseDate(data['dateAdded']),
      isAvailable: (data['status'] == 'Available') || (data['isAvailable'] == true),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'publisher': publisher,
      'description': description,
      'shelfPosition': shelfPosition,
      'status': status,
      'language': language,
      'isbn': isbn,
      'bookCopies': copies,
      'publishYear': publishYear,
      'dateAdded': dateAdded,
      'isAvailable': isAvailable,
    };
  }
  
  String get categoryName {
    if (categoryId.startsWith('1')) return 'Computer Science';
    if (categoryId.startsWith('2')) return 'Natural Science';
    if (categoryId.startsWith('3')) return 'Social Science';
    if (id.startsWith('4')) return 'Math';
    if (id.startsWith('5')) return 'English Language';
    if (id.startsWith('6')) return 'Art & Design';
    if (id.startsWith('7')) return 'Business';
    return 'General';
  }
}