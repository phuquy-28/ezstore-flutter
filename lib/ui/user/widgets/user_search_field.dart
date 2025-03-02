import 'package:flutter/material.dart';
import '../../../config/constants.dart';

class UserSearchField extends StatelessWidget {
  final Function(String) onChanged;

  const UserSearchField({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingNormal,
        top: AppSizes.paddingNormal,
        right: AppSizes.paddingNormal,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppStrings.userSearchHint,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusNormal),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: onChanged,
      ),
    );
  }
} 