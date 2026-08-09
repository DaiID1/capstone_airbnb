import 'package:capstone_airbnb/provider/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone_airbnb/view/guest_screen.dart';

class BookingDateScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  const BookingDateScreen({super.key, required this.place});

  @override
  State<BookingDateScreen> createState() => _BookingDateScreenState();
}

class _BookingDateScreenState extends State<BookingDateScreen> {
  DateTime? selectedCheckInDate;
  DateTime? selectedCheckOutDate;

  int get pricePerNight {
    final dynamic price = widget.place['price'];
    if (price is int) return price;
    if (price is double) return price.toInt();
    return int.tryParse(price.toString()) ?? 0;
  }

  int get totalNights {
    if (selectedCheckInDate == null || selectedCheckOutDate == null) {
      return 1;
    }

    final int nights = selectedCheckOutDate!
        .difference(selectedCheckInDate!)
        .inDays;
    return nights <= 0 ? 1 : nights;
  }

  int get totalPrice {
    return pricePerNight * totalNights;
  }

  String formatDate(DateTime? date, LanguageProvider lang) {
    if (date == null) return lang.t('Add date', 'Thêm ngày');

    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> pickCheckInDate(LanguageProvider lang) async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedCheckInDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2, 12, 31),
      helpText: lang.t('Select check-in date', 'Chọn ngày nhận phòng'),
      cancelText: lang.t('Cancel', 'Hủy'),
      confirmText: lang.t('OK', 'OK'),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedCheckInDate = pickedDate;

      if (selectedCheckOutDate != null &&
          !selectedCheckOutDate!.isAfter(selectedCheckInDate!)) {
        selectedCheckOutDate = null;
      }
    });
  }

  Future<void> pickCheckOutDate(LanguageProvider lang) async {
    if (selectedCheckInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang.t(
              'Please select check-in date first',
              'Vui lòng chọn ngày nhận phòng trước',
            ),
          ),
        ),
      );
      return;
    }

    final DateTime firstCheckoutDate = selectedCheckInDate!.add(
      const Duration(days: 1),
    );

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedCheckOutDate ?? firstCheckoutDate,
      firstDate: firstCheckoutDate,
      lastDate: DateTime(firstCheckoutDate.year + 2, 12, 31),
      helpText: lang.t('Select check-out date', 'Chọn ngày trả phòng'),
      cancelText: lang.t('Cancel', 'Hủy'),
      confirmText: lang.t('OK', 'OK'),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedCheckOutDate = pickedDate;
    });
  }

  void goToGuestScreen(LanguageProvider lang) {
    if (selectedCheckInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang.t('Please select check-in date', 'Vui lòng chọn ngày nhận phòng'),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuestScreen(
          place: {
            ...widget.place,
            'totalNights': totalNights,
            'totalPrice': totalPrice,
            'checkInDateText': formatDate(selectedCheckInDate, lang),
            'checkOutDateText': formatDate(selectedCheckOutDate, lang),
          },
          selectedDate: selectedCheckInDate!,
        ),
      ),
    );
  }

  Widget dateBox({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_month_outlined),
          ],
        ),
      ),
    );
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
                            lang.t("When's your trip?", 'Khi nào bạn đi?'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          dateBox(
                            title: lang.t('Check-in', 'Nhận phòng'),
                            value: formatDate(selectedCheckInDate, lang),
                            onTap: () => pickCheckInDate(lang),
                          ),
                          dateBox(
                            title: lang.t('Check-out', 'Trả phòng'),
                            value: formatDate(selectedCheckOutDate, lang),
                            onTap: () => pickCheckOutDate(lang),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$totalNights ${lang.t('night(s)', 'đêm')}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
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
                    onPressed: () => goToGuestScreen(lang),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      lang.t('Next', 'Tiếp theo'),
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
}
