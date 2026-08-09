import 'package:flutter/material.dart';

class AmenitiesScreen extends StatelessWidget {
  final Map<String, dynamic> place;

  const AmenitiesScreen({
    super.key,
    required this.place,
  });

  List<Map<String, dynamic>> getAmenities() {
    final dynamic firestoreAmenities = place['amenities'];

    if (firestoreAmenities is List && firestoreAmenities.isNotEmpty) {
      return firestoreAmenities.map<Map<String, dynamic>>((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }

        return {
          'name': item.toString(),
          'icon': 'check',
        };
      }).toList();
    }

    return [
      {'name': 'River view', 'icon': 'view'},
      {'name': 'Kitchen', 'icon': 'kitchen'},
      {'name': 'Wifi', 'icon': 'wifi'},
      {'name': 'Free parking on premises', 'icon': 'parking'},
      {'name': 'AC - split type ductless system', 'icon': 'ac'},
      {'name': 'TV', 'icon': 'tv'},
      {'name': 'Washer', 'icon': 'washer'},
      {'name': 'Dedicated workspace', 'icon': 'work'},
      {'name': 'Hair dryer', 'icon': 'dryer'},
      {'name': 'Private entrance', 'icon': 'door'},
      {'name': 'Security cameras on property', 'icon': 'camera'},
      {'name': 'Smoke alarm', 'icon': 'alarm'},
    ];
  }

  IconData getAmenityIcon(String iconName) {
    switch (iconName) {
      case 'view':
        return Icons.landscape_outlined;
      case 'kitchen':
        return Icons.kitchen_outlined;
      case 'wifi':
        return Icons.wifi;
      case 'parking':
        return Icons.local_parking_outlined;
      case 'ac':
        return Icons.ac_unit;
      case 'tv':
        return Icons.tv_outlined;
      case 'washer':
        return Icons.local_laundry_service_outlined;
      case 'work':
        return Icons.work_outline;
      case 'dryer':
        return Icons.dry_cleaning_outlined;
      case 'door':
        return Icons.door_front_door_outlined;
      case 'camera':
        return Icons.videocam_outlined;
      case 'alarm':
        return Icons.smoke_free_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final amenities = getAmenities();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'What this place offers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: amenities.length,
        separatorBuilder: (context, index) {
          return const Divider(height: 28);
        },
        itemBuilder: (context, index) {
          final amenity = amenities[index];
          final String name = amenity['name']?.toString() ?? '';
          final String icon = amenity['icon']?.toString() ?? 'check';

          return Row(
            children: [
              Icon(
                getAmenityIcon(icon),
                size: 26,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
