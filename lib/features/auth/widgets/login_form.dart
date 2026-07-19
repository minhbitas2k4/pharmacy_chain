import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.controller,
    required this.onLoginSuccess,
  });

  final AuthController controller;
  final Future<void> Function(UserModel user) onLoginSuccess;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final user = await widget.controller.login(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (user != null) {
      await widget.onLoginSuccess(user);
    } else if (widget.controller.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.controller.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _usernameController,
                labelText: AppStrings.username,
                prefixIcon: const Icon(Icons.person_outline),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    Validators.requiredField(value, fieldName: 'Tên đăng nhập'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                labelText: AppStrings.password,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                validator: (value) =>
                    Validators.requiredField(value, fieldName: 'Mật khẩu'),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(AppStrings.forgotPassword),
                ),
              ),
              const SizedBox(height: 8),
              AppButton(
                text: AppStrings.login,
                isLoading: widget.controller.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
