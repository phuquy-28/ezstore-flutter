import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../ui/core/shared/custom_button.dart';
import '../../../ui/core/shared/detail_app_bar.dart';
import '../../../ui/core/shared/detail_text_field.dart';
import '../../../ui/core/shared/detail_date_input.dart';
import '../../../ui/core/shared/detail_dropdown.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

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

  String selectedGender = 'Nam';
  String selectedRole = 'Admin';

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
      body: Form(
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
                      obscureText: true,
                      textColor: Colors.black,
                      fillColor: Colors.white,
                    ),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildFormField(
                    label: 'Giới tính',
                    child: DetailDropdown(
                      value: selectedGender,
                      items: const ['Nam', 'Nữ', 'Khác'],
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
                      items: const ['Admin', 'User', 'Manager'],
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
    setState(() {
      _passwordController.text = 'RandomPassword123!';
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Logic để thêm người dùng mới
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm người dùng thành công'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Quay lại màn hình trước
    }
  }
}
