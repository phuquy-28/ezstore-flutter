import 'package:flutter/material.dart';

class DetailDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final bool enabled;
  final Map<String, dynamic>? valueMap;

  const DetailDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
    this.valueMap,
  });

  @override
  Widget build(BuildContext context) {
    String displayValue = value;

    if (valueMap != null) {
      // Kiểm tra xem value có phải là một trong các giá trị trong valueMap không
      bool isValueInMap = valueMap!.values.any(
          (v) => v.toString().toUpperCase() == value.toString().toUpperCase());

      if (isValueInMap) {
        // Tìm key trong valueMap có value = this.value
        final entry = valueMap!.entries.firstWhere(
          (entry) =>
              entry.value.toString().toUpperCase() ==
              value.toString().toUpperCase(),
          orElse: () => MapEntry<String, dynamic>(value, value),
        );
        displayValue = entry.key;
      }
    }

    // Kiểm tra xem displayValue có trong danh sách items không
    if (!items.contains(displayValue)) {
      // Nếu không có, sử dụng giá trị đầu tiên trong danh sách
      displayValue = items.first;
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        color: enabled ? Colors.white : Colors.grey[100],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: displayValue,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
          onChanged: enabled
              ? (String? newValue) {
                  if (newValue != null && onChanged != null) {
                    onChanged!(newValue);
                  }
                }
              : null,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
