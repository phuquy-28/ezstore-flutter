import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/ui/auth/reset-password/viewmodels/reset_password_viewmodel.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_text_field.dart';
import 'package:ezstore_flutter/ui/core/shared/scalable_logo.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  final ResetPasswordViewModel viewModel;

  const ResetPasswordScreen({Key? key, required this.viewModel})
      : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final success = await widget.viewModel.resetPassword(
        _newPasswordController.text,
        _confirmPasswordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt lại mật khẩu thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
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
                  const SizedBox(height: AppSizes.paddingLarge),
                  CustomTextField(
                    controller: _newPasswordController,
                    hintText: 'Mật khẩu mới',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    enabled: !widget.viewModel.isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu mới';
                      } else if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingNormal),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Xác nhận mật khẩu',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    enabled: !widget.viewModel.isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu';
                      } else if (value != _newPasswordController.text) {
                        return 'Mật khẩu xác nhận không khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.paddingLarge),
                  CustomButton(
                    text: 'Đặt lại mật khẩu',
                    onPressed:
                        !widget.viewModel.isLoading ? _resetPassword : null,
                    isLoading: widget.viewModel.isLoading,
                  ),
                  const SizedBox(height: AppSizes.paddingNormal),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Quay lại',
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
