import 'package:capstone_airbnb/provider/language_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GuestScreen extends StatefulWidget {
  final Map<String, dynamic> place;
  final DateTime selectedDate;

  const GuestScreen({
    super.key,
    required this.place,
    required this.selectedDate,
  });

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  int adults = 0;
  int children = 0;
  int infants = 0;
  int pets = 0;
  bool isLoading = false;

  int get pricePerNight {
    final dynamic price = widget.place['price'];
    if (price is int) return price;
    if (price is double) return price.toInt();
    return int.tryParse(price.toString()) ?? 0;
  }

  int get guestTotal {
    return adults + children + infants + pets;
  }

  int get totalNights {
    final dynamic nights = widget.place['totalNights'];
    if (nights is int) return nights;
    return int.tryParse(nights?.toString() ?? '') ?? 1;
  }

  int get totalPrice {
    final dynamic total = widget.place['totalPrice'];
    if (total is int) return total;
    return int.tryParse(total?.toString() ?? '') ?? pricePerNight * totalNights;
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> reserveRoom(LanguageProvider lang) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang.t(
              'Please login before booking',
              'Vui lòng đăng nhập trước khi đặt phòng',
            ),
          ),
        ),
      );
      return;
    }

    if (adults == 0 && children == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang.t(
              'Please add at least 1 adult or child',
              'Vui lòng thêm ít nhất 1 người lớn hoặc trẻ em',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('booking').add({
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'userName': user.displayName ?? 'Guest',
        'roomTitle': widget.place['title'] ?? '',
        'roomAddress': widget.place['address'] ?? '',
        'roomImage': widget.place['image'] ?? '',
        'roomImages': widget.place['imageUrl'] ?? [],
        'roomPrice': pricePerNight,
        'totalNights': totalNights,
        'checkInDateText':
            widget.place['checkInDateText'] ?? formatDate(widget.selectedDate),
        'checkOutDateText': widget.place['checkOutDateText'] ?? '',
        'selectedDate': Timestamp.fromDate(widget.selectedDate),
        'selectedDateText': formatDate(widget.selectedDate),
        'adults': adults,
        'children': children,
        'infants': infants,
        'pets': pets,
        'guestTotal': guestTotal,
        'totalPrice': totalPrice,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang.t('Reservation saved successfully', 'Đặt phòng thành công'),
          ),
        ),
      );

      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${lang.t('Reservation failed', 'Đặt phòng thất bại')}: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void increase(String type) {
    setState(() {
      if (type == 'adults') adults++;
      if (type == 'children') children++;
      if (type == 'infants') infants++;
      if (type == 'pets') pets++;
    });
  }

  void decrease(String type) {
    setState(() {
      if (type == 'adults' && adults > 0) adults--;
      if (type == 'children' && children > 0) children--;
      if (type == 'infants' && infants > 0) infants--;
      if (type == 'pets' && pets > 0) pets--;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.t("Who's coming?", 'Ai sẽ đi cùng?'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          guestRow(
                            title: lang.t('Adults', 'Người lớn'),
                            subtitle: lang.t(
                              'Ages 13 or above',
                              'Từ 13 tuổi trở lên',
                            ),
                            value: adults,
                            type: 'adults',
                          ),
                          guestRow(
                            title: lang.t('Children', 'Trẻ em'),
                            subtitle: lang.t('Ages 2-12', 'Từ 2 đến 12 tuổi'),
                            value: children,
                            type: 'children',
                          ),
                          guestRow(
                            title: lang.t('Infants', 'Em bé'),
                            subtitle: lang.t('Under 2', 'Dưới 2 tuổi'),
                            value: infants,
                            type: 'infants',
                          ),
                          guestRow(
                            title: lang.t('Pets', 'Thú cưng'),
                            subtitle: lang.t(
                              'Bringing a service animal?',
                              'Bạn có mang theo động vật hỗ trợ không?',
                            ),
                            value: pets,
                            type: 'pets',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${lang.t('Total', 'Tổng cộng')}: \$$totalPrice',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => reserveRoom(lang),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            lang.t('Reserve', 'Đặt phòng'),
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget guestRow({
    required String title,
    required String subtitle,
    required int value,
    required String type,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          circularButton(icon: Icons.remove, onTap: () => decrease(type)),
          const SizedBox(width: 12),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          circularButton(icon: Icons.add, onTap: () => increase(type)),
        ],
      ),
    );
  }

  Widget circularButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
