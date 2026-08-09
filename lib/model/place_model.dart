import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> savePlacesToFirebase() async {
  final CollectionReference ref = FirebaseFirestore.instance.collection(
    "myAppCollection",
  );
  for (final Place place in listOfPlaces) {
    final String id =
        DateTime.now().toIso8601String() + Random().nextInt(1000).toString();
    ref.doc("das");
    await ref.doc(id).set(place.toMap());
  }
}

class Place {
  final String title;
  bool isActive;
  final String image;
  final double rating;
  final String date;
  final int price;
  final String address;
  final String vendor;
  final String vendorProfession;
  final String vendorProfile;
  final int review;
  final String bedAndBathroom;
  final int yearOfHostin;
  final double latitude;
  final double longitude;
  final List<String> imageUrl;

  Place({
    required this.isActive,
    required this.title,
    required this.image,
    required this.rating,
    required this.review,
    required this.bedAndBathroom,
    required this.date,
    required this.price,
    required this.address,
    required this.vendor,
    required this.vendorProfession,
    required this.vendorProfile,
    required this.yearOfHostin,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isActive': isActive,
      'title': title,
      'image': image,
      'rating': rating,
      'review': review,
      'bedAndBathroom': bedAndBathroom,
      'date': date,
      'price': price,
      'address': address,
      'vendor': vendor,
      'vendorProfession': vendorProfession,
      'vendorProfile': vendorProfile,
      'yearOfHostin': yearOfHostin,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
    };
  }
}

