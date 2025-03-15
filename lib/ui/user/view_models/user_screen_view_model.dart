import 'package:ezstore_flutter/domain/models/user.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/paginated_response.dart';
import 'dart:developer' as dev;

class UserScreenViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  PaginatedResponse<User>? _paginatedData;
  bool _isLoading = false;
  int _currentPage = 0;

  UserScreenViewModel(this._userRepository) {
    // Sử dụng mock data thay vì gọi API
    _loadMockData();
  }

  bool get isLoading => _isLoading;
  List<User>? get users => _paginatedData?.data;

  // Thêm các getter cho thông tin phân trang
  int get currentPage => _paginatedData?.meta.page ?? 0;
  int get totalPages => _paginatedData?.meta.pages ?? 0;
  int get totalItems => _paginatedData?.meta.total ?? 0;

  void _loadMockData() {
    _isLoading = true;
    notifyListeners();

    // Tạo mock data
    final mockUsers = [
      User(
        id: 1,
        email: 'admin@example.com',
        firstName: 'Admin',
        lastName: 'User',
        fullName: 'Admin User',
        phoneNumber: '0123456789',
        gender: 'Nam',
        role: Role(id: 1, name: 'Admin'),
      ),
      User(
        id: 2,
        email: 'user1@example.com',
        firstName: 'Nguyễn',
        lastName: 'Văn A',
        fullName: 'Nguyễn Văn A',
        phoneNumber: '0987654321',
        gender: 'Nam',
        role: Role(id: 2, name: 'User'),
      ),
      User(
        id: 3,
        email: 'user2@example.com',
        firstName: 'Trần',
        lastName: 'Thị B',
        fullName: 'Trần Thị B',
        phoneNumber: '0369852147',
        gender: 'Nữ',
        role: Role(id: 2, name: 'User'),
      ),
      User(
        id: 3,
        email: 'user2@example.com',
        firstName: 'Trần',
        lastName: 'Thị B',
        fullName: 'Trần Thị B',
        phoneNumber: '0369852147',
        gender: 'Nữ',
        role: Role(id: 2, name: 'User'),
      ),
      User(
        id: 3,
        email: 'user2@example.com',
        firstName: 'Trần',
        lastName: 'Thị B',
        fullName: 'Trần Thị B',
        phoneNumber: '0369852147',
        gender: 'Nữ',
        role: Role(id: 2, name: 'User'),
      ),
      User(
        id: 3,
        email: 'user2@example.com',
        firstName: 'Trần',
        lastName: 'Thị B',
        fullName: 'Trần Thị B',
        phoneNumber: '0369852147',
        gender: 'Nữ',
        role: Role(id: 2, name: 'User'),
      ),
      User(
        id: 3,
        email: 'user2@example.com',
        firstName: 'Trần',
        lastName: 'Thị B',
        fullName: 'Trần Thị B',
        phoneNumber: '0369852147',
        gender: 'Nữ',
        role: Role(id: 2, name: 'User'),
      ),
      User(
        id: 3,
        email: 'user2@example.com',
        firstName: 'Trần',
        lastName: 'Thị B',
        fullName: 'Trần Thị B',
        phoneNumber: '0369852147',
        gender: 'Nữ',
        role: Role(id: 2, name: 'User'),
      ),
    ];

    _paginatedData = PaginatedResponse<User>(
      meta: PaginationMeta(
          page: 0, pageSize: 10, pages: 1, total: mockUsers.length),
      data: mockUsers,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUsers({int page = 0}) async {
    // Giả lập việc tải dữ liệu
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    // Giả lập delay khi gọi API
    await Future.delayed(const Duration(seconds: 1));

    // Không thực sự gọi API, chỉ sử dụng mock data
    if (page > 0) {
      // Nếu trang > 0, giả lập không có thêm dữ liệu
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Tải lại mock data
    _loadMockData();
  }

  Future<void> loadMoreUsers() async {
    _currentPage++;
    // Giả lập tải thêm dữ liệu
    await Future.delayed(const Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
    // Không thêm dữ liệu mới vì đây là mock data
  }
}
