import 'package:ezstore_flutter/domain/models/user/user.dart';
import 'package:ezstore_flutter/routing/app_routes.dart';
import 'package:ezstore_flutter/ui/core/shared/paginated_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ezstore_flutter/ui/user/view_models/user_screen_view_model.dart';
import '../../drawer/widgets/custom_drawer.dart';
import '../../core/shared/custom_app_bar.dart';
import '../../../config/constants.dart';
import '../../core/shared/search_field.dart';
import 'user_card.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Theo dõi sự kiện cuộn
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Gọi loadMoreUsers khi cuộn gần đến cuối trang
        final viewModel =
            Provider.of<UserScreenViewModel>(context, listen: false);
        if (!viewModel.isLoading && viewModel.hasMoreData) {
          viewModel.loadMoreData();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Giải phóng bộ điều khiển cuộn
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chỉ gọi fetchUsers một lần sau khi widget được khởi tạo
    if (!_isInitialized) {
      _isInitialized = true;
      // Sử dụng Future.microtask để đảm bảo gọi sau khi build hoàn tất
      Future.microtask(() {
        Provider.of<UserScreenViewModel>(context, listen: false).loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserScreenViewModel>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.users,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addUser),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          if (viewModel.isLoading && viewModel.items == null)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (viewModel.errorMessage != null)
            Expanded(
              child: Center(
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
                      viewModel.errorMessage!,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.loadData(),
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: PaginatedListView<User>(
                items: viewModel.items ?? [],
                isLoading: viewModel.isLoading,
                hasMoreData: viewModel.hasMoreData,
                onLoadMore: () => viewModel.loadMoreData(),
                onRefresh: () => viewModel.refresh(),
                padding: const EdgeInsets.all(0),
                separatorHeight: AppSizes.paddingSmall,
                showEmptyWidget: false,
                headerBuilder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchField(
                      hintText: "Tìm kiếm theo email, tên",
                      initialValue: viewModel.searchKeyword,
                      onChanged: (value) {
                        // Không làm gì khi thay đổi, chỉ cập nhật UI
                      },
                      onSubmitted: (value) {
                        // Gọi tìm kiếm khi người dùng nhấn Enter
                        viewModel.searchUsers(value);
                      },
                      onClear: () {
                        // Xóa tìm kiếm và tải lại dữ liệu ban đầu
                        viewModel.clearSearch();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSizes.paddingNormal,
                        right: AppSizes.paddingNormal,
                        bottom: AppSizes.paddingSmall,
                      ),
                      child: Row(
                        children: [
                          Text(
                            viewModel.searchKeyword != null
                                ? "Kết quả tìm kiếm: ${viewModel.totalItems} người dùng"
                                : "Tổng số: ${viewModel.totalItems} người dùng",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          if (viewModel.searchKeyword != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              "cho '${viewModel.searchKeyword}'",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingNormal),
                      child: SizedBox(),
                    ),
                  ],
                ),
                itemBuilder: (context, user, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingNormal),
                    child: UserCard(
                      user: user,
                      onViewDetails: () {
                        // Mở UserDetailScreen ở chế độ xem khi nhấn vào UserCard
                        Navigator.pushNamed(
                          context,
                          AppRoutes.userDetail,
                          arguments: {'id': user.id},
                        );
                      },
                    ),
                  );
                },
                endOfListWidget: Text(
                  viewModel.searchKeyword != null
                      ? "Đã hiển thị tất cả ${viewModel.totalItems} kết quả cho '${viewModel.searchKeyword}'"
                      : "Đã hiển thị tất cả ${viewModel.totalItems} người dùng",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
