import 'package:ezstore_flutter/domain/models/product/product_response.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/ui/core/shared/action_sheet.dart';
import 'package:flutter/material.dart';

class ProductActionSheet extends ActionSheet<ProductResponse> {
  final Function(int) onDeleteProduct;

  const ProductActionSheet({
    Key? key,
    required ProductResponse product,
    required this.onDeleteProduct,
  }) : super(key: key, item: product);

  @override
  void onEdit(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.editProduct,
      arguments: {'id': item.id},
    );
  }

  @override
  Widget buildDeleteConfirmationContent() {
    return Text('Bạn có chắc chắn muốn xóa sản phẩm ${item.name ?? ""}?');
  }

  @override
  Future<void> onDelete(BuildContext context) async {
    await onDeleteProduct(item.id!);
  }
}
