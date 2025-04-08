import 'package:ezstore_flutter/ui/review/view_models/review_screen_viewmodel.dart';
import 'package:flutter/material.dart';

class ReviewFilter extends StatelessWidget {
  final ReviewScreenViewModel viewModel;

  const ReviewFilter({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  int? get ratingFilter => viewModel.ratingFilter;
  bool? get publishedFilter => viewModel.publishedFilter;
  bool get hasActiveFilters => viewModel.hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc',
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
          const SizedBox(height: 8),
          _buildFilterOption(
            context,
            'Đánh giá',
            ratingFilter != null ? '$ratingFilter sao' : null,
            () => _showRatingFilter(context),
          ),
          _buildFilterOption(
            context,
            'Trạng thái',
            publishedFilter != null
                ? (publishedFilter! ? 'Công khai' : 'Ẩn')
                : null,
            () => _showPublishedFilter(context),
          ),
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    viewModel.clearFilters();
                  },
                  child: const Text('Xóa tất cả bộ lọc'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String title,
    String? currentValue,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: currentValue != null
          ? Text(
              currentValue,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            )
          : const Text('Tất cả'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showRatingFilter(BuildContext context) {
    final options = List.generate(5, (index) => '${index + 1} sao');
    _showFilterOptions(
      context,
      'Đánh giá',
      options,
      ratingFilter != null ? '${ratingFilter} sao' : null,
      (value) {
        if (value == null) {
          viewModel.setRatingFilter(null);
        } else {
          viewModel.setRatingFilter(int.parse(value.split(' ')[0]));
        }
      },
    );
  }

  void _showPublishedFilter(BuildContext context) {
    final options = ['Công khai', 'Ẩn'];
    _showFilterOptions(
      context,
      'Trạng thái',
      options,
      publishedFilter != null ? (publishedFilter! ? 'Công khai' : 'Ẩn') : null,
      (value) {
        if (value == null) {
          viewModel.setPublishedFilter(null);
        } else {
          viewModel.setPublishedFilter(value == 'Công khai');
        }
      },
    );
  }

  void _showFilterOptions(
    BuildContext context,
    String title,
    List<String> options,
    String? currentValue,
    Function(String?) setter,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...options.map((option) => ListTile(
                      title: Text(option),
                      trailing: currentValue == option
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setter(option);
                        setState(() {});
                        Navigator.pop(context);
                      },
                    )),
                ListTile(
                  title: const Text('Tất cả',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: currentValue == null
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setter(null);
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
