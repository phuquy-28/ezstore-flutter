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
  final int? preloadItemCount;
  final bool useListView;
  final int initialKeepAliveCount;
  final double? itemExtent;

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
    this.preloadItemCount = 5,
    this.useListView = true,
    this.initialKeepAliveCount = 10,
    this.itemExtent,
  }) : super(key: key);

  @override
  _PaginatedListViewState<T> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  Timer? _debounceTimer;

  // Optimization - track visible items for keeping alive
  final Set<int> _visibleItems = {};
  bool _hasInitializedViewport = false;

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
    _visibleItems.clear();
    super.dispose();
  }

  void _scrollListener() {
    // Check if we need to load more data
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

    // Track visible items for optimization
    if (_scrollController.hasClients) {
      _updateVisibleItems();
    }
  }

  void _updateVisibleItems() {
    if (!mounted || !_scrollController.hasClients) return;

    // Initialize viewport tracking if not already done
    if (!_hasInitializedViewport && widget.items.isNotEmpty) {
      _hasInitializedViewport = true;

      // Initially mark first few items as visible
      for (int i = 0;
          i < widget.initialKeepAliveCount && i < widget.items.length;
          i++) {
        _visibleItems.add(i);
      }
    }

    // Calculate current viewport
    final viewportHeight = _scrollController.position.viewportDimension;
    final startOffset = _scrollController.offset;
    final endOffset = startOffset + viewportHeight;

    // Placeholder for new visible items
    final Set<int> newVisibleItems = {};

    // Estimate item height (using either itemExtent or a reasonable default)
    final estimatedItemHeight = widget.itemExtent ?? 100.0;

    // Calculate approximate range of visible items
    int headerOffset = widget.headerBuilder != null ? 1 : 0;
    int startIndex = (startOffset / estimatedItemHeight).floor() - headerOffset;
    int endIndex = (endOffset / estimatedItemHeight).ceil() - headerOffset;

    // Adjust for header if needed
    startIndex = startIndex < 0 ? 0 : startIndex;

    // Add visible items plus preload items
    final preloadCount = widget.preloadItemCount ?? 5;
    final startPreload =
        (startIndex - preloadCount).clamp(0, widget.items.length - 1);
    final endPreload =
        (endIndex + preloadCount).clamp(0, widget.items.length - 1);

    for (int i = startPreload; i <= endPreload; i++) {
      if (i >= 0 && i < widget.items.length) {
        newVisibleItems.add(i);
      }
    }

    // Only update if the visible items have changed
    if (!_areSetEqual(_visibleItems, newVisibleItems)) {
      setState(() {
        _visibleItems.clear();
        _visibleItems.addAll(newVisibleItems);
      });
    }
  }

  bool _shouldKeepAlive(int index) {
    return _visibleItems.contains(index) ||
        index < widget.initialKeepAliveCount;
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

    // Calculate actual item count
    final int itemCount = widget.items.length +
        (widget.headerBuilder != null ? 1 : 0) +
        (!widget.hasMoreData && widget.items.isNotEmpty ? 1 : 0);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: widget.useListView
                ? _buildListView(itemCount)
                : _buildListViewBuilder(itemCount),
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

  // Optimized ListView.builder for better performance
  Widget _buildListViewBuilder(int itemCount) {
    return ListView.builder(
      key: PageStorageKey<String>('paginated_list_view_${T.toString()}'),
      controller: _scrollController,
      padding: widget.padding,
      itemCount: itemCount,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      cacheExtent: 1000, // Increased cache extent
      itemExtent: widget.itemExtent,
      itemBuilder: (context, index) =>
          _buildListItem(context, index, itemCount),
    );
  }

  // Using ListView which can be more efficient for certain use cases
  Widget _buildListView(int itemCount) {
    final List<Widget> children = [];

    // Add header if available
    if (widget.headerBuilder != null) {
      children.add(widget.headerBuilder!(context));
    }

    // Add all items with optimized wrapping
    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];

      // Create item with conditional AutomaticKeepAlive
      Widget itemWidget = widget.itemBuilder(context, item, i);

      // Only use keep alive for visible items to optimize memory
      if (_shouldKeepAlive(i)) {
        itemWidget = AutomaticKeepAliveWidget(
          child: RepaintBoundary(child: itemWidget),
        );
      } else {
        itemWidget = RepaintBoundary(child: itemWidget);
      }

      // Add the item to the list
      children.add(itemWidget);

      // Add separator if needed and not the last item
      if (i < widget.items.length - 1) {
        if (widget.separatorBuilder != null) {
          children.add(widget.separatorBuilder!(context, i));
        } else if (widget.separatorHeight != null) {
          children.add(SizedBox(height: widget.separatorHeight));
        }
      }
    }

    // Add end of list widget if needed
    if (!widget.hasMoreData && widget.items.isNotEmpty) {
      children.add(
        Center(
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
        ),
      );
    }

    return ListView(
      key: PageStorageKey<String>('paginated_list_view_${T.toString()}'),
      controller: _scrollController,
      padding: widget.padding,
      addAutomaticKeepAlives: false,
      cacheExtent: 1000,
      children: children,
    );
  }

  Widget _buildListItem(BuildContext context, int index, int itemCount) {
    // Show header if available
    if (widget.headerBuilder != null && index == 0) {
      return widget.headerBuilder!(context);
    }

    // Adjust index if header is present
    final adjustedIndex = widget.headerBuilder != null ? index - 1 : index;

    // Show end of list message
    if (!widget.hasMoreData && adjustedIndex == widget.items.length) {
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

    // Show item with proper index adjustment
    if (adjustedIndex >= 0 && adjustedIndex < widget.items.length) {
      final item = widget.items[adjustedIndex];

      // Create base item widget
      Widget itemWidget = widget.itemBuilder(context, item, adjustedIndex);

      // Conditionally apply performance optimizations
      if (_shouldKeepAlive(adjustedIndex)) {
        itemWidget = AutomaticKeepAliveWidget(
          child: RepaintBoundary(child: itemWidget),
        );
      } else {
        itemWidget = RepaintBoundary(child: itemWidget);
      }

      // Add separator if needed
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

    return SizedBox.shrink();
  }

  // Helper method to compare sets
  bool _areSetEqual(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.every((element) => b.contains(element));
  }
}

/// Custom widget to optimize keeping items alive
class AutomaticKeepAliveWidget extends StatefulWidget {
  final Widget child;

  const AutomaticKeepAliveWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _AutomaticKeepAliveWidgetState createState() =>
      _AutomaticKeepAliveWidgetState();
}

class _AutomaticKeepAliveWidgetState extends State<AutomaticKeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
