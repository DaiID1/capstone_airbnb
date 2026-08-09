import 'package:provider/provider.dart';
import 'package:capstone_airbnb/provider/language_provider.dart';
import 'package:capstone_airbnb/view/explore_screen.dart';
import 'package:capstone_airbnb/view/message_screen.dart';
import 'package:capstone_airbnb/view/my_booking_screen.dart';
import 'package:capstone_airbnb/view/profile_screen.dart';
import 'package:capstone_airbnb/view/wishlist_screen.dart';
import 'package:flutter/material.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late final List<Widget> page;

  @override
  void initState() {
    super.initState();
    page = [
      const ExploreScreen(),
      const WishlistScreen(),
      const MyBookingScreen(),
      const MessageScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: page[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 5,
        iconSize: 32,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.explore_outlined,
              size: 30,
              color: selectedIndex == 0 ? Colors.pinkAccent : Colors.black54,
            ),
            label: lang.t('Explore', 'Khám phá'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border,
              size: 30,
              color: selectedIndex == 1 ? Colors.pinkAccent : Colors.black54,
            ),
            label: lang.t('Wishlist', 'Yêu thích'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.airplane_ticket_outlined,
              size: 30,
              color: selectedIndex == 2 ? Colors.pinkAccent : Colors.black54,
            ),
            label: lang.t('Trip', 'Chuyến đi'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.message,
              size: 30,
              color: selectedIndex == 3 ? Colors.pinkAccent : Colors.black54,
            ),
            label: lang.t('Message', 'Tin nhắn'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
              color: selectedIndex == 4 ? Colors.pinkAccent : Colors.black54,
            ),
            label: lang.t('Profile', 'Hồ sơ'),
          ),
        ],
      ),
    );
  }
}
