import 'package:flutter/material.dart';
import '../../drawer/widgets/custom_drawer.dart';
import '../../core/shared/custom_app_bar.dart';
import '../../../config/constants.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.products,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Handle add product
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: const Center(
        child: Text('Danh sách sản phẩm'),
      ),
    );
  }
}
