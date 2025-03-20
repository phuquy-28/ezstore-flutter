import 'package:ezstore_flutter/domain/models/category/category.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/ui/category/view_models/category_screen_view_model.dart';
import 'package:ezstore_flutter/ui/core/shared/action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryActionSheet extends ActionSheet<Category> {
  const CategoryActionSheet({Key? key, required Category category})
      : super(key: key, item: category);

  @override
  void onEdit(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.categoryDetail,
        arguments: {'id': item.id}).then((_) {
      // Refresh danh sách sau khi chỉnh sửa
      Provider.of<CategoryScreenViewModel>(context, listen: false).refresh();
    });
  }

  @override
  Widget buildDeleteConfirmationContent() {
    return Text('Bạn có chắc chắn muốn xóa danh mục ${item.name ?? ""}?');
  }

  @override
  Future<void> onDelete(BuildContext context) async {
    final viewModel =
        Provider.of<CategoryScreenViewModel>(context, listen: false);
    final result = await viewModel.deleteCategory(item.id);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (result) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Xóa danh mục thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content:
              Text(viewModel.deleteErrorMessage ?? 'Xóa danh mục thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
