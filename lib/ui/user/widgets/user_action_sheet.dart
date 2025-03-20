import 'package:ezstore_flutter/domain/models/user/user.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/ui/core/shared/action_sheet.dart';
import 'package:ezstore_flutter/ui/user/view_models/user_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserActionSheet extends ActionSheet<User> {
  const UserActionSheet({super.key, required User user}) : super(item: user);

  @override
  void onEdit(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.userDetail,
        arguments: {'id': item.id}).then((_) {
      Provider.of<UserScreenViewModel>(context, listen: false).refresh();
    });
  }

  @override
  Widget buildDeleteConfirmationContent() {
    return Text('Bạn có chắc chắn muốn xoá người dùng ${item.fullName}?');
  }

  @override
  Future<void> onDelete(BuildContext context) async {
    final viewModel = Provider.of<UserScreenViewModel>(context, listen: false);
    final success = await viewModel.deleteUser(item.id);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
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
