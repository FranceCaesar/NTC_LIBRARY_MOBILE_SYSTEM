import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntc_library/Database/model/book_model.dart';
import 'package:ntc_library/Database/model/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- COLLECTIONS ---
  CollectionReference get _booksRef => _db.collection('books');
  CollectionReference get _usersRef => _db.collection('users');

  // --- BOOK OPERATIONS ---
  
  // Stream of Books (Real-time updates)
  Stream<List<Book>> getBooks() {
    return _booksRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add a Book (For admin use or testing)
  Future<void> addBook(Book book) {
    return _booksRef.add(book.toMap());
  }

  // --- USER OPERATIONS ---

  // Create User if not exists (called after Login/Register)
  Future<void> createOrUpdateUser(UserModel user) async {
    final docRef = _usersRef.doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set(user.toMap());
    } else {
      // Optional: Update fields if needed, e.g. last login
      // await docRef.update({'lastLogin': FieldValue.serverTimestamp()});
    }
  }

  // Get Current User Data
  Stream<UserModel?> getUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // --- BORROW OPERATIONS ---

  // Get Active Borrows for a specific User
  Stream<List<BorrowTransaction>> getUserActiveBorrows(String uid) {
    return _usersRef
        .doc(uid)
        .collection('active_borrows')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BorrowTransaction.fromMap(doc.data());
      }).toList();
    });
  }
}