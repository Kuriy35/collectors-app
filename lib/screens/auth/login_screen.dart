import 'package:flutter/material.dart';
import '../../core/app_strings.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_auth_button.dart';
import '../../widgets/custom_toast.dart';
import '../../services/analytics_service.dart';
import '../../services/crashlytics_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = AuthRepository();
  bool _isLoading = false;
  bool _isLoadingGoogle = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView('login_screen');
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      CustomToast.showError(context, AppStrings.checkInputFields);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _authRepo.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        final userId = user != null ? user.uid : 'Unknown';

        await AnalyticsService.logLogin('email');
        await AnalyticsService.setUserId(userId);
        await CrashlyticsService.setUserId(userId);

        if (!mounted) return;

        CustomToast.showSuccess(context, AppStrings.authSuccess('Email'));
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoadingGoogle = true);
    try {
      final user = await _authRepo.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        final userId = user.uid;

        await AnalyticsService.logLogin('google');
        await AnalyticsService.setUserId(userId);
        await CrashlyticsService.setUserId(userId);

        if (!mounted) return;

        CustomToast.showSuccess(context, AppStrings.authSuccess('Google'));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        CustomToast.showError(context, AppStrings.googleLoginCanceled);
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFE8EAF6)],
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
                    const SizedBox(height: 80),
                    _buildLogoSection(),
                    const SizedBox(height: 60),
                    _buildLoginForm(),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, '/register'),
                      child: Text(
                        AppStrings.noAccount,
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.w600,
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

  Widget _buildLogoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.inventory_2, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            'CollectorApp',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 32,
              color: Color(0xFF1976D2),
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Ваша персональна колекція',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF666666),
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        CustomTextField(
          label: AppStrings.email,
          hintText: AppStrings.emailExample,
          icon: Icons.mail_outline,
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) return AppStrings.emailRequired;
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return AppStrings.emailInvalid;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: AppStrings.password,
          hintText: AppStrings.passwordExample,
          icon: Icons.lock_outline,
          controller: _passwordController,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.passwordRequired;
            }
            if (value.length < 6) return AppStrings.passwordMin;
            return null;
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/forgot-password'),
            child: const Text(
              'Забули пароль?',
              style: TextStyle(
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const CircularProgressIndicator()
            : CustomAuthButton(text: AppStrings.login, onTap: _handleLogin),
        const SizedBox(height: 16),
        _isLoadingGoogle
            ? const CircularProgressIndicator()
            : CustomAuthButton(
                text: AppStrings.googleLogin,
                onTap: _handleGoogleLogin,
              ),
      ],
    );
  }
}
