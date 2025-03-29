import 'package:ezstore_flutter/domain/models/category/category.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/ui/core/shared/action_sheet.dart';
import 'package:flutter/material.dart';

class CategoryActionSheet extends ActionSheet<Category> {
  final Function(int)? onDeleteCategory;
  final VoidCallback? onEditSuccess;

  const CategoryActionSheet({
    Key? key,
    required Category category,
    this.onDeleteCategory,
    this.onEditSuccess,
  }) : super(key: key, item: category);

  @override
  void onEdit(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.categoryDetail,
        arguments: {'id': item.id}).then((_) {
      // Refresh danh sách sau khi chỉnh sửa
      if (onEditSuccess != null) {
        onEditSuccess!();
      }
    });
  }

  @override
  Widget buildDeleteConfirmationContent() {
    return Text('Bạn có chắc chắn muốn xóa danh mục ${item.name ?? ""}?');
  }

  @override
  Future<void> onDelete(BuildContext context) async {
    if (onDeleteCategory != null && item.id != null) {
      // Just call the delete callback - dialog is already closed by base class
      await onDeleteCategory!(item.id!);
    }
  }
}
