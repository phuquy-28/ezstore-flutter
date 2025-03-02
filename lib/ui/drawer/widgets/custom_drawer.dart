import 'package:ezstore_flutter/provider/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/constants.dart';
import '../../../routing/app_routes.dart';
import '../../../ui/drawer/viewmodel/drawer_viewmodel.dart';
import '../../../domain/models/user_info_response.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (context, userInfoProvider, child) {
        return Drawer(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildDrawerHeader(userInfoProvider.userInfo),
                Expanded(
                  child: _buildDrawerItems(context),
                ),
                _buildLogoutSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final viewModel = context.read<DrawerViewModel>();
    final success = await viewModel.logout();

    if (context.mounted) {
      if (success) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Đã có lỗi xảy ra'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDrawerHeader(UserInfoResponse? userInfo) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.black12,
            child: Text('YC', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 16),
          Text(
            userInfo?.firstName ?? 'Người dùng',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItems(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        _buildDrawerItem(
          context,
          Icons.dashboard_outlined,
          AppStrings.dashboard,
          AppRoutes.dashboard,
        ),
        _buildDrawerItem(
          context,
          Icons.people_outlined,
          AppStrings.users,
          AppRoutes.users,
        ),
        _buildDrawerItem(
          context,
          Icons.shopping_bag_outlined,
          AppStrings.products,
          AppRoutes.products,
        ),
        _buildDrawerItem(
          context,
          Icons.category_outlined,
          AppStrings.categories,
          AppRoutes.categories,
        ),
        _buildDrawerItem(
          context,
          Icons.receipt_outlined,
          AppStrings.orders,
          AppRoutes.orders,
        ),
        _buildDrawerItem(
          context,
          Icons.discount_outlined,
          AppStrings.promotions,
          AppRoutes.promotions,
        ),
        _buildDrawerItem(
          context,
          Icons.star_outline,
          AppStrings.reviews,
          AppRoutes.reviews,
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    final isSelected = currentRoute == route;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.black87,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.black87,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            if (currentRoute == route) {
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context,
                route,
                arguments: {'previousRoute': currentRoute},
              );
            }
          },
          selected: isSelected,
          selectedTileColor: AppColors.primary.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey[200],
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Đăng xuất',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () => _handleLogout(context),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
