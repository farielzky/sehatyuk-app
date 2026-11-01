import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/article.dart';

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _bookmarkCollection(String uid) {
    return _firestore.collection('users').doc(uid).collection('bookmarks');
  }

  /// Menghasilkan document ID yang aman dari URL artikel.
  String _generateDocumentId(String articleId) {
    return base64Url.encode(utf8.encode(articleId)).replaceAll('=', '');
  }

  /// Mengambil bookmark secara real-time berdasarkan UID pengguna.
  Stream<List<Article>> watchBookmarks(String uid) {
    return _bookmarkCollection(uid)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Article.fromSaved(doc.data());
          }).toList();
        });
  }

  /// Menambahkan artikel ke bookmark pengguna.
  Future<void> addBookmark(String uid, Article article) async {
    if (article.id.isEmpty) {
      throw ArgumentError('URL artikel tidak boleh kosong.');
    }

    final documentId = _generateDocumentId(article.id);

    await _bookmarkCollection(uid)
        .doc(documentId)
        .set({...article.toJson(), 'savedAt': FieldValue.serverTimestamp()});
  }

  /// Menghapus artikel dari bookmark pengguna.
  Future<void> removeBookmark(String uid, Article article) async {
    final documentId = _generateDocumentId(article.id);

    await _bookmarkCollection(uid).doc(documentId).delete();
  }
}
