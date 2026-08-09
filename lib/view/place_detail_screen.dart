import 'package:capstone_airbnb/provider/language_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:capstone_airbnb/view/amenities_screen.dart';
import 'package:capstone_airbnb/view/booking_date_screen.dart';
import 'package:capstone_airbnb/view/chat_screen.dart';
import 'package:capstone_airbnb/view/review_screen.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> place;
  const PlaceDetailScreen({super.key, required this.place});
  List<String> get imageUrls {
    final dynamic imageUrl = place['imageUrl'];
    if (imageUrl is List && imageUrl.isNotEmpty) {
      return imageUrl.map((e) => e.toString()).toList();
    }
    if (place['image'] != null && place['image'].toString().isNotEmpty) {
      return [place['image'].toString()];
    }
    return [];
  }

  bool isNetworkImage(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  Widget buildAnyImage({
    required String image,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
  }) {
    if (image.isEmpty) {
      return Container(
        height: height,
        width: width,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported_outlined, size: 45),
      );
    }

    if (isNetworkImage(image)) {
      return Image.network(
        image,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image_not_supported_outlined, size: 45),
          );
        },
      );
    }

    return Image.asset(
      image,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported_outlined, size: 45),
        );
      },
    );
  }

  Widget buildVendorAvatar() {
    final String vendorProfile = place['vendorProfile']?.toString() ?? '';

    if (vendorProfile.isEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.person, color: Colors.black54),
      );
    }

    if (isNetworkImage(vendorProfile)) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(vendorProfile),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: AssetImage(vendorProfile),
    );
  }

  double get latitude {
    final dynamic value = place['latitude'];
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  double get longitude {
    final dynamic value = place['longitude'];
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String getConversationId(String uid, String title, String address) {
    final String rawKey = '${title}_$address'.toLowerCase();
    final String roomKey = rawKey.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return '${uid}_$roomKey';
  }

  Future<void> contactHost(BuildContext context) async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang.t(
              'Please login to contact host',
              'Vui lòng đăng nhập để liên hệ chủ nhà',
            ),
          ),
        ),
      );
      return;
    }

    final String title = place['title']?.toString() ?? 'No title';
    final String address = place['address']?.toString() ?? 'No address';
    final String vendor = place['vendor']?.toString() ?? 'Host';
    final String vendorProfile = place['vendorProfile']?.toString() ?? '';
    final String conversationId = getConversationId(user.uid, title, address);
    final List<dynamic> images = imageUrls;
    final String roomImage = images.isNotEmpty ? images.first.toString() : '';

    final Map<String, dynamic> conversationData = {
      'userId': user.uid,
      'userName': user.displayName ?? 'Guest',
      'hostName': vendor,
      'hostAvatar': vendorProfile,
      'roomTitle': title,
      'roomAddress': address,
      'roomImage': roomImage,
      'roomImages': images,
      'lastMessage': 'Hi $vendor, I am interested in this room.',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      final DocumentReference conversationRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId);
      final DocumentSnapshot oldConversation = await conversationRef.get();
      await conversationRef.set(conversationData, SetOptions(merge: true));

      if (!oldConversation.exists) {
        await conversationRef.collection('messages').add({
          'text': 'Hi $vendor, I am interested in this room.',
          'senderId': user.uid,
          'senderName': user.displayName ?? 'Guest',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            conversationData: {
              ...conversationData,
              'updatedAt': Timestamp.now(),
              'createdAt': Timestamp.now(),
            },
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${lang.t('Cannot contact host', 'Không thể liên hệ chủ nhà')}: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final List<dynamic> images = imageUrls;
    final String mainImage = images.isNotEmpty ? images.first.toString() : '';
    final String title =
        place['title']?.toString() ?? lang.t('No title', 'Không có tiêu đề');
    final String address =
        place['address']?.toString() ??
        lang.t('No address', 'Không có địa chỉ');
    final String vendor =
        place['vendor']?.toString() ?? lang.t('Host', 'Chủ nhà');
    final String vendorProfession = place['vendorProfession']?.toString() ?? '';
    final String bedAndBathroom = place['bedAndBathroom']?.toString() ?? '';
    final String description =
        place['description']?.toString() ??
        lang.t(
          'Enjoy a comfortable and quiet stay with easy access to nearby restaurants, transport, and local attractions. This place is suitable for short trips, weekend getaways, and relaxing vacations.',
          'Tận hưởng kỳ nghỉ thoải mái và yên tĩnh với vị trí thuận tiện gần nhà hàng, phương tiện di chuyển và các điểm tham quan. Chỗ ở này phù hợp cho chuyến đi ngắn, cuối tuần và kỳ nghỉ thư giãn.',
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      buildAnyImage(
                        image: mainImage,
                        height: 300,
                        width: double.infinity,
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 70,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(
                              Icons.ios_share,
                              color: Colors.black,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.black,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${place['rating'] ?? 0} · ${place['review'] ?? 0} ${lang.t('reviews', 'đánh giá')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(address),
                        const SizedBox(height: 20),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.t(
                                      'Private room hosted by $vendor',
                                      'Phòng riêng được đón tiếp bởi $vendor',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(bedAndBathroom),
                                  if (vendorProfession.isNotEmpty)
                                    Text(vendorProfession),
                                ],
                              ),
                            ),
                            buildVendorAvatar(),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const Divider(),
                        featureItem(
                          icon: Icons.door_front_door_outlined,
                          title: lang.t('Self check-in', 'Tự nhận phòng'),
                          subtitle: lang.t(
                            'Check yourself in with the keypad.',
                            'Tự nhận phòng bằng bàn phím mã số.',
                          ),
                        ),
                        featureItem(
                          icon: Icons.location_on_outlined,
                          title: lang.t('Great location', 'Vị trí tuyệt vời'),
                          subtitle: lang.t(
                            'Guests love the location and nearby attractions.',
                            'Khách yêu thích vị trí và các điểm tham quan gần đó.',
                          ),
                        ),
                        featureItem(
                          icon: Icons.event_available_outlined,
                          title: lang.t(
                            'Free cancellation before Feb 12.',
                            'Hủy miễn phí trước ngày 12 tháng 2.',
                          ),
                          subtitle: '',
                        ),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(description),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(
                              lang.t('Show more', 'Hiển thị thêm'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          lang.t("Where you’ll sleep", 'Nơi bạn sẽ ngủ'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 130,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.bed_outlined),
                              const SizedBox(height: 12),
                              Text(
                                lang.t('Bedroom', 'Phòng ngủ'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(lang.t('1 queen bed', '1 giường đôi lớn')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          lang.t(
                            'What this place offers',
                            'Tiện nghi nơi này cung cấp',
                          ),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        amenityItem(
                          Icons.landscape_outlined,
                          lang.t('River view', 'Hướng nhìn ra sông'),
                        ),
                        amenityItem(
                          Icons.kitchen_outlined,
                          lang.t('Kitchen', 'Bếp'),
                        ),
                        amenityItem(Icons.wifi, lang.t('Wifi', 'Wifi')),
                        amenityItem(
                          Icons.local_parking_outlined,
                          lang.t(
                            'Free parking on premises',
                            'Chỗ đỗ xe miễn phí trong khuôn viên',
                          ),
                        ),
                        amenityItem(
                          Icons.ac_unit,
                          lang.t(
                            'AC - split type ductless system',
                            'Điều hòa - hệ thống treo tường',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AmenitiesScreen(place: place),
                              ),
                            ),
                            child: Text(
                              lang.t(
                                'Show all amenities',
                                'Hiển thị tất cả tiện nghi',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          lang.t("Where you’ll be", 'Vị trí của chỗ ở'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 210,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(latitude, longitude),
                                initialZoom: 13,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.capstone_airbnb',
                                ),
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: LatLng(latitude, longitude),
                                      radius: 70,
                                      color: Colors.pink.withValues(
                                        alpha: 0.22,
                                      ),
                                      borderColor: Colors.pinkAccent,
                                      borderStrokeWidth: 1,
                                    ),
                                  ],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(latitude, longitude),
                                      width: 48,
                                      height: 48,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.pinkAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.home,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          address,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lang.t(
                            'Exact location provided after booking. Nearby restaurants and attractions are easy to reach.',
                            'Vị trí chính xác sẽ được cung cấp sau khi đặt phòng. Nhà hàng và điểm tham quan gần đó rất dễ di chuyển.',
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '${place['rating'] ?? 0} · ${place['review'] ?? 0} ${lang.t('reviews', 'đánh giá')}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        reviewSection(context, title, lang),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewScreen(place: place),
                              ),
                            ),
                            child: Text(
                              lang.t('Rate this room', 'Đánh giá phòng này'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Divider(),
                        const SizedBox(height: 12),
                        hostInfoSection(
                          context,
                          vendor,
                          vendorProfession,
                          lang,
                        ),
                        const SizedBox(height: 22),
                        const Divider(),
                        listArrowItem(
                          lang.t('Availability', 'Lịch trống'),
                          'Feb 13 - 14',
                        ),
                        const Divider(),
                        listArrowItem(
                          lang.t('Cancellation policy', 'Chính sách hủy'),
                          lang.t(
                            'Free cancellation before Feb 12. Review the host cancellation policy before booking.',
                            'Hủy miễn phí trước ngày 12 tháng 2. Hãy xem chính sách hủy của chủ nhà trước khi đặt.',
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.flag),
                            const SizedBox(width: 8),
                            Text(
                              lang.t(
                                'Report this listing',
                                'Báo cáo chỗ ở này',
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '\$${place['price'] ?? 0} ${lang.t('night', 'đêm')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingDateScreen(place: place),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(
                  horizontal: 34,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                lang.t('Reserve', 'Đặt phòng'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget featureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget amenityItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 23),
          const SizedBox(width: 13),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget reviewSection(
    BuildContext context,
    String roomTitle,
    LanguageProvider lang,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('roomTitle', isEqualTo: roomTitle)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              lang.t(
                'No reviews yet. Be the first to rate this room.',
                'Chưa có đánh giá. Hãy là người đầu tiên đánh giá phòng này.',
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        return SizedBox(
          height: 155,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final comment = data['comment']?.toString() ?? '';
              final userName =
                  data['userName']?.toString() ?? lang.t('You', 'Bạn');
              final userAvatar = data['userAvatar']?.toString() ?? '';

              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: isNetworkImage(userAvatar)
                              ? NetworkImage(userAvatar)
                              : null,
                          child: userAvatar.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(comment, maxLines: 4, overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget hostInfoSection(
    BuildContext context,
    String vendor,
    String vendorProfession,
    LanguageProvider lang,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.t('Hosted by $vendor', 'Được đón tiếp bởi $vendor'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lang.t('Joined in July 2014', 'Tham gia vào tháng 7 năm 2014'),
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.star, size: 18),
                  const SizedBox(width: 8),
                  Text(lang.t('3 Reviews', '3 đánh giá')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.verified_user, size: 18),
                  const SizedBox(width: 8),
                  Text(lang.t('Identity verified', 'Đã xác minh danh tính')),
                ],
              ),
              const SizedBox(height: 18),
              if (vendorProfession.isNotEmpty) Text(vendorProfession),
              const SizedBox(height: 20),
              Text(
                lang.t('During your stay', 'Trong thời gian lưu trú'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                lang.t(
                  'I will be available on site. You can reach me through the app.',
                  'Tôi sẽ có mặt tại chỗ. Bạn có thể liên hệ với tôi qua ứng dụng.',
                ),
              ),
              const SizedBox(height: 16),
              Text(lang.t('Language: English', 'Ngôn ngữ: Tiếng Anh')),
              const SizedBox(height: 8),
              Text(lang.t('Response rate: 100%', 'Tỷ lệ phản hồi: 100%')),
              const SizedBox(height: 8),
              Text(
                lang.t(
                  'Response time: within an hour',
                  'Thời gian phản hồi: trong vòng một giờ',
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => contactHost(context),
                  child: Text(lang.t('Contact Host', 'Liên hệ chủ nhà')),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                lang.t(
                  'To protect your payment, never transfer money or communicate outside of this app.',
                  'Để bảo vệ khoản thanh toán, không chuyển tiền hoặc trao đổi bên ngoài ứng dụng này.',
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        buildVendorAvatar(),
      ],
    );
  }

  Widget listArrowItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
