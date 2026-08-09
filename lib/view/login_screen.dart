import 'package:capstone_airbnb/Authentication/email_authentication.dart';
import 'package:capstone_airbnb/Authentication/google_authentication.dart';
import 'package:capstone_airbnb/Components/login/social_login_button.dart';
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
  void goToMainScreen() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppMainScreen()),
      (route) => false,
    );
  }

  void showComingSoon(String featureName, LanguageProvider lang) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang.isVietnamese
              ? '$featureName chưa được hỗ trợ trong bản demo'
              : '$featureName is not available in this demo',
        ),
      ),
    );
  }

  void showHelpDialog(LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(lang.t('Need help?', 'Bạn cần trợ giúp?')),
          content: Text(
            lang.t(
              'You can login with Google or Email. Phone, Facebook and Apple login are not available in this demo.',
              'Bạn có thể đăng nhập bằng Google hoặc Email. Đăng nhập bằng số điện thoại, Facebook và Apple chưa được hỗ trợ trong bản demo.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> loginWithEmail(LanguageProvider lang) async {
    final bool success = await EmailAuthentication.showEmailLoginDialog(
      context: context,
      lang: lang,
    );

    if (success && mounted) {
      goToMainScreen();
    }
  }

  Future<void> loginWithGoogle() async {
    final userCredential = await FirebaseAuthServices().signInWithGoogle();

    if (userCredential == null) {
      return;
    }

    if (!mounted) return;

    goToMainScreen();
  }

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
                    SizedBox(height: size.height * 0.03),
                    Text(
                      lang.t(
                        'Continue with your Google account or email address to use the app.',
                        'Tiếp tục bằng tài khoản Google hoặc địa chỉ Email để sử dụng ứng dụng.',
                      ),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    GestureDetector(
                      onTap: () {
                        loginWithEmail(lang);
                      },
                      child: Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            lang.t('Continue with Email', 'Tiếp tục với Email'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
                    SocialLoginButton(
                      size: size,
                      icon: FontAwesomeIcons.google,
                      label: lang.t(
                        'Continue with Google',
                        'Tiếp tục với Google',
                      ),
                      iconColor: Colors.pink,
                      iconSize: 27,
                      onTap: loginWithGoogle,
                    ),
                    SocialLoginButton(
                      size: size,
                      icon: FontAwesomeIcons.envelope,
                      label: lang.t(
                        'Continue with Email',
                        'Tiếp tục với Email',
                      ),
                      iconColor: Colors.black,
                      iconSize: 30,
                      onTap: () {
                        loginWithEmail(lang);
                      },
                    ),
                    SocialLoginButton(
                      size: size,
                      icon: FontAwesomeIcons.facebook,
                      label: lang.t(
                        'Continue with Facebook',
                        'Tiếp tục với Facebook',
                      ),
                      iconColor: Colors.blue,
                      iconSize: 30,
                      onTap: () {
                        showComingSoon(
                          lang.t('Facebook login', 'Đăng nhập bằng Facebook'),
                          lang,
                        );
                      },
                    ),
                    SocialLoginButton(
                      size: size,
                      icon: FontAwesomeIcons.apple,
                      label: lang.t(
                        'Continue with Apple',
                        'Tiếp tục với Apple',
                      ),
                      iconColor: Colors.black,
                      iconSize: 30,
                      onTap: () {
                        showComingSoon(
                          lang.t('Apple login', 'Đăng nhập bằng Apple'),
                          lang,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          showHelpDialog(lang);
                        },
                        child: Text(
                          lang.t('Need help?', 'Bạn cần trợ giúp?'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            decoration: TextDecoration.underline,
                          ),
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
}
