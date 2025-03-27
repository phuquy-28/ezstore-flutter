import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/domain/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'user_action_sheet.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onViewDetails;
  final Function(int) onDeleteUser;
  final VoidCallback onEditSuccess;

  const UserCard({
    Key? key,
    required this.user,
    required this.onViewDetails,
    required this.onDeleteUser,
    required this.onEditSuccess,
  }) : super(key: key);

  Color getRoleColor() {
    switch (user.role.name) {
      case AppStrings.roleAdmin:
        return AppColors.roleAdmin;
      case AppStrings.roleManager:
        return AppColors.roleManager;
      case AppStrings.roleStaff:
        return AppColors.roleStaff;
      case AppStrings.roleUser:
      default:
        return AppColors.roleUser;
    }
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => UserActionSheet(
        user: user,
        onDeleteUser: onDeleteUser,
        onEditSuccess: onEditSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => onViewDetails(),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingNormal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.lastName} ${user.firstName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showActionSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    user.birthDate != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(DateTime.parse(user.birthDate!))
                        : '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingNormal),
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    user.gender ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: getRoleColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: getRoleColor()),
                ),
                child: Text(
                  user.role.name,
                  style: TextStyle(
                    color: getRoleColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
