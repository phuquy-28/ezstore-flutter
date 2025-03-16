import 'package:ezstore_flutter/ui/user/view_models/add_user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../ui/core/shared/custom_button.dart';
import '../../../ui/core/shared/detail_app_bar.dart';
import '../../../ui/core/shared/detail_text_field.dart';
import '../../../ui/core/shared/detail_date_input.dart';
import '../../../ui/core/shared/detail_dropdown.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
  final TextEditingController _phoneController = TextEditingController();

  String selectedGender = 'Nam';
  String selectedRole = 'Admin';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final Map<String, dynamic> genderMap = {
    'Nam': 'MALE',
    'Nữ': 'FEMALE',
    'Khác': 'OTHER',
  };

  final Map<String, int> roleMap = {
    'Admin': 1,
    'User': 2,
    'Staff': 3,
    'Manager': 4,
  };

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
      body: _isLoading
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      final emailRegExp =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegExp.hasMatch(value)) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
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
                            obscureText: !_isPasswordVisible,
                            textColor: Colors.black,
                            fillColor: Colors.white,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value.length < 8) {
                                return 'Mật khẩu phải có ít nhất 8 ký tự';
                              }
                              if (!value.contains(RegExp(r'[A-Z]'))) {
                                return 'Mật khẩu phải có ít nhất 1 chữ hoa';
                              }
                              if (!value.contains(RegExp(r'[a-z]'))) {
                                return 'Mật khẩu phải có ít nhất 1 chữ thường';
                              }
                              if (!value.contains(RegExp(r'[0-9]'))) {
                                return 'Mật khẩu phải có ít nhất 1 số';
                              }
                              if (!value.contains(
                                  RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                                return 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập họ';
                            }
                            return null;
                          },
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tên';
                            }
                            return null;
                          },
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
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final phoneRegExp = RegExp(r'^[0-9]{10,11}$');
                        if (!phoneRegExp.hasMatch(value)) {
                          return 'Số điện thoại không hợp lệ';
                        }
                      }
                      return null;
                    },
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
                            valueMap: genderMap,
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
    String randomPassword = _createRandomPassword();
    setState(() {
      _passwordController.text = randomPassword;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    final clipboardData = 'Email: $email\nMật khẩu: $password';
    Clipboard.setData(ClipboardData(text: clipboardData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email và mật khẩu đã được sao chép vào clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _createRandomPassword() {
    const String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lower = 'abcdefghijklmnopqrstuvwxyz';
    const String digits = '0123456789';
    const String special = '@#\$%&*!';

    String password = '';
    password +=
        upper[(DateTime.now().millisecondsSinceEpoch % upper.length).toInt()];
    password +=
        lower[(DateTime.now().millisecondsSinceEpoch % lower.length).toInt()];
    password +=
        digits[(DateTime.now().millisecondsSinceEpoch % digits.length).toInt()];
    password += special[
        (DateTime.now().millisecondsSinceEpoch % special.length).toInt()];

    const String allChars = upper + lower + digits + special;
    for (int i = 4; i < 8; i++) {
      password += allChars[
          (DateTime.now().millisecondsSinceEpoch % allChars.length).toInt()];
    }

    return (password.split('')..shuffle()).join();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final viewModel = Provider.of<AddUserViewModel>(context, listen: false);

      final String genderValue = genderMap[selectedGender] ?? 'MALE';

      final int roleId = roleMap[selectedRole] ?? 2;

      viewModel
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
        setState(() {
          _isLoading = false;
        });

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
                  'Lỗi: ${viewModel.errorMessage ?? "Không thể thêm người dùng"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });

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
