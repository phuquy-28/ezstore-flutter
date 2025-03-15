import 'package:flutter/material.dart';

typedef ItemBuilder<T> = Widget Function(
    BuildContext context, T item, int index);
typedef LoadMoreCallback = Future<void> Function();
typedef RefreshCallback = Future<void> Function();
typedef HeaderBuilder = Widget Function(BuildContext context);

class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final ItemBuilder<T> itemBuilder;
  final LoadMoreCallback onLoadMore;
  final RefreshCallback onRefresh;
  final bool isLoading;
  final bool hasMoreData;
  final Widget? loadingIndicator;
  final Widget? emptyWidget;
  final Widget? endOfListWidget;
  final EdgeInsetsGeometry padding;
  final double loadMoreThreshold;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final double? separatorHeight;
  final HeaderBuilder? headerBuilder;

  const PaginatedListView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    required this.isLoading,
    required this.hasMoreData,
    this.loadingIndicator,
    this.emptyWidget,
    this.endOfListWidget,
    this.padding = const EdgeInsets.all(16.0),
    this.loadMoreThreshold = 200.0,
    this.separatorBuilder,
    this.separatorHeight,
    this.headerBuilder,
  }) : super(key: key);

  @override
  _PaginatedListViewState<T> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      if (!widget.isLoading && widget.hasMoreData) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Không có dữ liệu",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
    }

    // Tính toán số lượng item thực tế trong ListView
    int itemCount = widget.items.length +
        (widget.headerBuilder != null ? 1 : 0) +
        (!widget.hasMoreData ? 1 : 0); // Thêm 1 cho thông báo cuối danh sách

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              padding: widget.padding,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                // Hiển thị header nếu có và nếu đang ở vị trí đầu tiên
                if (widget.headerBuilder != null && index == 0) {
                  return widget.headerBuilder!(context);
                }

                // Điều chỉnh index nếu có header
                final adjustedIndex =
                    widget.headerBuilder != null ? index - 1 : index;

                // Hiển thị thông báo cuối danh sách
                if (!widget.hasMoreData &&
                    adjustedIndex == widget.items.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: widget.endOfListWidget ??
                          Text(
                            "Đã hiển thị tất cả dữ liệu",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                    ),
                  );
                }

                if (adjustedIndex >= 0 && adjustedIndex < widget.items.length) {
                  final item = widget.items[adjustedIndex];
                  final itemWidget =
                      widget.itemBuilder(context, item, adjustedIndex);

                  // Thêm separator nếu cần và không phải item cuối cùng
                  if (widget.separatorBuilder != null &&
                      adjustedIndex < widget.items.length - 1) {
                    return Column(
                      children: [
                        itemWidget,
                        widget.separatorBuilder!(context, adjustedIndex),
                      ],
                    );
                  } else if (widget.separatorHeight != null &&
                      adjustedIndex < widget.items.length - 1) {
                    return Column(
                      children: [
                        itemWidget,
                        SizedBox(height: widget.separatorHeight),
                      ],
                    );
                  }

                  return itemWidget;
                }

                return SizedBox.shrink(); // Không nên xảy ra
              },
            ),
          ),
        ),
        if (widget.isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.loadingIndicator ?? CircularProgressIndicator(),
          ),
      ],
    );
  }
}
