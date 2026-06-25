import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  Future<void> _onLoginSuccess() async {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.chainDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.pharmaMint,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.local_pharmacy_outlined,
                        size: 40,
                        color: AppColors.pharmaGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.welcomeBack,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    LoginForm(
                      controller: _authController,
                      onLoginSuccess: _onLoginSuccess,
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
