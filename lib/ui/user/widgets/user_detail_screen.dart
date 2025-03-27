import 'package:ezstore_flutter/domain/models/user/user.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_date_input.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_dropdown.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_text_field.dart';
import 'package:ezstore_flutter/ui/user/view_models/user_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDetailScreen extends StatefulWidget {
  final bool isEditMode;
  final int? userId;
  final UserDetailViewModel viewModel;

  const UserDetailScreen({
    Key? key,
    this.isEditMode = false,
    this.userId,
    required this.viewModel,
  }) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late bool isEditMode;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String selectedGender = 'Nam';
  String selectedRole = 'User';

  @override
  void initState() {
    super.initState();
    isEditMode = widget.isEditMode;
    widget.viewModel.addListener(_viewModelListener);

    // Tải dữ liệu người dùng nếu có userId
    if (widget.userId != null) {
      // Sử dụng Future.microtask để đảm bảo gọi sau khi build hoàn tất
      Future.microtask(() => _loadUserData());
    }
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
        // Update UI when viewModel changes
        if (widget.viewModel.user != null && !widget.viewModel.isLoading) {
          _updateFormWithUserData(widget.viewModel.user!);
        }
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      await widget.viewModel.getUserById(widget.userId!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateFormWithUserData(User user) {
    _emailController.text = user.email;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _phoneController.text = user.phoneNumber ?? '';

    // Format and set birthdate
    _birthDateController.text =
        widget.viewModel.formatBirthDateForDisplay(user.birthDate);

    // Set gender
    selectedGender = widget.viewModel.getGenderDisplayValue(user.gender);

    // Set role
    selectedRole = widget.viewModel.getRoleDisplayValue(user.role.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailAppBar(
        title: isEditMode ? 'Chỉnh sửa người dùng' : 'Chi tiết người dùng',
        onEditToggle: () {
          setState(() {
            isEditMode = !isEditMode;
          });
        },
        isEditMode: isEditMode,
      ),
      body: widget.viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.viewModel.errorMessage != null
              ? _buildErrorView()
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      DetailTextField(
                        controller: _emailController,
                        label: 'Email',
                        enabled: false,
                        hintText: 'Nhập email',
                        textColor: Colors.black,
                        fillColor: Colors.white,
                      ),
                      if (isEditMode) ...[
                        const SizedBox(height: 24),
                        _buildFormField(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: DetailTextField(
                                  controller: _passwordController,
                                  label: 'Mật khẩu mới (không bắt buộc)',
                                  enabled: true,
                                  hintText: 'Nhập để thay đổi mật khẩu',
                                  obscureText:
                                      !widget.viewModel.isPasswordVisible,
                                  textColor: Colors.black,
                                  fillColor: Colors.white,
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
                      ],
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DetailTextField(
                              controller: _firstNameController,
                              label: 'Họ',
                              enabled: isEditMode,
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
                              enabled: isEditMode,
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
                          enabled: isEditMode,
                          onTap: () => _selectDate(context),
                        ),
                      ),
                      const SizedBox(height: 24),
                      DetailTextField(
                        controller: _phoneController,
                        label: 'Số điện thoại',
                        enabled: isEditMode,
                        hintText: 'Nhập số điện thoại',
                        textColor: Colors.black,
                        fillColor: Colors.white,
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
                                onChanged: isEditMode
                                    ? (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedGender = newValue;
                                          });
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFormField(
                              label: 'Vai trò',
                              child: DetailDropdown(
                                value: selectedRole,
                                items: const [
                                  'Admin',
                                  'User',
                                  'Staff',
                                  'Manager'
                                ],
                                onChanged: isEditMode
                                    ? (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedRole = newValue;
                                          });
                                        }
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isEditMode) ...[
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'Cập nhật',
                          onPressed: _handleSubmit,
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            "Đã xảy ra lỗi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              widget.viewModel.errorMessage ??
                  "Không thể tải thông tin người dùng",
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserData,
            child: const Text("Thử lại"),
          ),
        ],
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
    // Xác định ngày ban đầu
    DateTime initialDate;
    try {
      // Nếu đã có ngày sinh, sử dụng nó
      if (_birthDateController.text.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(_birthDateController.text);
      } else {
        // Nếu chưa có, sử dụng ngày hiện tại trừ 18 năm (giả sử người dùng trên 18 tuổi)
        initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
      }
    } catch (e) {
      // Nếu có lỗi khi parse, sử dụng ngày hiện tại trừ 18 năm
      initialDate = DateTime.now().subtract(const Duration(days: 365 * 18));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

    // Copy email and password to clipboard
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
      // Get roleId from roleMap
      final int roleId = widget.viewModel.getRoleMap[selectedRole] ?? 2;

      // Get gender value
      final String genderValue =
          widget.viewModel.getGenderMap[selectedGender] ?? 'MALE';

      // Create updated user from form data
      final updatedUser = User(
        id: widget.userId!,
        email: _emailController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        birthDate: _birthDateController.text.isEmpty
            ? null
            : _birthDateController.text,
        phoneNumber: _phoneController.text,
        gender: genderValue,
        role: Role(name: selectedRole, id: roleId),
      );

      // Update user
      widget.viewModel
          .updateUser(
              updatedUser,
              _passwordController.text.isNotEmpty
                  ? _passwordController.text
                  : null)
          .then((success) {
        if (success) {
          // Turn off edit mode if update is successful
          setState(() {
            isEditMode = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Show error from ViewModel
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Lỗi: ${widget.viewModel.errorMessage ?? "Không thể cập nhật người dùng"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }).catchError((error) {
        // Show error message
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
