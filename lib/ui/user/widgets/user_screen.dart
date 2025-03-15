import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ezstore_flutter/ui/user/view_models/user_screen_view_model.dart';
import '../../drawer/widgets/custom_drawer.dart';
import '../../core/shared/custom_app_bar.dart';
import '../../../config/constants.dart';
import 'search_field.dart';
import 'user_card.dart';
import 'add_user_screen.dart';

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
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Gọi loadMoreUsers khi cuộn đến cuối trang
        Provider.of<UserScreenViewModel>(context, listen: false)
            .loadMoreUsers();
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
        Provider.of<UserScreenViewModel>(context, listen: false).fetchUsers();
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddUserScreen()),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          SearchField(
            onChanged: (value) => {},
          ),
          if (viewModel.isLoading && viewModel.users == null)
            // Hiển thị loading khi đang tải dữ liệu lần đầu
            Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (viewModel.users?.isEmpty ?? true)
            // Hiển thị thông báo khi danh sách rỗng
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Danh sách người dùng rỗng",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Không tìm thấy người dùng nào",
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Hiển thị danh sách người dùng
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSizes.paddingNormal),
                itemCount: viewModel.users?.length ?? 0,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSizes.paddingSmall),
                itemBuilder: (context, index) {
                  final user = viewModel.users![index];
                  return UserCard(
                    user: user,
                    onViewDetails: () {
                      // Bỏ qua logic điều hướng
                    },
                  );
                },
              ),
            ),
          if (viewModel.isLoading &&
              viewModel.users != null) // Hiển thị loading khi tải thêm
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
