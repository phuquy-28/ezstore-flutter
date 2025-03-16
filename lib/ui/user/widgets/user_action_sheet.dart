import 'package:ezstore_flutter/domain/models/user/user.dart';
import 'package:ezstore_flutter/ui/user/widgets/user_detail_screen.dart';
import 'package:ezstore_flutter/ui/user/view_models/user_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserActionSheet extends StatelessWidget {
  final User user;

  const UserActionSheet({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Sửa'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailScreen(
                    isEditMode: true,
                    userId: user.id,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xoá', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá người dùng'),
        content: Text('Bạn có chắc chắn muốn xoá người dùng ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(context);
            },
            child: Text(
              'Có',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteUser(BuildContext context) async {
    // Lưu trữ context trong một biến để kiểm tra sau này
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final viewModel = Provider.of<UserScreenViewModel>(context, listen: false);

    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang xóa người dùng...'),
          ],
        ),
      ),
    );

    // Gọi phương thức xóa người dùng
    final success = await viewModel.deleteUser(user.id);

    // Kiểm tra xem context còn hợp lệ không trước khi sử dụng
    if (navigator.mounted) {
      // Đóng dialog loading
      navigator.pop();

      // Hiển thị thông báo kết quả
      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Xóa người dùng thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
                'Lỗi: ${viewModel.deleteErrorMessage ?? "Không thể xóa người dùng"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
