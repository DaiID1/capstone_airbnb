import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone_airbnb/provider/language_provider.dart';
import 'package:capstone_airbnb/view/place_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  String getImage(Map<String, dynamic> data) {
    final dynamic imageUrl = data['imageUrl'];
    if (imageUrl is List && imageUrl.isNotEmpty) return imageUrl.first.toString();
    if (data['image'] != null && data['image'].toString().isNotEmpty) return data['image'].toString();
    return '';
  }

  Future<void> removeFromWishlist(BuildContext context, String docId) async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    try {
      await FirebaseFirestore.instance.collection('wishlist').doc(docId).delete();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang.t('Removed from wishlist', 'Đã xóa khỏi yêu thích'))),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${lang.t('Remove failed', 'Xóa thất bại')}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text(lang.t('Please login to view wishlist', 'Vui lòng đăng nhập để xem yêu thích'))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(lang.t('Wishlist', 'Yêu thích'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('wishlist').where('userId', isEqualTo: user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('${lang.t('Error', 'Lỗi')}: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(lang.t('No wishlist yet', 'Chưa có mục yêu thích'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final QueryDocumentSnapshot doc = snapshot.data!.docs[index];
              final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              final String image = getImage(data);

              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: data))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: image.isEmpty
                                ? Container(height: 220, width: double.infinity, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported_outlined, size: 50))
                                : Image.network(image, height: 220, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 220, width: double.infinity, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported_outlined, size: 50))),
                          ),
                          Positioned(top: 12, right: 12, child: GestureDetector(onTap: () => removeFromWishlist(context, doc.id), child: const Icon(Icons.favorite, color: Colors.red, size: 32))),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(data['title']?.toString() ?? lang.t('No title', 'Không có tiêu đề'), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
                            const Icon(Icons.star, size: 16),
                            const SizedBox(width: 4),
                            Text('${data['rating'] ?? 0} (${data['review'] ?? 0})', style: const TextStyle(fontWeight: FontWeight.w500)),
                          ]),
                          const SizedBox(height: 5),
                          Text(data['address']?.toString() ?? lang.t('No address', 'Không có địa chỉ'), style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 5),
                          Text(data['bedAndBathroom']?.toString() ?? '', style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 8),
                          Text('\$${data['price'] ?? 0} ${lang.t('night', 'đêm')}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
