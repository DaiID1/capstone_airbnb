import 'package:capstone_airbnb/Authentication/google_authentication.dart';
import 'package:capstone_airbnb/provider/language_provider.dart';
import 'package:capstone_airbnb/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  lang.t('Log in or sign up', 'Đăng nhập hoặc đăng ký'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(color: Colors.black12),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('Welcome to Airbnb', 'Chào mừng đến với Airbnb'),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    phoneNumberField(size, lang),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: lang.t(
                          'We will call or text you to confirm your number. Standard message and data rates apply.',
                          'Chúng tôi sẽ gọi hoặc nhắn tin để xác nhận số điện thoại của bạn. Phí tin nhắn và dữ liệu tiêu chuẩn có thể được áp dụng.',
                        ),
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: lang.t(' Privacy Policy', ' Chính sách quyền riêng tư'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Container(
                      width: size.width,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          lang.t('Continue', 'Tiếp tục'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.026),
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: Colors.black26),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            lang.t('or', 'hoặc'),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Expanded(
                          child: Container(height: 1, color: Colors.black26),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.026),
                    socialIcons(
                      size,
                      FontAwesomeIcons.facebook,
                      lang.t('Continue with Facebook', 'Tiếp tục với Facebook'),
                      Colors.blue,
                      30,
                    ),
                    InkWell(
                      onTap: () async {
                        await FirebaseAuthServices().signInWithGoogle();
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppMainScreen(),
                          ),
                        );
                      },
                      child: socialIcons(
                        size,
                        FontAwesomeIcons.google,
                        lang.t('Continue with Google', 'Tiếp tục với Google'),
                        Colors.pink,
                        27,
                      ),
                    ),
                    socialIcons(
                      size,
                      FontAwesomeIcons.apple,
                      lang.t('Continue with Apple', 'Tiếp tục với Apple'),
                      Colors.black,
                      30,
                    ),
                    socialIcons(
                      size,
                      FontAwesomeIcons.envelope,
                      lang.t('Continue with Email', 'Tiếp tục với Email'),
                      Colors.black,
                      30,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        lang.t('Need help?', 'Bạn cần trợ giúp?'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding socialIcons(
    Size size,
    FaIconData icon,
    String name,
    Color color,
    double iconSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        width: size.width,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(),
        ),
        child: Row(
          children: [
            SizedBox(width: size.width * 0.05),
            FaIcon(icon, color: color, size: iconSize),
            SizedBox(width: size.width * 0.12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Container phoneNumberField(Size size, LanguageProvider lang) {
    return Container(
      width: size.width,
      height: 130,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10, left: 10, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('Country/Region', 'Quốc gia/Khu vực'),
                  style: const TextStyle(color: Colors.black45),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vietnam(+84)',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    Icon(Icons.keyboard_arrow_down_sharp, size: 30),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: lang.t('Phone number', 'Số điện thoại'),
                hintStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.black45,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
