import 'package:flutter/material.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onEditToggle;
  final bool isEditMode;
  final bool showEditButton;

  const DetailAppBar({
    super.key,
    required this.title,
    required this.onEditToggle,
    required this.isEditMode,
    this.showEditButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (showEditButton)
          TextButton(
            onPressed: onEditToggle,
            child: Text(
              isEditMode ? 'Huỷ' : 'Sửa',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
