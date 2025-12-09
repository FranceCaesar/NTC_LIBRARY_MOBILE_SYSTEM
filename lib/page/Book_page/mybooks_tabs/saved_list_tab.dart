import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ntc_library/theme/colorpallet.dart';
import 'package:ntc_library/theme/text.dart';
import '../../book_page/saved_list_detail.dart';

class SavedListTab extends StatefulWidget {
  const SavedListTab({super.key});

  @override
  State<SavedListTab> createState() => _SavedListTabState();
}

class _SavedListTabState extends State<SavedListTab> {
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  CollectionReference get _listsRef => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('book_lists');

  void _showCreateListSheet() {
    final TextEditingController nameController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Required to allow the sheet to resize with keyboard
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        // This padding is the key: it pushes the sheet up by the height of the keyboard
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView( // Allows scrolling if space is tight
            child: Column(
              mainAxisSize: MainAxisSize.min, // Hug content height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, 
                    height: 4, 
                    decoration: BoxDecoration(
                      color: AppColors.alternate, 
                      borderRadius: BorderRadius.circular(2)
                    )
                  )
                ),
                const SizedBox(height: 24),
                Text(
                  "Create New List", 
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    fontSize: 20, 
                    color: AppColors.primaryText
                  )
                ),
                const SizedBox(height: 8),
                Text(
                  "Give your collection a name", 
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText
                  )
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  autofocus: true, // Focuses input immediately
                  style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.primaryText),
                  decoration: InputDecoration(
                    hintText: "List Name",
                    hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
                    filled: true,
                    fillColor: AppColors.secondaryBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12), 
                      borderSide: BorderSide.none
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty) {
                        await _listsRef.add({
                          "name": nameController.text.trim(),
                          "count": 0,
                          "previewImage": "",
                          "createdAt": FieldValue.serverTimestamp(),
                        });
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, 
                      padding: const EdgeInsets.symmetric(vertical: 16), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: Text(
                      "Create Collection", 
                      style: AppTypography.textTheme.labelLarge?.copyWith(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteList(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryBackground,
        title: Text("Delete List", style: AppTypography.textTheme.titleLarge?.copyWith(color: AppColors.primaryText)),
        content: Text("Are you sure you want to delete this list?", style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text("Cancel", style: AppTypography.textTheme.labelLarge?.copyWith(color: AppColors.primaryText))
          ),
          TextButton(
            onPressed: () async {
              await _listsRef.doc(docId).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text("Delete", style: AppTypography.textTheme.labelLarge?.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _savedListCard(String docId, Map<String, dynamic> data) {
    final String previewImage = data['previewImage'] ?? '';
    final int count = data['count'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SavedListDetail(
              listId: docId, 
              listName: data['name'] ?? 'Untitled'
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryText.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.alternate.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity, 
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackground,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      image: (previewImage.isNotEmpty && count > 0)
                          ? DecorationImage(
                              image: NetworkImage(previewImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (previewImage.isEmpty || count == 0)
                        ? const Center(
                            child: Icon(Icons.folder_open_rounded, size: 40, color: AppColors.secondaryText),
                          )
                        : null,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data['name'] ?? 'Untitled',
                          style: AppTypography.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$count books",
                          style: AppTypography.textTheme.labelSmall?.copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              onPressed: () => _deleteList(docId),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _listsRef.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_books_outlined, size: 100, color: AppColors.alternate.withOpacity(0.5)),
                const SizedBox(height: 20),
                Text("No saved list", style: AppTypography.textTheme.titleMedium?.copyWith(color: AppColors.primaryText)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showCreateListSheet,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text("Create", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: GestureDetector(
                onTap: _showCreateListSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primary.withOpacity(0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text("Create new list", style: AppTypography.textTheme.labelLarge?.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _savedListCard(doc.id, data);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}