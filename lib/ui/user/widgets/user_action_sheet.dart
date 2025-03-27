import 'package:ezstore_flutter/domain/models/user/user.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/ui/core/shared/action_sheet.dart';
import 'package:flutter/material.dart';

class UserActionSheet extends ActionSheet<User> {
  final Function(int) onDeleteUser;
  final VoidCallback? onEditSuccess;

  const UserActionSheet({
    Key? key,
    required User user,
    required this.onDeleteUser,
    this.onEditSuccess,
  }) : super(key: key, item: user);

  @override
  void onEdit(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.userDetail,
        arguments: {'id': item.id}).then((_) {
      if (onEditSuccess != null) {
        onEditSuccess!();
      }
    });
  }

  @override
  Widget buildDeleteConfirmationContent() {
    return Text(
        'Bạn có chắc chắn muốn xoá người dùng ${item.fullName ?? "${item.lastName} ${item.firstName}"}?');
  }

  @override
  Future<void> onDelete(BuildContext context) async {
    await onDeleteUser(item.id);
  }
}
