import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String language = 'English';
  bool isLoading = true;

  bool get isVietnamese => language == 'Tiếng Việt';

  String t(String en, String vi) {
    return isVietnamese ? vi : en;
  }

  Future<void> loadLanguage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      language = doc.data()?['language']?.toString() ?? 'English';
    } catch (_) {
      language = 'English';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> changeLanguage(String value) async {
    language = value;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'language': value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
