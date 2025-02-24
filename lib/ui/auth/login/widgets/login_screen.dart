import 'package:flutter/material.dart';
import '../../../../config/constants.dart';
import '../../../core/shared/scalable_logo.dart';
import '../../../core/shared/custom_text_field.dart';
import '../../../core/shared/custom_button.dart';
import '../view_model/login_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: viewModel.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: ScalableStoreLogo(
                              width: 200,
                              height: 60,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge * 2),
                          CustomTextField(
                            controller: viewModel.emailController,
                            hintText: 'Email đăng nhập',
                            prefixIcon: Icons.email_outlined,
                            enabled: !viewModel.isLoading,
                            validator: viewModel.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSizes.paddingNormal),
                          CustomTextField(
                            controller: viewModel.passwordController,
                            hintText: 'Mật khẩu',
                            prefixIcon: Icons.lock_outlined,
                            enabled: !viewModel.isLoading,
                            validator: viewModel.validatePassword,
                            obscureText: !viewModel.isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                viewModel.isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: !viewModel.isLoading
                                  ? () => viewModel.togglePasswordVisibility()
                                  : null,
                            ),
                            onFieldSubmitted: (_) =>
                                viewModel.handleLogin(context),
                          ),
                          const SizedBox(height: AppSizes.paddingLarge),
                          CustomButton(
                            text: 'Đăng nhập',
                            onPressed: !viewModel.isLoading
                                ? () => viewModel.handleLogin(context)
                                : null,
                            isLoading: viewModel.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
