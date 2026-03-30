import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:chat_app/views/auth/register_screen.dart';
import 'package:chat_app/views/chat/chat_list_screen.dart';
import 'package:chat_app/widgets/common/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();

  TextEditingController password = TextEditingController();

  void _login() async {
    final authcntroller = context.read<AuthController>();

    bool success = await authcntroller.login(
      email: email.text.trim(),
      password: password.text.trim(),
    );
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Successful')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customfield(hint: 'Email', controller: email, icon: Icons.email),
              SizedBox(height: 20),
              customfield(
                hint: 'Password',
                controller: password,
                icon: Icons.lock,
              ),
              SizedBox(height: 20),
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  return ElevatedButton(
                    onPressed: authController.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(14),
                      ),
                    ),
                    child: authController.isLoading
                        ? const CircularProgressIndicator(color: Colors.blue)
                        : const Text('Sign In'),
                  );
                },
              ),
              //error message
              Consumer<AuthController>(
                builder: (context, authController, child) {
                  if (authController.errorMessage.isEmpty) {
                    return const SizedBox();
                  }
                  return Text(authController.errorMessage);
                },
              ),
              SizedBox(height: 60),
              //register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
