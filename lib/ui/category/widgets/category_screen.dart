import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:ezstore_flutter/ui/core/shared/search_field.dart';
import 'package:flutter/material.dart';

class Category {
  final String name;
  final String imageUrl;

  Category({
    required this.name,
    required this.imageUrl,
  });
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<Category> categories = [
    Category(
      name: 'Office',
      imageUrl:
          'https://res.cloudinary.com/db9vcatme/image/upload/v1733736322/blazer-removebg-preview_rgjidu.png',
    ),
    Category(
      name: 'Đồ ngủ',
      imageUrl:
          'https://res.cloudinary.com/db9vcatme/image/upload/v1733736322/blazer-removebg-preview_rgjidu.png',
    ),
    Category(
      name: 'Quần áo Basic',
      imageUrl:
          'https://res.cloudinary.com/db9vcatme/image/upload/v1733736322/blazer-removebg-preview_rgjidu.png',
    ),
  ];

  String searchQuery = '';

  List<Category> get filteredCategories {
    if (searchQuery.isEmpty) {
      return categories;
    }
    return categories
        .where((category) =>
            category.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.categories,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddCategoryDialog(context);
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          SearchField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            onSubmitted: (value) {
              // Tạm bỏ qua xử lý
            },
            onClear: () {
              // Tạm bỏ qua xử lý
            },
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingNormal),
              itemCount: filteredCategories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSizes.paddingSmall),
              itemBuilder: (context, index) {
                final category = filteredCategories[index];
                return CategoryCard(category: category);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh mục mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tên danh mục',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // Add image picker logic
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image),
                  SizedBox(width: 8),
                  Text('Chọn hình ảnh'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add category logic
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showCategoryDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Category Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  category.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              // Category Name
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Action Menu
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showActionSheet(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Sửa'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCategoryDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Xem chi tiết'),
                onTap: () {
                  Navigator.pop(context);
                  _showCategoryDetails(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết danh mục',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  category.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tên danh mục:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa danh mục'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tên danh mục',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: category.name),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // Add image picker logic
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image),
                  SizedBox(width: 8),
                  Text('Thay đổi hình ảnh'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Update category logic
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa danh mục ${category.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete category logic
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
