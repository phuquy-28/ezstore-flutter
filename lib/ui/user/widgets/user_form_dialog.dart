import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../data/models/user.dart';

class UserFormDialog extends StatelessWidget {
  final String title;
  final User? user;

  const UserFormDialog({
    super.key, 
    required this.title,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: AppStrings.name,
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: user?.name),
            ),
            const SizedBox(height: 16),
            // ... other form fields
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Add/Update user logic
          },
          child: Text(user == null ? AppStrings.add : AppStrings.save),
        ),
      ],
    );
  }
} 