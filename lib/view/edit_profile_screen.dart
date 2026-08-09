import 'package:capstone_airbnb/provider/language_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController photoController;
  late final TextEditingController aboutController;
  late final TextEditingController locationController;
  late final TextEditingController workController;
  late final TextEditingController languagesController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;

    nameController = TextEditingController(
      text: widget.profileData['name']?.toString() ?? user?.displayName ?? '',
    );
    photoController = TextEditingController(
      text: widget.profileData['photoUrl']?.toString() ?? user?.photoURL ?? '',
    );
    aboutController = TextEditingController(
      text: widget.profileData['about']?.toString() ?? '',
    );
    locationController = TextEditingController(
      text: widget.profileData['location']?.toString() ?? '',
    );
    workController = TextEditingController(
      text: widget.profileData['work']?.toString() ?? '',
    );
    languagesController = TextEditingController(
      text: widget.profileData['languages']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    photoController.dispose();
    aboutController.dispose();
    locationController.dispose();
    workController.dispose();
    languagesController.dispose();
    super.dispose();
  }

  bool isNetworkImage(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  Future<void> saveProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    if (user == null) return;

    setState(() {
      isSaving = true;
    });

    final String name = nameController.text.trim();
    final String photoUrl = photoController.text.trim();

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': name,
        'photoUrl': photoUrl,
        'about': aboutController.text.trim(),
        'location': locationController.text.trim(),
        'work': workController.text.trim(),
        'languages': languagesController.text.trim(),
        'joined': widget.profileData['joined'] ?? 'Joined in 2024',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
      }

      if (photoUrl.isNotEmpty && isNetworkImage(photoUrl)) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang.t('Profile saved successfully', 'Đã lưu hồ sơ thành công'),
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${lang.t('Save failed', 'Lưu thất bại')}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget profileAvatarPreview() {
    final String url = photoController.text.trim();

    if (isNetworkImage(url)) {
      return CircleAvatar(
        radius: 68,
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.grey.shade200,
      );
    }

    return CircleAvatar(
      radius: 68,
      backgroundColor: Colors.blueGrey.shade700,
      child: Icon(Icons.person, size: 78, color: Colors.blueGrey.shade200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          lang.t('Edit Profile', 'Chỉnh sửa hồ sơ'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isSaving ? null : saveProfile,
            child: Text(
              isSaving
                  ? lang.t('Saving...', 'Đang lưu...')
                  : lang.t('Save', 'Lưu'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            profileAvatarPreview(),
            const SizedBox(height: 12),
            TextField(
              controller: photoController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: lang.t('Photo URL', 'Link ảnh đại diện'),
                hintText: lang.t(
                  'Paste image URL here',
                  'Dán link ảnh vào đây',
                ),
              ),
            ),
            const SizedBox(height: 24),
            buildEditField(lang.t('Name', 'Tên'), nameController),
            buildEditField(lang.t('About me', 'Giới thiệu'), aboutController),
            buildEditField(lang.t('Location', 'Vị trí'), locationController),
            buildEditField(lang.t('Work', 'Công việc'), workController),
            buildEditField(
              lang.t('Languages', 'Ngôn ngữ'),
              languagesController,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, suffixText: 'Add'),
      ),
    );
  }
}
