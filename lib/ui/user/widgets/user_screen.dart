import 'package:ezstore_flutter/config/constants.dart';
import 'package:ezstore_flutter/domain/models/user/user.dart';
import 'package:ezstore_flutter/ui/core/shared/custom_app_bar.dart';
import 'package:ezstore_flutter/ui/core/shared/paginated_list_view.dart';
import 'package:ezstore_flutter/ui/core/shared/search_field.dart';
import 'package:ezstore_flutter/ui/drawer/widgets/custom_drawer.dart';
import 'package:ezstore_flutter/ui/user/view_models/user_screen_view_model.dart';
import 'package:flutter/material.dart';
import 'user_card.dart';

class UserScreen extends StatefulWidget {
  final UserScreenViewModel viewModel;

  const UserScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);

    // Theo dõi sự kiện cuộn
    _scrollController.addListener(_handleScroll);

    // Khởi tạo dữ liệu
    Future.microtask(() {
      widget.viewModel.initData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    if (mounted) {
      setState(() {
        _isLoading = widget.viewModel.isLoading;
      });
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.viewModel.handleScrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.users,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => widget.viewModel.navigateToAddUser(context),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Hiển thị loading khi đang tải dữ liệu ban đầu
    if (_isLoading && widget.viewModel.items == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hiển thị lỗi nếu có
    if (widget.viewModel.errorMessage != null) {
      return _buildErrorView();
    }

    // Hiển thị danh sách người dùng
    return _buildUserList();
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            "Đã xảy ra lỗi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.viewModel.errorMessage!,
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.viewModel.handleRetry,
            child: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return PaginatedListView<User>(
      items: widget.viewModel.items ?? [],
      isLoading: _isLoading,
      hasMoreData: widget.viewModel.hasMoreData,
      onLoadMore: widget.viewModel.loadMoreData,
      onRefresh: widget.viewModel.handleRefresh,
      padding: const EdgeInsets.all(0),
      separatorHeight: AppSizes.paddingSmall,
      showEmptyWidget: false,
      headerBuilder: (context) => _buildHeader(),
      itemBuilder: (context, user, index) => _buildUserItem(user),
      endOfListWidget: _buildEndOfList(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchField(
          hintText: "Tìm kiếm theo email, tên",
          initialValue: widget.viewModel.searchKeyword,
          onChanged: (value) {
            // Không làm gì khi thay đổi, chỉ cập nhật UI
          },
          onSubmitted: widget.viewModel.handleSearchSubmitted,
          onClear: widget.viewModel.handleClearSearch,
        ),
        _buildSearchResult(),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.paddingNormal),
          child: SizedBox(),
        ),
      ],
    );
  }

  Widget _buildSearchResult() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingNormal,
        right: AppSizes.paddingNormal,
        bottom: AppSizes.paddingSmall,
      ),
      child: Row(
        children: [
          Text(
            widget.viewModel.searchKeyword != null
                ? "Kết quả tìm kiếm: ${widget.viewModel.totalItems} người dùng"
                : "Tổng số: ${widget.viewModel.totalItems} người dùng",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (widget.viewModel.searchKeyword != null) ...[
            const SizedBox(width: 8),
            Text(
              "cho '${widget.viewModel.searchKeyword}'",
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserItem(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingNormal),
      child: UserCard(
        user: user,
        onViewDetails: () =>
            widget.viewModel.navigateToUserDetail(context, user.id),
        onDeleteUser: _handleDeleteUser,
        onEditSuccess: widget.viewModel.handleRefresh,
      ),
    );
  }

  Future<void> _handleDeleteUser(int userId) async {
    final success = await widget.viewModel.deleteUser(userId);
    if (mounted) {
      widget.viewModel.showDeleteResult(context, success);
    }
  }

  Widget _buildEndOfList() {
    return Text(
      widget.viewModel.searchKeyword != null
          ? "Đã hiển thị tất cả ${widget.viewModel.totalItems} kết quả cho '${widget.viewModel.searchKeyword}'"
          : "Đã hiển thị tất cả ${widget.viewModel.totalItems} người dùng",
      style: TextStyle(
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
