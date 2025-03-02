import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../data/models/user.dart';

class UserDetails extends StatelessWidget {
  final User user;

  const UserDetails({super.key, required this.user});

  Color getRoleColor() {
    switch (user.role) {
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(width: AppSizes.paddingSmall),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingNormal),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.userDetails,
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
          const SizedBox(height: AppSizes.paddingNormal),
          _buildDetailRow('${AppStrings.name}:', user.name),
          _buildDetailRow('${AppStrings.email}:', user.email),
          _buildDetailRow('${AppStrings.dateOfBirth}:', user.dateOfBirth),
          _buildDetailRow('${AppStrings.gender}:', user.gender),
          Row(
            children: [
              const Text('${AppStrings.role}:'),
              const SizedBox(width: AppSizes.paddingSmall),
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
                  user.role,
                  style: TextStyle(
                    color: getRoleColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 