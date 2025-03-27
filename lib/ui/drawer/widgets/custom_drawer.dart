import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/domain/models/user/user_info_response.dart';
import 'package:ezstore_flutter/provider/user_info_provider.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/ui/drawer/viewmodel/drawer_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final drawerViewModel =
        Provider.of<DrawerViewModel>(context, listen: false);
    final currentRoute = drawerViewModel.getCurrentRoute(context);

    return Consumer<UserInfoProvider>(
      builder: (context, userInfoProvider, child) {
        return Drawer(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildDrawerHeader(userInfoProvider.userInfo),
                Expanded(
                  child:
                      _buildDrawerItems(context, currentRoute, drawerViewModel),
                ),
                _buildLogoutSection(context, drawerViewModel),
              ],
            ),
          ),
        );
      },
    );
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

  Widget _buildDrawerItems(
      BuildContext context, String currentRoute, DrawerViewModel viewModel) {
    return ListView(
      shrinkWrap: true,
      children: [
        _buildDrawerItem(
          context,
          Icons.dashboard_outlined,
          AppStrings.dashboard,
          AppRoutes.dashboard,
          currentRoute,
          viewModel,
        ),
        _buildDrawerItem(
          context,
          Icons.people_outlined,
          AppStrings.users,
          AppRoutes.users,
          currentRoute,
          viewModel,
        ),
        _buildDrawerItem(
          context,
          Icons.shopping_bag_outlined,
          AppStrings.products,
          AppRoutes.products,
          currentRoute,
          viewModel,
        ),
        _buildDrawerItem(
          context,
          Icons.category_outlined,
          AppStrings.categories,
          AppRoutes.categories,
          currentRoute,
          viewModel,
        ),
        _buildDrawerItem(
          context,
          Icons.receipt_outlined,
          AppStrings.orders,
          AppRoutes.orders,
          currentRoute,
          viewModel,
        ),
        _buildDrawerItem(
          context,
          Icons.discount_outlined,
          AppStrings.promotions,
          AppRoutes.promotions,
          currentRoute,
          viewModel,
        ),
        _buildDrawerItem(
          context,
          Icons.star_outline,
          AppStrings.reviews,
          AppRoutes.reviews,
          currentRoute,
          viewModel,
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
    String currentRoute,
    DrawerViewModel viewModel,
  ) {
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
          onTap: () => viewModel.navigateToRoute(context, route),
          selected: isSelected,
          selectedTileColor: AppColors.primary.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, DrawerViewModel viewModel) {
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
          onTap: () => viewModel.handleLogout(context),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
