import 'dart:async';
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
  final bool showEmptyWidget;

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
    this.showEmptyWidget = true,
  }) : super(key: key);

  @override
  _PaginatedListViewState<T> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoadingMore &&
        !widget.isLoading &&
        widget.hasMoreData &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                widget.loadMoreThreshold) {
      // Debounce the load more call to prevent multiple calls
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          _isLoadingMore = true;
          widget.onLoadMore().then((_) {
            if (mounted) {
              setState(() {
                _isLoadingMore = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.showEmptyWidget) {
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
        (!widget.hasMoreData && widget.items.isNotEmpty
            ? 1
            : 0); // Chỉ hiển thị thông báo cuối danh sách khi có dữ liệu

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: ListView.builder(
              key:
                  PageStorageKey<String>('paginated_list_view_${T.toString()}'),
              controller: _scrollController,
              padding: widget.padding,
              itemCount: itemCount,
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
              cacheExtent: 500,
              itemExtent: null,
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
                  // Use a key based on item identity to help Flutter efficiently update the list
                  final itemWidget = KeyedSubtree(
                    key: ValueKey<String>(
                        'item_${adjustedIndex}_${item.hashCode}'),
                    child: widget.itemBuilder(context, item, adjustedIndex),
                  );

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
