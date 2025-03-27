import 'package:ezstore_flutter/data/repositories/auth_repository.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:flutter/material.dart';

class DrawerViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  String? _error;
  bool _isLoading = false;

  DrawerViewModel(this._authRepository);

  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<bool> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authRepository.logout();
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Thêm các phương thức xử lý logic mới

  Future<bool> confirmLogout(BuildContext context) async {
    // Hiển thị hộp thoại xác nhận
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child:
                  const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    return confirm ?? false;
  }

  Future<void> handleLogout(BuildContext context) async {
    final shouldLogout = await confirmLogout(context);

    if (shouldLogout) {
      final success = await logout();

      if (success && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  void navigateToRoute(BuildContext context, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';

    if (currentRoute == route) {
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(
        context,
        route,
        arguments: {'previousRoute': currentRoute},
      );
    }
  }

  String getCurrentRoute(BuildContext context) {
    return ModalRoute.of(context)?.settings.name ?? '';
  }
}
