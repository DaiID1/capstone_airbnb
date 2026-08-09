import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone_airbnb/provider/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLoading = true;
  bool notificationsEnabled = true;
  bool privacyMode = false;

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final currentUser = user;

    if (currentUser == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final data = doc.data();

      if (!mounted) {
        return;
      }

      setState(() {
        notificationsEnabled = data?['notificationsEnabled'] ?? true;
        privacyMode = data?['privacyMode'] ?? false;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateSetting(String key, dynamic value) async {
    final currentUser = user;

    if (currentUser == null) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set({
          key: value,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> changeNotifications(bool value) async {
    setState(() {
      notificationsEnabled = value;
    });

    await updateSetting('notificationsEnabled', value);
  }

  Future<void> changePrivacy(bool value) async {
    setState(() {
      privacyMode = value;
    });

    await updateSetting('privacyMode', value);
  }

  String get userEmail {
    return user?.email ?? 'No email';
  }

  String get userName {
    final displayName = user?.displayName ?? '';

    if (displayName.isNotEmpty) {
      return displayName;
    }

    return user?.email?.split('@').first ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    if (isLoading || lang.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          lang.t('Settings', 'Cài đặt'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            lang.t('Language', 'Ngôn ngữ'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: settingBoxDecoration(),
            child: RadioGroup<String>(
              groupValue: lang.language,
              onChanged: (value) {
                if (value != null) {
                  lang.changeLanguage(value);
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'English',
                    fillColor: WidgetStateProperty.all(Colors.pinkAccent),
                    title: const Text('English'),
                    secondary: const Icon(Icons.language),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    value: 'Tiếng Việt',
                    fillColor: WidgetStateProperty.all(Colors.pinkAccent),
                    title: const Text('Tiếng Việt'),
                    secondary: const Icon(Icons.translate),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            lang.t('Account', 'Tài khoản'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: settingBoxDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person, color: Colors.black54),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            lang.t('Privacy', 'Quyền riêng tư'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: settingBoxDecoration(),
            child: SwitchListTile(
              value: privacyMode,
              activeThumbColor: Colors.pinkAccent,
              onChanged: changePrivacy,
              secondary: const Icon(Icons.lock_outline),
              title: Text(lang.t('Private profile', 'Hồ sơ riêng tư')),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            lang.t('Notifications', 'Thông báo'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: settingBoxDecoration(),
            child: SwitchListTile(
              value: notificationsEnabled,
              activeThumbColor: Colors.pinkAccent,
              onChanged: changeNotifications,
              secondary: const Icon(Icons.notifications_outlined),
              title: Text(lang.t('Push notifications', 'Thông báo đẩy')),
              subtitle: Text(
                notificationsEnabled
                    ? lang.t('Notifications are enabled', 'Thông báo đang bật')
                    : lang.t(
                        'Notifications are disabled',
                        'Thông báo đang tắt',
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration settingBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black12),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
      ],
    );
  }
}
