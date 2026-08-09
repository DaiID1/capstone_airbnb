import 'package:capstone_airbnb/provider/language_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapWithCustomInfoWindows extends StatefulWidget {
  const MapWithCustomInfoWindows({super.key});

  @override
  State<MapWithCustomInfoWindows> createState() =>
      _MapWithCustomInfoWindowsState();
}

class _MapWithCustomInfoWindowsState extends State<MapWithCustomInfoWindows> {
  final LatLng vietnamCenter = const LatLng(16.0544, 108.2022);

  final CollectionReference placeCollection =
      FirebaseFirestore.instance.collection('myAppCollection');

  double getDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String getImage(Map<String, dynamic> data) {
    final dynamic imageUrl = data['imageUrl'];

    if (imageUrl is List && imageUrl.isNotEmpty) {
      return imageUrl.first.toString();
    }

    if (data['image'] != null && data['image'].toString().isNotEmpty) {
      return data['image'].toString();
    }

    return '';
  }

  String translateBedAndBath(String value, LanguageProvider lang) {
    if (!lang.isVietnamese) return value;

    return value
        .replaceAll('beds', 'giường')
        .replaceAll('bed', 'giường')
        .replaceAll('bathrooms', 'phòng tắm')
        .replaceAll('bathroom', 'phòng tắm');
  }

  List<Marker> buildMarkers({
    required List<QueryDocumentSnapshot> docs,
    required void Function(Map<String, dynamic>) onSelectPlace,
  }) {
    final List<Marker> result = [];

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final double latitude = getDouble(data['latitude']);
      final double longitude = getDouble(data['longitude']);

      if (latitude == 0 || longitude == 0) continue;

      result.add(
        Marker(
          point: LatLng(latitude, longitude),
          width: 86,
          height: 44,
          child: GestureDetector(
            onTap: () => onSelectPlace(data),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.black12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '\$${data['price'] ?? 0}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final size = MediaQuery.of(context).size;

    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {
        Map<String, dynamic>? selectedPlace;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  height: size.height * 0.77,
                  width: size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: placeCollection.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                '${lang.t('Error', 'Lỗi')}: ${snapshot.error}',
                              ),
                            );
                          }

                          final docs = snapshot.data?.docs ?? [];
                          final markers = buildMarkers(
                            docs: docs,
                            onSelectPlace: (data) {
                              setModalState(() {
                                selectedPlace = data;
                              });
                            },
                          );

                          return FlutterMap(
                            options: MapOptions(
                              initialCenter: vietnamCenter,
                              initialZoom: 5.8,
                              minZoom: 4,
                              maxZoom: 18,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.capstone_airbnb',
                              ),
                              MarkerLayer(markers: markers),
                            ],
                          );
                        },
                      ),

                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 16,
                        right: 16,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),

                      if (selectedPlace != null)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 20,
                          child: Container(
                            height: 145,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 12,
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  child: getImage(selectedPlace!).isEmpty
                                      ? Container(
                                          width: 130,
                                          height: 145,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image_not_supported_outlined,
                                          ),
                                        )
                                      : Image.network(
                                          getImage(selectedPlace!),
                                          width: 130,
                                          height: 145,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 130,
                                              height: 145,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.image_not_supported_outlined,
                                              ),
                                            );
                                          },
                                        ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          selectedPlace!['title']?.toString() ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          selectedPlace!['address']?.toString() ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '\$${selectedPlace!['price'] ?? 0} / ${lang.t('night', 'đêm')}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          translateBedAndBath(
                                            selectedPlace!['bedAndBathroom']?.toString() ?? '',
                                            lang,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      label: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Text(
              lang.t('Map', 'Bản đồ'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.map_outlined, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
