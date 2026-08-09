import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:capstone_airbnb/view/place_detail_screen.dart';

class SearchResultScreen extends StatelessWidget {
  final String searchText;

  const SearchResultScreen({super.key, required this.searchText});

  bool placeMatchesSearch(Map<String, dynamic> data) {
    final String keyword = searchText.toLowerCase().trim();
    final String address = (data['address'] ?? '').toString().toLowerCase();
    final String title = (data['title'] ?? '').toString().toLowerCase();

    return address.contains(keyword) || title.contains(keyword);
  }

  String getImageUrl(Map<String, dynamic> data) {
    final dynamic imageUrl = data['imageUrl'];

    if (imageUrl is List && imageUrl.isNotEmpty) {
      return imageUrl.first.toString();
    }

    if (imageUrl is String && imageUrl.isNotEmpty) {
      return imageUrl;
    }

    if (data['image'] != null && data['image'].toString().isNotEmpty) {
      return data['image'].toString();
    }

    return '';
  }

  void openPlaceDetail(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference placeCollection = FirebaseFirestore.instance
        .collection('myAppCollection');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          searchText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: placeCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No rooms found'));
          }

          final List<QueryDocumentSnapshot> results = snapshot.data!.docs.where(
            (doc) {
              final data = doc.data() as Map<String, dynamic>;
              return placeMatchesSearch(data);
            },
          ).toList();

          if (results.isEmpty) {
            return Center(child: Text('No rooms found for "$searchText"'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final data = results[index].data() as Map<String, dynamic>;
              final String image = getImageUrl(data);

              return GestureDetector(
                onTap: () {
                  openPlaceDetail(context, data);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
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
                                height: 220,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 50,
                                ),
                              )
                            : Image.network(
                                image,
                                height: 220,
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
                              data['title']?.toString() ?? 'No title',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              data['address']?.toString() ?? 'No address',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              data['bedAndBathroom']?.toString() ?? '',
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '\$${data['price'] ?? 0} / night',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.star, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${data['rating'] ?? 0} (${data['review'] ?? 0})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
