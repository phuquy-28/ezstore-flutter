import 'package:flutter/material.dart';
import '../../drawer/widgets/custom_drawer.dart';
import '../../core/shared/custom_app_bar.dart';
import '../../../config/constants.dart';
import '../../../data/models/user.dart';
import 'user_search_field.dart';
import 'user_card.dart';
import 'user_form_dialog.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final List<User> users = [
    User(
      name: 'System Admin',
      email: 'admin@gmail.com',
      dateOfBirth: '01/01/1990',
      gender: 'Nam',
      role: 'ADMIN',
    ),
    User(
      name: 'sssss oss',
      email: 'phuquy2823@gmail.com',
      dateOfBirth: '21/02/2025',
      gender: 'Nam',
      role: 'USER',
    ),
    User(
      name: 'Nguyễn Văn C',
      email: 'example1@gmail.com',
      dateOfBirth: '10/12/2003',
      gender: 'Nam',
      role: 'MANAGER',
    ),
    User(
      name: 'Nguyễn Văn C',
      email: 'example1@gmail.com',
      dateOfBirth: '10/12/2003',
      gender: 'Nam',
      role: 'MANAGER',
    ),
    User(
      name: 'Nguyễn Văn C',
      email: 'example1@gmail.com',
      dateOfBirth: '10/12/2003',
      gender: 'Nam',
      role: 'MANAGER',
    ),
    User(
      name: 'Nguyễn Văn C',
      email: 'example1@gmail.com',
      dateOfBirth: '10/12/2003',
      gender: 'Nam',
      role: 'MANAGER',
    ),
    // Add more users as needed
  ];

  String searchQuery = '';

  List<User> get filteredUsers {
    if (searchQuery.isEmpty) {
      return users;
    }
    return users
        .where((user) =>
            user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.users,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const UserFormDialog(
                title: AppStrings.addUser,
              ),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          UserSearchField(
            onChanged: (value) => setState(() => searchQuery = value),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingNormal),
              itemCount: filteredUsers.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSizes.paddingSmall),
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return UserCard(user: user);
              },
            ),
          ),
        ],
      ),
    );
  }
}
