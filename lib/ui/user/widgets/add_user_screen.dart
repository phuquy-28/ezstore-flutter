import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_date_input.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_dropdown.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_text_field.dart';
import 'package:ezstore_flutter/ui/user/view_models/add_user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddUserScreen extends StatefulWidget {
  final AddUserViewModel viewModel;

  const AddUserScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String selectedGender = 'Nam';
  String selectedRole = 'Admin';

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    widget.viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    if (mounted) {
      setState(() {
        // Update UI if needed when viewModel changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailAppBar(
        title: 'Thêm người dùng mới',
        onEditToggle: () {},
        isEditMode: false,
        showEditButton: false,
      ),
      body: widget.viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  DetailTextField(
                    controller: _emailController,
                    label: 'Email',
                    enabled: true,
                    hintText: 'Nhập email',
                    textColor: Colors.black,
                    fillColor: Colors.white,
                    validator: widget.viewModel.validateEmail,
                  ),
                  const SizedBox(height: 24),
                  _buildFormField(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: DetailTextField(
                            controller: _passwordController,
                            label: 'Mật khẩu',
                            enabled: true,
                            hintText: 'Nhập mật khẩu',
                            obscureText: !widget.viewModel.isPasswordVisible,
                            textColor: Colors.black,
                            fillColor: Colors.white,
                            validator: widget.viewModel.validatePassword,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            widget.viewModel.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            widget.viewModel.togglePasswordVisibility();
                          },
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _generateRandomPassword,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Random',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DetailTextField(
                          controller: _firstNameController,
                          label: 'Họ',
                          enabled: true,
                          hintText: 'Nhập họ',
                          textColor: Colors.black,
                          fillColor: Colors.white,
                          validator: (value) =>
                              widget.viewModel.validateRequired(value, 'họ'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DetailTextField(
                          controller: _lastNameController,
                          label: 'Tên',
                          enabled: true,
                          hintText: 'Nhập tên',
                          textColor: Colors.black,
                          fillColor: Colors.white,
                          validator: (value) =>
                              widget.viewModel.validateRequired(value, 'tên'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildFormField(
                    label: 'Ngày sinh',
                    child: DetailDateInput(
                      controller: _birthDateController,
                      enabled: true,
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DetailTextField(
                    controller: _phoneController,
                    label: 'Số điện thoại',
                    enabled: true,
                    hintText: 'Nhập số điện thoại',
                    textColor: Colors.black,
                    fillColor: Colors.white,
                    validator: widget.viewModel.validatePhone,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Giới tính',
                          child: DetailDropdown(
                            value: selectedGender,
                            items: const ['Nam', 'Nữ', 'Khác'],
                            valueMap: widget.viewModel.getGenderMap,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedGender = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          label: 'Vai trò',
                          child: DetailDropdown(
                            value: selectedRole,
                            items: const ['Admin', 'User', 'Staff', 'Manager'],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedRole = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Thêm người dùng',
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFormField({
    String? label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _generateRandomPassword() {
    String randomPassword = widget.viewModel.generateRandomPassword();
    setState(() {
      _passwordController.text = randomPassword;
    });

    // Copy to clipboard
    widget.viewModel.copyCredentialsToClipboard(
        _emailController.text, _passwordController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email và mật khẩu đã được sao chép vào clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Get gender value
      final String genderValue =
          widget.viewModel.getGenderMap[selectedGender] ?? 'MALE';

      // Get roleId
      final int roleId = widget.viewModel.getRoleMap[selectedRole] ?? 2;

      widget.viewModel
          .addUser(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber:
            _phoneController.text.isEmpty ? null : _phoneController.text,
        birthDate: _birthDateController.text.isEmpty
            ? null
            : _birthDateController.text,
        gender: genderValue,
        roleId: roleId,
      )
          .then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm người dùng thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Lỗi: ${widget.viewModel.errorMessage ?? "Không thể thêm người dùng"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }).catchError((error) {
        // Show error message in snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }
}
