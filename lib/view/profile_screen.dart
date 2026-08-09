import 'package:provider/provider.dart';
import 'package:capstone_airbnb/provider/language_provider.dart';
import 'package:capstone_airbnb/view/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:capstone_airbnb/view/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String getDisplayName(User user, Map<String, dynamic>? data) {
    final String firestoreName = data?['name']?.toString() ?? '';
    if (firestoreName.isNotEmpty) return firestoreName;

    final String authName = user.displayName ?? '';
    if (authName.isNotEmpty) return authName;

    final String email = user.email ?? 'User';
    return email.split('@').first;
  }

  String getAvatar(User user, Map<String, dynamic>? data) {
    final String firestoreAvatar = data?['photoUrl']?.toString() ?? '';
    if (firestoreAvatar.isNotEmpty) return firestoreAvatar;

    final String authAvatar = user.photoURL ?? '';
    if (authAvatar.isNotEmpty) return authAvatar;

    return '';
  }

  bool isNetworkImage(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  Widget avatarWidget(String avatar, double radius) {
    if (isNetworkImage(avatar)) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatar),
        backgroundColor: Colors.grey.shade200,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: Icon(Icons.person, size: radius, color: Colors.black54),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final lang = Provider.of<LanguageProvider>(context);

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            lang.t(
              'Please login to view profile',
              'Vui lòng đăng nhập để xem hồ sơ',
            ),
          ),
        ),
      );
    }

    final DocumentReference userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: userRef.snapshots(),
          builder: (context, snapshot) {
            final Map<String, dynamic>? data = snapshot.data?.data() == null
                ? null
                : snapshot.data!.data() as Map<String, dynamic>;

            final String name = getDisplayName(user, data);
            final String avatar = getAvatar(user, data);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatarWidget(avatar, 23),
                  const SizedBox(height: 18),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfileDetailScreen(
                            user: user,
                            profileData: data ?? {},
                          ),
                        ),
                      );
                    },
                    child: Text(
                      lang.t('View profile', 'Xem hồ sơ'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    lang.t('Activity', 'Hoạt động'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('booking')
                        .where('userId', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, bookingSnapshot) {
                      if (bookingSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          height: 150,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (!bookingSnapshot.hasData ||
                          bookingSnapshot.data!.docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            lang.t(
                              'No trip activity yet',
                              'Chưa có hoạt động đặt phòng',
                            ),
                          ),
                        );
                      }

                      final booking = bookingSnapshot.data!.docs.first;
                      final bookingData =
                          booking.data() as Map<String, dynamic>;
                      final String image = getBookingImage(bookingData);

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: image.isEmpty
                                  ? Container(
                                      height: 210,
                                      width: double.infinity,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image_not_supported_outlined,
                                      ),
                                    )
                                  : Image.network(
                                      image,
                                      height: 210,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bookingData['roomAddress']?.toString() ??
                                        lang.t(
                                          'No address',
                                          'Không có địa chỉ',
                                        ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bookingData['selectedDateText']
                                            ?.toString() ??
                                        '',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${bookingData['totalPrice'] ?? bookingData['roomPrice'] ?? 0} ${lang.t('night', 'đêm')}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  profileMenuItem(
                    icon: Icons.settings_outlined,
                    title: lang.t('Settings', 'Cài đặt'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  profileMenuItem(
                    icon: Icons.help_outline,
                    title: lang.t('Get help', 'Trợ giúp'),
                    onTap: () {},
                  ),
                  profileMenuItem(
                    icon: Icons.logout,
                    title: lang.t('Log out', 'Đăng xuất'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String getBookingImage(Map<String, dynamic> data) {
    final dynamic images = data['roomImages'];
    if (images is List && images.isNotEmpty) return images.first.toString();
    if (data['roomImage'] != null) return data['roomImage'].toString();
    return '';
  }

  Widget profileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class UserProfileDetailScreen extends StatelessWidget {
  final User user;
  final Map<String, dynamic> profileData;

  const UserProfileDetailScreen({
    super.key,
    required this.user,
    required this.profileData,
  });

  String get name {
    final String firestoreName = profileData['name']?.toString() ?? '';
    if (firestoreName.isNotEmpty) return firestoreName;
    if ((user.displayName ?? '').isNotEmpty) return user.displayName!;
    return user.email?.split('@').first ?? 'User';
  }

  String get avatar {
    final String firestoreAvatar = profileData['photoUrl']?.toString() ?? '';
    if (firestoreAvatar.isNotEmpty) return firestoreAvatar;
    return user.photoURL ?? '';
  }

  bool isNetworkImage(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  Widget avatarWidget(double radius) {
    if (isNetworkImage(avatar)) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatar),
        backgroundColor: Colors.grey.shade200,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: Icon(Icons.person, size: radius, color: Colors.black54),
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
        actions: [
          TextButton(
            onPressed: () async {
              final bool? updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(profileData: profileData),
                ),
              );

              if (updated == true && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              lang.t('Edit', 'Sửa'),
              style: const TextStyle(
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatarWidget(45),
            const SizedBox(height: 18),
            Text(
              lang.t('Hi, I’m $name', 'Xin chào, tôi là $name'),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              profileData['joined']?.toString() ??
                  lang.t('Joined in 2024', 'Tham gia vào năm 2024'),
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 22),
            const Icon(Icons.verified_user_outlined, color: Colors.teal),
            const SizedBox(height: 12),
            Text(
              lang.t('Identity verification', 'Xác minh danh tính'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              lang.t(
                'Show others you’re really you with the identity verification badge',
                'Cho người khác biết bạn là thật bằng huy hiệu xác minh danh tính',
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () {},
              child: Text(lang.t('Get the badge', 'Nhận huy hiệu')),
            ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 22),
            Text(
              lang.t('$name confirmed', '$name đã xác nhận'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.check, size: 20),
                const SizedBox(width: 12),
                Text(lang.t('Phone number', 'Số điện thoại')),
              ],
            ),
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 20),
            buildProfileInfo(
              lang.t('About me', 'Giới thiệu'),
              profileData['about'],
            ),
            buildProfileInfo(
              lang.t('Location', 'Vị trí'),
              profileData['location'],
            ),
            buildProfileInfo(lang.t('Work', 'Công việc'), profileData['work']),
            buildProfileInfo(
              lang.t('Languages', 'Ngôn ngữ'),
              profileData['languages'],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileInfo(String title, dynamic value) {
    final String text = value?.toString() ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(text),
        ],
      ),
    );
  }
}
