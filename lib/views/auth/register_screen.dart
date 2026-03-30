import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/utils/app_colors.dart';
import 'package:chat_app/widgets/common/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

TextEditingController name = TextEditingController();
TextEditingController email = TextEditingController();
TextEditingController password = TextEditingController();

class _RegisterPageState extends State<RegisterPage> {
  void _register() async {
    final authcontroller = context.read<AuthController>();

    bool success = await authcontroller.register(
      name: name.text.trim(),
      email: email.text.trim(),
      password: password.text.trim(),
    );
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Account created successfully')));
      Navigator.pop(context);
  
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.Primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customfield(
                hint: 'Name',
                controller: name,
                icon: Icons.abc_outlined,
              ),
              SizedBox(height: 20),
              customfield(hint: 'email', controller: email, icon: Icons.email),
              SizedBox(height: 20),
              customfield(
                hint: 'password',
                controller: password,
                icon: Icons.password,
              ),
              SizedBox(height: 30),
              Consumer<AuthController>(
                builder: (context, authcontroller, child) {
                  return ElevatedButton(
                    onPressed: authcontroller.isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                    ),
                    child: authcontroller.isLoading
                        ? const CircularProgressIndicator()
                        : Text('Sign Up'),
                  );
                },
              ),
              SizedBox(height: 20),
              Consumer<AuthController>(
                builder: (context, authcontroller, child) {
                  if (authcontroller.errorMessage.isEmpty) {
                    return const SizedBox();
                  }
                  return Text(authcontroller.errorMessage);
                },
              ),
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
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
