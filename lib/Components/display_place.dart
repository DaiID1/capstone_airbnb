import 'package:provider/provider.dart';
import 'package:capstone_airbnb/provider/language_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:capstone_airbnb/view/place_detail_screen.dart';

class DisplayPlace extends StatelessWidget {
  const DisplayPlace({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final CollectionReference placeCollection =
        FirebaseFirestore.instance.collection('myAppCollection');

    return StreamBuilder<QuerySnapshot>(
      stream: placeCollection.snapshots(),
      builder: (context, streamSnapshot) {
        if (streamSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (streamSnapshot.hasError) {
          return Center(
            child: Text('${lang.t('Error', 'Lỗi')}: ${streamSnapshot.error}'),
          );
        }

        if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(lang.t('No places found', 'Không tìm thấy chỗ ở')),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: streamSnapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final place = streamSnapshot.data!.docs[index];
            return PlaceCard(place: place);
          },
        );
      },
    );
  }
}

class PlaceCard extends StatefulWidget {
  final QueryDocumentSnapshot place;

  const PlaceCard({super.key, required this.place});

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  int activeIndex = 0;

  Map<String, dynamic> get placeData {
    return widget.place.data() as Map<String, dynamic>;
  }

  String get wishlistDocId {
    final User? user = FirebaseAuth.instance.currentUser;
    return '${user?.uid ?? 'guest'}_${widget.place.id}';
  }

  List<dynamic> get images {
    final data = placeData;

    if (data['imageUrl'] is List && data['imageUrl'].isNotEmpty) {
      return data['imageUrl'];
    }

    if (data['image'] != null && data['image'].toString().isNotEmpty) {
      return [data['image']];
    }

    return [];
  }

  void openPlaceDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceDetailScreen(place: placeData),
      ),
    );
  }

  Future<void> toggleWishlist(bool isWishlisted) async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang.t(
              'Please login to use wishlist',
              'Vui lòng đăng nhập để dùng danh sách yêu thích',
            ),
          ),
        ),
      );
      return;
    }

    final DocumentReference wishlistRef = FirebaseFirestore.instance
        .collection('wishlist')
        .doc(wishlistDocId);

    if (isWishlisted) {
      await wishlistRef.delete();
    } else {
      await wishlistRef.set({
        ...placeData,
        'placeId': widget.place.id,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  String translateBedAndBath(String value, LanguageProvider lang) {
    if (!lang.isVietnamese) return value;

    return value
        .replaceAll('beds', 'giường')
        .replaceAll('bed', 'giường')
        .replaceAll('bathrooms', 'phòng tắm')
        .replaceAll('bathroom', 'phòng tắm')
        .replaceAll('Private', 'Riêng')
        .replaceAll('Shared', 'Chung')
        .replaceAll('share', 'chung');
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final data = placeData;
    final placeImages = images;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: openPlaceDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: placeImages.isEmpty
                      ? Container(
                          height: 360,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                          ),
                        )
                      : CarouselSlider(
                          items: placeImages.map<Widget>((url) {
                            return Image.network(
                              url.toString(),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 50,
                                  ),
                                );
                              },
                            );
                          }).toList(),
                          options: CarouselOptions(
                            height: 360,
                            viewportFraction: 1,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 3),
                            onPageChanged: (index, reason) {
                              setState(() {
                                activeIndex = index;
                              });
                            },
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('wishlist')
                        .doc(wishlistDocId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final bool isWishlisted = snapshot.data?.exists ?? false;

                      return GestureDetector(
                        onTap: () {
                          toggleWishlist(isWishlisted);
                        },
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.white,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
                if (placeImages.isNotEmpty)
                  Positioned(
                    bottom: 12,
                    child: AnimatedSmoothIndicator(
                      activeIndex: activeIndex,
                      count: placeImages.length,
                      effect: const WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Colors.white,
                        dotColor: Colors.white54,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['title']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(
                      '${data['rating'] ?? 0} (${data['review'] ?? 0})',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              data['address']?.toString() ?? '',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              translateBedAndBath(
                data['bedAndBathroom']?.toString() ?? '',
                lang,
              ),
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              data['date']?.toString() ?? '',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${data['price'] ?? 0} ${lang.t('night', 'đêm')}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
