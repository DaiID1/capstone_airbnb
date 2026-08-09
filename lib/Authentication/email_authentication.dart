import 'package:capstone_airbnb/provider/language_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailAuthentication {
  static Future<bool> showEmailLoginDialog({
    required BuildContext context,
    required LanguageProvider lang,
  }) async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    bool isRegister = false;
    bool isLoading = false;

    final bool? success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submitEmailAuth() async {
              final String email = emailController.text.trim();
              final String password = passwordController.text.trim();

              if (email.isEmpty || password.isEmpty) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      lang.t(
                        'Please enter email and password',
                        'Vui lòng nhập email và mật khẩu',
                      ),
                    ),
                  ),
                );
                return;
              }

              setDialogState(() {
                isLoading = true;
              });

              try {
                UserCredential userCredential;

                if (isRegister) {
                  userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                } else {
                  userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                }

                if (userCredential.user == null) {
                  setDialogState(() {
                    isLoading = false;
                  });
                  return;
                }

                FocusManager.instance.primaryFocus?.unfocus();

                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } on FirebaseAuthException catch (e) {
                String message = lang.t(
                  'Authentication failed',
                  'Đăng nhập thất bại',
                );

                if (e.code == 'email-already-in-use') {
                  message = lang.t(
                    'This email is already in use',
                    'Email này đã được sử dụng',
                  );
                } else if (e.code == 'weak-password') {
                  message = lang.t('Password is too weak', 'Mật khẩu quá yếu');
                } else if (e.code == 'user-not-found') {
                  message = lang.t(
                    'No account found with this email',
                    'Không tìm thấy tài khoản với email này',
                  );
                } else if (e.code == 'wrong-password') {
                  message = lang.t('Wrong password', 'Sai mật khẩu');
                } else if (e.code == 'invalid-email') {
                  message = lang.t('Invalid email', 'Email không hợp lệ');
                }

                messenger.showSnackBar(SnackBar(content: Text(message)));

                setDialogState(() {
                  isLoading = false;
                });
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('${lang.t('Error', 'Lỗi')}: $e')),
                );

                setDialogState(() {
                  isLoading = false;
                });
              }
            }

            return AlertDialog(
              title: Text(
                isRegister
                    ? lang.t('Create account', 'Tạo tài khoản')
                    : lang.t('Login with Email', 'Đăng nhập bằng Email'),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: lang.t('Email', 'Email'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: lang.t('Password', 'Mật khẩu'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setDialogState(() {
                        isRegister = !isRegister;
                      });
                    },
                    child: Text(
                      isRegister
                          ? lang.t(
                              'Already have an account? Login',
                              'Đã có tài khoản? Đăng nhập',
                            )
                          : lang.t(
                              'No account? Create one',
                              'Chưa có tài khoản? Tạo tài khoản',
                            ),
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: Text(lang.t('Cancel', 'Hủy')),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : submitEmailAuth,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
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
                          isRegister
                              ? lang.t('Register', 'Đăng ký')
                              : lang.t('Login', 'Đăng nhập'),
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    emailController.dispose();
    passwordController.dispose();

    return success == true;
  }
}
