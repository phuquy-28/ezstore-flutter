import 'package:ezstore_flutter/domain/models/user.dart';
import 'package:ezstore_flutter/ui/user/widgets/user_detail_screen.dart';
import 'package:flutter/material.dart';

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
              // Delete user logic
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
}
