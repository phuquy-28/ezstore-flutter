import 'package:flutter/material.dart';

class DetailDateInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback? onTap;

  const DetailDateInput({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      readOnly: true,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Chọn ngày sinh',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        suffixIcon: enabled
            ? IconButton(
                icon: const Icon(Icons.calendar_today,
                    size: 20, color: Colors.black),
                onPressed: onTap,
              )
            : null,
      ),
    );
  }
}
