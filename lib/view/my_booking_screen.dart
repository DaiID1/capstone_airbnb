import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone_airbnb/provider/language_provider.dart';

class MyBookingScreen extends StatelessWidget {
  const MyBookingScreen({super.key});

  String getImage(Map<String, dynamic> data) {
    final dynamic roomImages = data['roomImages'];
    if (roomImages is List && roomImages.isNotEmpty)
      return roomImages.first.toString();
    if (data['roomImage'] != null && data['roomImage'].toString().isNotEmpty)
      return data['roomImage'].toString();
    return '';
  }

  Future<void> cancelBooking(BuildContext context, String docId) async {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    try {
      await FirebaseFirestore.instance.collection('booking').doc(docId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.t('Booking cancelled', 'Đã hủy đặt phòng')),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${lang.t('Cancel failed', 'Hủy thất bại')}: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final CollectionReference bookingCollection = FirebaseFirestore.instance
        .collection('booking');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          lang.t('My Trips', 'Chuyến đi của tôi'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(
              child: Text('${lang.t('Error', 'Lỗi')}: ${snapshot.error}'),
            );
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(
              child: Text(
                lang.t('No trips yet', 'Chưa có chuyến đi'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final booking = snapshot.data!.docs[index];
              final data = booking.data() as Map<String, dynamic>;
              final image = getImage(data);
              final status = data['status']?.toString() ?? 'pending';
              final statusText = status == 'cancelled'
                  ? lang.t('cancelled', 'đã hủy')
                  : lang.t('pending', 'đang chờ');

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: image.isEmpty
                          ? Container(
                              height: 190,
                              width: double.infinity,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                              ),
                            )
                          : Image.network(
                              image,
                              height: 190,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 190,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  data['roomTitle']?.toString() ??
                                      lang.t('No title', 'Không có tiêu đề'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: status == 'cancelled'
                                      ? Colors.grey.shade200
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: status == 'cancelled'
                                        ? Colors.grey
                                        : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data['roomAddress']?.toString() ??
                                lang.t('No address', 'Không có địa chỉ'),
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(data['selectedDateText']?.toString() ?? ''),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.people_alt_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${data['guestTotal'] ?? 0} ${lang.t('guests', 'khách')}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.payments_outlined, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '\$${data['totalPrice'] ?? data['roomPrice'] ?? 0}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (status != 'cancelled')
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () =>
                                    cancelBooking(context, booking.id),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  lang.t('Cancel booking', 'Hủy đặt phòng'),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
