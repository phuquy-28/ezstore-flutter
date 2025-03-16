import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../ui/core/shared/custom_button.dart';
import '../../../ui/core/shared/detail_app_bar.dart';
import '../../../ui/core/shared/detail_text_field.dart';
import '../../../ui/core/shared/detail_date_input.dart';
import '../../../ui/core/shared/detail_dropdown.dart';
import '../view_models/user_detail_view_model.dart';
import '../../../domain/models/user/user.dart';
import 'package:flutter/rendering.dart';

class UserDetailScreen extends StatefulWidget {
  final bool isEditMode;
  final int? userId;

  const UserDetailScreen({Key? key, this.isEditMode = false, this.userId})
      : super(key: key);

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
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.isEditMode;

    // Không khởi tạo giá trị mặc định cho ngày sinh
    // _birthDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Đặt _isLoading = true trước khi gọi API
    setState(() {
      _isLoading = true;
    });

    // Tải dữ liệu người dùng nếu có userId
    if (widget.userId != null) {
      // Sử dụng Future.microtask để đảm bảo gọi sau khi build hoàn tất
      Future.microtask(() => _loadUserData());
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final viewModel =
          Provider.of<UserDetailViewModel>(context, listen: false);
      await viewModel.getUserById(widget.userId!);

      if (viewModel.user != null) {
        _updateFormWithUserData(viewModel.user!);
      }

      setState(() {
        _isLoading = false;
        _errorMessage = viewModel.errorMessage;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Không thể tải thông tin người dùng: ${e.toString()}";
      });
    }
  }

  void _updateFormWithUserData(User user) {
    _emailController.text = user.email;
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _phoneController.text = user.phoneNumber ?? '';

    // Xử lý ngày sinh
    if (user.birthDate != null) {
      if (user.birthDate is String) {
        // Nếu là chuỗi định dạng yyyy-MM-dd, chuyển sang dd/MM/yyyy
        try {
          final date = DateFormat('yyyy-MM-dd').parse(user.birthDate as String);
          _birthDateController.text = DateFormat('dd/MM/yyyy').format(date);
        } catch (e) {
          _birthDateController.text = user.birthDate as String;
        }
      } else if (user.birthDate is DateTime) {
        _birthDateController.text =
            DateFormat('dd/MM/yyyy').format(user.birthDate as DateTime);
      }
    } else {
      // Nếu ngày sinh là null, để trống
      _birthDateController.text = '';
    }

    // Xử lý giới tính
    if (user.gender != null) {
      // Tìm key trong genderMap có value = user.gender
      final genderEntry = genderMap.entries.firstWhere(
        (entry) =>
            entry.value.toUpperCase() == user.gender.toString().toUpperCase(),
        orElse: () => const MapEntry(
            'Nam', 'MALE'), // Mặc định là 'Nam' nếu không tìm thấy
      );
      selectedGender = genderEntry.key;
    }

    // Tìm key trong roleMap có value = user.role.id
    final roleEntry = roleMap.entries.firstWhere(
      (entry) => entry.value == user.role.id,
      orElse: () =>
          const MapEntry('User', 2), // Mặc định là 'User' nếu không tìm thấy
    );
    selectedRole = roleEntry.key;
  }

  // Ánh xạ giữa giá trị hiển thị và giá trị thực cho giới tính
  final Map<String, dynamic> genderMap = {
    'Nam': 'MALE',
    'Nữ': 'FEMALE',
    'Khác': 'OTHER',
  };

  // Ánh xạ giữa giá trị hiển thị và giá trị thực cho vai trò
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
        title: isEditMode ? 'Chỉnh sửa người dùng' : 'Chi tiết người dùng',
        onEditToggle: () {
          setState(() {
            isEditMode = !isEditMode;
          });
        },
        isEditMode: isEditMode,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
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
                                  obscureText: !_isPasswordVisible,
                                  textColor: Colors.black,
                                  fillColor: Colors.white,
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
                                valueMap: genderMap,
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
              _errorMessage ?? "Không thể tải thông tin người dùng",
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
    String randomPassword = _createRandomPassword();
    setState(() {
      _passwordController.text = randomPassword;
    });

    // Sao chép email và mật khẩu vào clipboard
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

    // Thêm các ký tự ngẫu nhiên khác để đạt độ dài tối thiểu (ví dụ: 8 ký tự)
    const String allChars = upper + lower + digits + special;
    for (int i = 4; i < 8; i++) {
      password += allChars[
          (DateTime.now().millisecondsSinceEpoch % allChars.length).toInt()];
    }

    // Trộn mật khẩu và trả về dưới dạng chuỗi
    return (password.split('')..shuffle()).join(); // Trả về chuỗi đã trộn
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Hiển thị loading indicator
      });

      final viewModel =
          Provider.of<UserDetailViewModel>(context, listen: false);

      // Lấy giá trị thực của gender từ genderMap
      final String genderValue = genderMap[selectedGender] ?? 'MALE';

      // Kiểm tra xem giá trị gender đã được lấy đúng chưa
      print('Selected Gender: $selectedGender');
      print('Gender Value: $genderValue');

      // Lấy roleId từ roleMap
      final int roleId =
          roleMap[selectedRole] ?? 2; // Mặc định là User nếu không tìm thấy

      // Tạo đối tượng User từ dữ liệu form
      final updatedUser = User(
        id: widget.userId!,
        email: _emailController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        birthDate: _birthDateController.text.isEmpty
            ? null
            : _birthDateController.text,
        phoneNumber: _phoneController.text,
        gender: genderValue, // Sử dụng giá trị thực của gender
        role: Role(name: selectedRole, id: roleId), // Sử dụng roleId từ roleMap
      );

      // Cập nhật người dùng
      viewModel
          .updateUser(
              updatedUser,
              _passwordController.text.isNotEmpty
                  ? _passwordController.text
                  : null)
          .then((success) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          // Chỉ hiển thị thông báo thành công và tắt chế độ chỉnh sửa khi cập nhật thực sự thành công
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
          // Hiển thị thông báo lỗi từ ViewModel
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Lỗi: ${viewModel.errorMessage ?? "Không thể cập nhật người dùng"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }).catchError((error) {
        setState(() {
          _isLoading = false;
        });

        // Hiển thị thông báo lỗi
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
