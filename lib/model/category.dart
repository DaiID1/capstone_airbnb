import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveCategoryItems() async {
  final CollectionReference ref = FirebaseFirestore.instance.collection(
    'AppCategory',
  );

  for (final Category category in categoryList) {
    await ref.doc(category.key).set(category.toMap());
  }
}

class Category {
  final String key;
  final String title;
  final String titleVi;
  final String image;

  Category({
    required this.key,
    required this.title,
    required this.titleVi,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {'key': key, 'title': title, 'titleVi': titleVi, 'image': image};
  }
}

final List<Category> categoryList = [
  Category(
    key: 'all',
    title: 'All',
    titleVi: 'Tất cả',
    image: 'https://cdn-icons-png.flaticon.com/512/6192/6192020.png',
  ),
  Category(
    key: 'beach',
    title: 'Beach',
    titleVi: 'Biển',
    image: 'https://cdn-icons-png.flaticon.com/128/2664/2664589.png',
  ),
  Category(
    key: 'mountain',
    title: 'Mountain',
    titleVi: 'Núi',
    image: 'https://cdn-icons-png.flaticon.com/128/12220/12220991.png',
  ),
  Category(
    key: 'city',
    title: 'City',
    titleVi: 'Thành phố',
    image: 'https://cdn-icons-png.flaticon.com/128/269/269947.png',
  ),
  Category(
    key: 'villa',
    title: 'Villa',
    titleVi: 'Villa',
    image: 'https://cdn-icons-png.flaticon.com/128/3446/3446684.png',
  ),
  Category(
    key: 'homestay',
    title: 'Homestay',
    titleVi: 'Homestay',
    image: 'https://cdn-icons-png.flaticon.com/128/9771/9771265.png',
  ),
];
