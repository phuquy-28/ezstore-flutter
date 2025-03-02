import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../data/models/user.dart';
import 'user_form_dialog.dart';
import 'user_details.dart';

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
            title: const Text(AppStrings.edit),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => UserFormDialog(
                  title: AppStrings.editUser,
                  user: user,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text(AppStrings.view),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => UserDetails(user: user),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text(AppStrings.delete, 
              style: TextStyle(color: Colors.red)),
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
        title: const Text(AppStrings.deleteConfirmation),
        content: Text('${AppStrings.deleteUserConfirmation} ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.no),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete user logic
            },
            child: Text(
              AppStrings.yes,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
} 