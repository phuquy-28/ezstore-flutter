import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/ui/auth/forget-password/viewmodels/forget_password_viewmodel.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_text_field.dart';
import 'package:ezstore_flutter/ui/core/shared/scalable_logo.dart';
import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatefulWidget {
  final ForgetPasswordViewModel viewModel;

  const ForgetPasswordScreen({Key? key, required this.viewModel})
      : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final success = await widget.viewModel.recoverPassword(email);

      if (success && mounted) {
        // Navigate to verification screen with the email
        Navigator.of(context).pushNamed('/verify', arguments: {
          'email': email,
        });
      } else if (mounted && widget.viewModel.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.viewModel.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingNormal),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSizes.paddingLarge),
                  const Center(
                    child: ScalableStoreLogo(
                      width: 200,
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingLarge * 2),
                  const Text(
                    'Nhập địa chỉ email của bạn để nhận mã xác thực.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    enabled: !widget.viewModel.isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  CustomButton(
                    text: 'Gửi mã xác thực',
                    onPressed:
                        !widget.viewModel.isLoading ? _sendResetLink : null,
                    isLoading: widget.viewModel.isLoading,
                  ),
                  const SizedBox(height: AppSizes.paddingNormal),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Quay lại đăng nhập',
                      style: TextStyle(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
