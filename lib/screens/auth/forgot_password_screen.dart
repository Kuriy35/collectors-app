import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_auth_button.dart';
import '../../widgets/custom_toast.dart';
import '../../repositories/auth_repository.dart';
import '../../services/analytics_service.dart';
import '../../core/app_strings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authRepo = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _sendReset() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      CustomToast.showError(context, 'Будь ласка, введіть коректний email');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authRepo.sendPasswordResetEmail(_emailController.text.trim());

      if (!mounted) return;

      await AnalyticsService.logPasswordReset();

      if (!mounted) return;

      CustomToast.showSuccess(
        context,
        'Лист надіслано! Перевірте пошту (включно зі "Спам")',
      );
      Navigator.pop(context);
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
              theme.scaffoldBackgroundColor.withAlpha((0.8 * 255).toInt()),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF2196F3,
                            ).withAlpha((0.3 * 255).toInt()),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Відновлення паролю',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1976D2),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Введіть email, щоб отримати інструкції',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                    ),

                    const SizedBox(height: 40),

                    CustomTextField(
                      label: 'Email',
                      hintText: 'example@gmail.com',
                      icon: Icons.mail_outline,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.emailRequired;
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return AppStrings.emailInvalid;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : CustomAuthButton(
                            text: 'Надіслати інструкції',
                            onTap: _sendReset,
                          ),

                    const SizedBox(height: 24),

                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Повернутися до входу',
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
