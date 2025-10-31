import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_auth_button.dart';
import '../../repositories/auth_repository.dart';
import '../../core/app_strings.dart';
import '../../widgets/custom_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = AuthRepository();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      CustomToast.showError(context, AppStrings.checkInputFields);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authRepo.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (mounted) {
        CustomToast.showSuccess(context, AppStrings.welcome);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        CustomToast.showError(context, e.toString());
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.scaffoldBackgroundColor,
              // ignore: deprecated_member_use
              theme.scaffoldBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  const CustomAppBar(title: 'Реєстрація', showBackButton: true),
                  const SizedBox(height: 80),
                  _buildRegisterForm(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          CustomTextField(
            label: "Ім'я",
            hintText: "Введіть ваше ім'я користувача",
            icon: Icons.person_outline,
            controller: _nameController,
            validator: (v) =>
                v?.trim().isEmpty == true ? AppStrings.nameRequired : null,
          ),
          const SizedBox(height: 19),
          CustomTextField(
            label: 'Email',
            hintText: 'Введіть ваш email',
            icon: Icons.mail_outline,
            controller: _emailController,
            validator: (v) {
              if (v?.trim().isEmpty == true) return AppStrings.emailRequired;
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                return AppStrings.emailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 19),
          CustomTextField(
            label: 'Пароль',
            hintText: 'Створіть пароль',
            icon: Icons.lock_outline,
            controller: _passwordController,
            obscureText: true,
            validator: (v) {
              if (v?.isEmpty == true) return AppStrings.passwordRequired;
              if (v!.length < 6) return AppStrings.passwordMin;
              return null;
            },
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator()
              : CustomAuthButton(
                  text: AppStrings.register,
                  onTap: _handleRegister,
                ),
          const SizedBox(height: 20),

          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Center(
              child: Text(
                AppStrings.hasAccount,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF2196F3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