final List<Place> listOfPlaces = [
  Place(
    isActive: true,
    title: "Căn hộ view biển Mỹ Khê",
    image:
        "https://cf.bstatic.com/xdata/images/hotel/max1024x768/320552632.jpg?k=899a45f007c34bc015a4321832994792dcf7fb6d6ed4d43f1fdc0232584256f1&o=",
    rating: 4.88,
    review: 214,
    bedAndBathroom: "2 beds · 2 bathrooms",
    date: "2026-08-21",
    price: 72,
    address: "Đà Nẵng, Việt Nam",
    vendor: "Minh Nguyễn",
    vendorProfession: "Chủ nhà địa phương",
    vendorProfile: "https://picsum.photos/id/1005/300/300",
    yearOfHostin: 2021,
    latitude: 16.0544,
    longitude: 108.2022,
    imageUrl: [
      "https://cf.bstatic.com/xdata/images/hotel/max1024x768/320552632.jpg?k=899a45f007c34bc015a4321832994792dcf7fb6d6ed4d43f1fdc0232584256f1&o=",
      "https://cf.bstatic.com/xdata/images/hotel/max500/901180686.jpg?k=7c69e2a8eeac5e1a9a1f55c3864aa6af7cac59141c55f45489a0233c3254ee68&o=",
      "https://cf.bstatic.com/xdata/images/hotel/max500/320552630.jpg?k=f44881a64f18cf993c7043de02a88df802e66b457ecb6b8534b5f9db4b62b066&o=",
    ],
  ),

  Place(
    isActive: true,
    title: "Hotel",
    image:
        "https://cf.bstatic.com/xdata/images/hotel/max500/460405082.jpg?k=007ba8488967e0f44e4be0168b8428941b30a82b57ab1984a8bebb92d88b1218&o=",
    rating: 4.76,
    review: 138,
    bedAndBathroom: "2 bed · 1 bathroom",
    date: "2026-08-22",
    price: 48,
    address: "Hải Châu, Đà Nẵng, Việt Nam",
    vendor: "Lan Trần",
    vendorProfession: "Apartment Host",
    vendorProfile: "https://picsum.photos/id/1011/300/300",
    yearOfHostin: 2022,
    latitude: 16.0678,
    longitude: 108.2208,
    imageUrl: [
      "https://cf.bstatic.com/xdata/images/hotel/max500/460405082.jpg?k=007ba8488967e0f44e4be0168b8428941b30a82b57ab1984a8bebb92d88b1218&o=",
      "https://cf.bstatic.com/xdata/images/hotel/max300/460405875.jpg?k=3c24825d31b7729fcf13209c84b48b4bcd746d7b4d821068cb6b2c4c1c2e7cb4&o=",
      "https://cf.bstatic.com/xdata/images/hotel/max1024x768/460405115.jpg?k=9a10c34f32eeb5167d4dea49851a1dadfe10940632463f10288836ea47eed5ab&o=",
    ],
  ),

  Place(
    isActive: true,
    title: "NA Hoian Hotel",
    image:
        "https://cf.bstatic.com/xdata/images/hotel/max1024x768/814090334.jpg?k=31cf7a6b212adb74861d3441642ef532e122942415e3f24785a09f56a63457a0&o=",
    rating: 4.91,
    review: 302,
    bedAndBathroom: "2 beds · 1 bathroom",
    date: "2026-08-23",
    price: 61,
    address: "Hội An, Quảng Nam, Việt Nam",
    vendor: "Thu Hoàng",
    vendorProfession: "Homestay Owner",
    vendorProfile: "https://picsum.photos/id/1012/300/300",
    yearOfHostin: 2019,
    latitude: 15.8801,
    longitude: 108.3380,
    imageUrl: [
      "https://cf.bstatic.com/xdata/images/hotel/max1024x768/814090334.jpg?k=31cf7a6b212adb74861d3441642ef532e122942415e3f24785a09f56a63457a0&o=",
      "https://cf.bstatic.com/xdata/images/hotel/max500/806395472.jpg?k=b00cd67d4c45e8f2aeaeee1015ac75ba911ed059a21690ab1a1fd7156cb349ba&o=",
      "https://cf.bstatic.com/xdata/images/hotel/max300/806390086.jpg?k=e62215ec62d0ac49622761bf313533dc74780f82b1c28ce14060a074e879eea8&o=",
    ],
  ),

  Place(
    isActive: true,
    title: "Villa sân vườn bên sông Thu Bồn",
    image: "https://picsum.photos/id/1056/1000/700",
    rating: 4.84,
    review: 167,
    bedAndBathroom: "3 beds · 2 bathrooms",
    date: "2026-08-24",
    price: 95,
    address: "Cẩm Thanh, Hội An, Việt Nam",
    vendor: "An Phạm",
    vendorProfession: "Villa Host",
    vendorProfile: "https://picsum.photos/id/1027/300/300",
    yearOfHostin: 2020,
    latitude: 15.8700,
    longitude: 108.3800,
    imageUrl: [
      "https://picsum.photos/id/1056/1000/700",
      "https://picsum.photos/id/1057/1000/700",
      "https://picsum.photos/id/1058/1000/700",
    ],
  ),

  Place(
    isActive: true,
    title: "Căn hộ hướng biển Trần Phú",
    image: "https://picsum.photos/id/1063/1000/700",
    rating: 4.79,
    review: 184,
    bedAndBathroom: "2 beds · 2 bathrooms",
    date: "2026-08-25",
    price: 68,
    address: "Nha Trang, Khánh Hòa, Việt Nam",
    vendor: "Hải Lê",
    vendorProfession: "Property Manager",
    vendorProfile: "https://picsum.photos/id/1015/300/300",
    yearOfHostin: 2021,
    latitude: 12.2388,
    longitude: 109.1967,
    imageUrl: [
      "https://picsum.photos/id/1063/1000/700",
      "https://picsum.photos/id/1064/1000/700",
      "https://picsum.photos/id/1065/1000/700",
    ],
  ),

  Place(
    isActive: true,
    title: "Phòng nghỉ gần biển Hòn Chồng",
    image: "https://picsum.photos/id/1074/1000/700",
    rating: 4.67,
    review: 96,
    bedAndBathroom: "1 bed · 1 bathroom",
    date: "2026-08-26",
    price: 42,
    address: "Vĩnh Phước, Nha Trang, Việt Nam",
    vendor: "Vy Đặng",
    vendorProfession: "Local Host",
    vendorProfile: "https://picsum.photos/id/1016/300/300",
    yearOfHostin: 2023,
    latitude: 12.2680,
    longitude: 109.2040,
    imageUrl: [
      "https://picsum.photos/id/1074/1000/700",
      "https://picsum.photos/id/1075/1000/700",
      "https://picsum.photos/id/1076/1000/700",
    ],
  ),

  Place(
    isActive: true,
    title: "Cabin gỗ giữa rừng thông",
    image: "https://picsum.photos/id/1020/1000/700",
    rating: 4.95,
    review: 276,
    bedAndBathroom: "2 beds · 1 bathroom",
    date: "2026-08-27",
    price: 78,
    address: "Đà Lạt, Lâm Đồng, Việt Nam",
    vendor: "Bảo Lâm",
    vendorProfession: "Cabin Host",
    vendorProfile: "https://picsum.photos/id/1025/300/300",
    yearOfHostin: 2018,
    latitude: 11.9404,
    longitude: 108.4583,
    imageUrl: [
      "https://picsum.photos/id/1020/1000/700",
      "https://picsum.photos/id/1024/1000/700",
      "https://picsum.photos/id/1029/1000/700",
    ],
  ),

  Place(
    isActive: true,
    title: "Home Đà Lạt có ban công săn mây",
    image: "https://picsum.photos/id/1080/1000/700",
    rating: 4.82,
    review: 143,
    bedAndBathroom: "1 bed · 1 bathroom",
    date: "2026-08-28",
    price: 55,
    address: "Phường 3, Đà Lạt, Việt Nam",
    vendor: "Mai Anh",
    vendorProfession: "Homestay Host",
    vendorProfile: "https://picsum.photos/id/1024/300/300",
    yearOfHostin: 2022,
    latitude: 11.9359,
    longitude: 108.4429,
    imageUrl: [
      "https://picsum.photos/id/1080/1000/700",
      "https://picsum.photos/id/1081/1000/700",
      "https://picsum.photos/id/1082/1000/700",
    ],
  ),

  Place(
    isActive: true,
    title: "Bungalow sát biển Phú Quốc",
    image: "https://picsum.photos/id/1016/1000/700",
    rating: 4.89,
    review: 221,
    bedAndBathroom: "1 bed · 1 bathroom",
    date: "2026-08-29",
    price: 88,
    address: "Phú Quốc, Kiên Giang, Việt Nam",
    vendor: "Quốc Bảo",
    vendorProfession: "Resort Host",
    vendorProfile: "https://picsum.photos/id/1001/300/300",
    yearOfHostin: 2020,
    latitude: 10.2899,
    longitude: 103.9840,
    imageUrl: [
      "https://picsum.photos/id/1016/1000/700",
      "https://picsum.photos/id/1019/1000/700",
      "https://picsum.photos/id/1021/1000/700",
    ],
  ),

  Place(
    isActive: true,
    title: "Villa hồ bơi gần Bãi Sao",
    image: "https://picsum.photos/id/1050/1000/700",
    rating: 4.93,
    review: 188,
    bedAndBathroom: "3 beds · 3 bathrooms",
    date: "2026-08-30",
    price: 145,
    address: "An Thới, Phú Quốc, Việt Nam",
    vendor: "Ngọc Hà",
    vendorProfession: "Luxury Stay Host",
    vendorProfile: "https://picsum.photos/id/1006/300/300",
    yearOfHostin: 2019,
    latitude: 10.0430,
    longitude: 104.0400,
    imageUrl: [
      "https://picsum.photos/id/1050/1000/700",
      "https://picsum.photos/id/1051/1000/700",
      "https://picsum.photos/id/1052/1000/700",
    ],
  ),

  Place(
    isActive: true,
    title: "Căn hộ phố cổ Hà Nội",
    image: "https://picsum.photos/id/1060/1000/700",
    rating: 4.73,
    review: 198,
    bedAndBathroom: "2 beds · 1 bathroom",
    date: "2026-08-31",
    price: 64,
    address: "Hoàn Kiếm, Hà Nội, Việt Nam",
    vendor: "Trang Vũ",
    vendorProfession: "Apartment Host",
    vendorProfile: "https://picsum.photos/id/1018/300/300",
    yearOfHostin: 2021,
    latitude: 21.0285,
    longitude: 105.8542,
    imageUrl: [
      "https://picsum.photos/id/1060/1000/700",
      "https://picsum.photos/id/1061/1000/700",
      "https://picsum.photos/id/1062/1000/700",
    ],
  ),

  Place(
    isActive: true,
    title: "Loft hiện đại trung tâm Sài Gòn",
    image: "https://picsum.photos/id/1067/1000/700",
    rating: 4.81,
    review: 256,
    bedAndBathroom: "1 bed · 1 bathroom",
    date: "2026-09-01",
    price: 59,
    address: "Quận 1, TP. Hồ Chí Minh, Việt Nam",
    vendor: "Khoa Trần",
    vendorProfession: "City Host",
    vendorProfile: "https://picsum.photos/id/1019/300/300",
    yearOfHostin: 2020,
    latitude: 10.7769,
    longitude: 106.7009,
    imageUrl: [
      "https://picsum.photos/id/1067/1000/700",
      "https://picsum.photos/id/1068/1000/700",
      "https://picsum.photos/id/1069/1000/700",
    ],
  ),

  Place(
    isActive: true,
    title: "Căn hộ view vịnh Hạ Long",
    image: "https://picsum.photos/id/1039/1000/700",
    rating: 4.87,
    review: 172,
    bedAndBathroom: "2 beds · 2 bathrooms",
    date: "2026-09-02",
    price: 82,
    address: "Hạ Long, Quảng Ninh, Việt Nam",
    vendor: "Tuấn Anh",
    vendorProfession: "Bay View Host",
    vendorProfile: "https://picsum.photos/id/1020/300/300",
    yearOfHostin: 2022,
    latitude: 20.9712,
    longitude: 107.0448,
    imageUrl: [
      "https://picsum.photos/id/1039/1000/700",
      "https://picsum.photos/id/1040/1000/700",
      "https://picsum.photos/id/1041/1000/700",
    ],
  ),

  Place(
    isActive: true,
    title: "Nhà nghỉ view núi Sa Pa",
    image: "https://picsum.photos/id/1003/1000/700",
    rating: 4.9,
    review: 219,
    bedAndBathroom: "2 beds · 1 bathroom",
    date: "2026-09-03",
    price: 57,
    address: "Sa Pa, Lào Cai, Việt Nam",
    vendor: "Sơn Lý",
    vendorProfession: "Mountain Host",
    vendorProfile: "https://picsum.photos/id/1021/300/300",
    yearOfHostin: 2019,
    latitude: 22.3364,
    longitude: 103.8438,
    imageUrl: [
      "https://picsum.photos/id/1003/1000/700",
      "https://picsum.photos/id/1004/1000/700",
      "https://picsum.photos/id/1008/1000/700",
    ],
  ),

  Place(
    isActive: true,
    title: "Homestay gần Đại Nội Huế",
    image: "https://picsum.photos/id/1048/1000/700",
    rating: 4.74,
    review: 127,
    bedAndBathroom: "1 bed · 1 bathroom",
    date: "2026-09-04",
    price: 41,
    address: "Huế, Thừa Thiên Huế, Việt Nam",
    vendor: "Hạnh Nguyễn",
    vendorProfession: "Heritage Host",
    vendorProfile: "https://picsum.photos/id/1022/300/300",
    yearOfHostin: 2023,
    latitude: 16.4637,
    longitude: 107.5909,
    imageUrl: [
      "https://picsum.photos/id/1048/1000/700",
      "https://picsum.photos/id/1049/1000/700",
      "https://picsum.photos/id/1053/1000/700",
    ],
  ),
];
