import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/ui/auth/verify/view_model/verify_viewmodel.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/scalable_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyScreen extends StatefulWidget {
  final VerifyViewModel viewModel;

  const VerifyScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args.containsKey('email')) {
        widget.viewModel.setEmail(args['email'] as String);
        widget.viewModel.startResendCooldown();
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _verificationCode => _controllers.map((c) => c.text).join();

  void _verifyCode() async {
    if (_verificationCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ mã xác thực 6 số'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success =
        await widget.viewModel.verifyPasswordReset(_verificationCode);

    if (success && mounted) {
      // Navigate to reset password screen with email and code
      Navigator.of(context).pushNamed('/reset-password', arguments: {
        'email': widget.viewModel.email,
        'code': _verificationCode,
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

  void _resendCode() async {
    final success = await widget.viewModel.resendActivationCode();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi lại mã xác thực'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && widget.viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingNormal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ScalableStoreLogo(
                width: 200,
                height: 60,
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              const Text(
                'Nhập mã xác thực đã gửi đến email của bạn',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.viewModel.email.isNotEmpty) ...[
                const SizedBox(height: AppSizes.paddingSmall),
                Text(
                  widget.viewModel.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSizes.paddingLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 45,
                    height: 55,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      enabled: !widget.viewModel.isLoading,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 24),
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.inputBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            // Last digit entered, verify code
                            _verifyCode();
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Xác thực',
                  onPressed: !widget.viewModel.isLoading ? _verifyCode : null,
                  isLoading: widget.viewModel.isLoading,
                ),
              ),
              const SizedBox(height: AppSizes.paddingNormal),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chưa nhận được mã?',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.viewModel.canResend ? _resendCode : null,
                    child: Text(
                      widget.viewModel.resendCooldown > 0
                          ? 'Gửi lại (${widget.viewModel.resendCooldown}s)'
                          : 'Gửi lại',
                      style: TextStyle(
                        color: widget.viewModel.canResend
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.viewModel.isResending)
                const Padding(
                  padding: EdgeInsets.only(top: AppSizes.paddingSmall),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
