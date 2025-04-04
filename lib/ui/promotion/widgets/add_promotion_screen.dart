import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_date_input.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_text_field.dart';
import 'package:ezstore_flutter/ui/promotion/widgets/category_selector_widget.dart';
import 'package:ezstore_flutter/ui/promotion/widgets/product_selector_widget.dart';
import 'package:ezstore_flutter/ui/promotion/view_models/add_promotion_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPromotionScreen extends StatefulWidget {
  final AddPromotionViewModel viewModel;

  const AddPromotionScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  State<AddPromotionScreen> createState() => _AddPromotionScreenState();
}

class _AddPromotionScreenState extends State<AddPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_viewModelListener);

    // Khởi tạo ban đầu
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Tải danh sách danh mục và sản phẩm ban đầu
    await widget.viewModel.loadCategories(refresh: true);
    await widget.viewModel.loadProducts(refresh: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _scrollController.dispose();

    widget.viewModel.removeListener(_viewModelListener);
    super.dispose();
  }

  void _viewModelListener() {
    if (mounted) {
      setState(() {
        // Cập nhật UI khi có thay đổi trong viewModel
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = isStartDate
        ? (widget.viewModel.startDate ?? now)
        : (widget.viewModel.endDate ??
            (widget.viewModel.startDate?.add(const Duration(days: 7)) ??
                now.add(const Duration(days: 7))));

    final DateTime firstDate =
        isStartDate ? now : (widget.viewModel.startDate ?? now);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Hiển thị định dạng thân thiện với người dùng
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);

      if (isStartDate) {
        widget.viewModel.updateStartDate(picked);
        setState(() {
          _startDateController.text = formattedDate;
        });

        // Nếu ngày kết thúc đã chọn và nhỏ hơn ngày bắt đầu mới, cập nhật ngày kết thúc
        if (widget.viewModel.endDate != null &&
            widget.viewModel.endDate!.isBefore(picked)) {
          final newEndDate = picked.add(const Duration(days: 7));
          widget.viewModel.updateEndDate(newEndDate);
          setState(() {
            _endDateController.text =
                DateFormat('dd/MM/yyyy').format(newEndDate);
          });
        }
      } else {
        widget.viewModel.updateEndDate(picked);
        setState(() {
          _endDateController.text = formattedDate;
        });
      }
    }
  }

  // Xử lý khi bấm nút tạo khuyến mãi
  Future<void> _handleCreatePromotion() async {
    // Cập nhật tất cả các giá trị vào view model
    widget.viewModel.updateName(_nameController.text);
    widget.viewModel.updateDescription(_descriptionController.text);
    widget.viewModel.updateDiscountRate(_discountController.text);

    // Reset validation
    widget.viewModel.resetValidation();

    // Kiểm tra lỗi validation
    if (!widget.viewModel.validateAll()) {
      // Hiển thị lỗi và cuộn đến phần lỗi đầu tiên
      if (widget.viewModel.nameErrorText != null) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else if (widget.viewModel.discountRateErrorText != null) {
        _scrollController.animateTo(150,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      } else if (widget.viewModel.dateRangeErrorText != null) {
        _scrollController.animateTo(300,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.nameErrorText ??
              widget.viewModel.discountRateErrorText ??
              widget.viewModel.dateRangeErrorText ??
              widget.viewModel.selectionErrorText ??
              'Vui lòng kiểm tra lại thông tin nhập vào'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Thực hiện tạo khuyến mãi
    final success = await widget.viewModel.createPromotion();

    if (!mounted) return;

    if (success) {
      // Xóa các dữ liệu đã nhập
      _nameController.clear();
      _descriptionController.clear();
      _discountController.clear();
      _startDateController.clear();
      _endDateController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo khuyến mãi thành công'),
          backgroundColor: Colors.green,
        ),
      );

      // Quay về màn hình trước đó
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(widget.viewModel.errorMessage ?? 'Tạo khuyến mãi thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailAppBar(
        title: 'Thêm khuyến mãi mới',
        onEditToggle: () {},
        isEditMode: false,
        showEditButton: false,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
                // Tên khuyến mãi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailTextField(
                      controller: _nameController,
                      label: 'Tên khuyến mãi',
                      hintText: 'Nhập tên khuyến mãi',
                      enabled: true,
                      textColor: Colors.black,
                      fillColor: Colors.white,
                      onChanged: (value) {
                        widget.viewModel.updateName(value);
                      },
                    ),
                    if (widget.viewModel.nameErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                        child: Text(
                          widget.viewModel.nameErrorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Mô tả khuyến mãi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mô tả khuyến mãi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Nhập mô tả chi tiết khuyến mãi',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        fillColor: Colors.white,
                        filled: true,
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
                      ),
                      onChanged: (value) {
                        widget.viewModel.updateDescription(value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Phần trăm giảm giá
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailTextField(
                      controller: _discountController,
                      label: 'Phần trăm giảm giá',
                      hintText: 'Nhập phần trăm giảm giá',
                      enabled: true,
                      textColor: Colors.black,
                      fillColor: Colors.white,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        widget.viewModel.updateDiscountRate(value);
                      },
                    ),
                    if (widget.viewModel.discountRateErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                        child: Text(
                          widget.viewModel.discountRateErrorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Thời gian khuyến mãi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thời gian khuyến mãi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ngày bắt đầu',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DetailDateInput(
                                controller: _startDateController,
                                onTap: () => _selectDate(context, true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ngày kết thúc',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DetailDateInput(
                                controller: _endDateController,
                                onTap: () => _selectDate(context, false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.viewModel.dateRangeErrorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                        child: Text(
                          widget.viewModel.dateRangeErrorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Phần áp dụng khuyến mãi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Áp dụng khuyến mãi cho',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sử dụng CategorySelectorWidget cho phần chọn danh mục
                      CategorySelectorWidget(
                        categories: widget.viewModel.categories,
                        selectedCategoryIds:
                            widget.viewModel.selectedCategoryIds,
                        onToggleSelection:
                            widget.viewModel.toggleCategorySelection,
                        onLoadMore: () => widget.viewModel.loadCategories(),
                        isLoading: widget.viewModel.isLoadingCategories,
                        hasMoreItems: widget.viewModel.hasMoreCategories,
                      ),

                      const SizedBox(height: 16),

                      // Sử dụng ProductSelectorWidget cho phần chọn sản phẩm
                      ProductSelectorWidget(
                        products: widget.viewModel.products,
                        selectedProductIds: widget.viewModel.selectedProductIds,
                        onToggleSelection:
                            widget.viewModel.toggleProductSelection,
                        onLoadMore: () => widget.viewModel.loadProducts(),
                        onSearch: (keyword) => widget.viewModel
                            .loadProducts(refresh: true, keyword: keyword),
                        onClearSearch: () => widget.viewModel
                            .loadProducts(refresh: true, keyword: ''),
                        isLoading: widget.viewModel.isLoadingProducts,
                        hasMoreItems: widget.viewModel.hasMoreProducts,
                      ),
                    ],
                  ),
                ),

                if (widget.viewModel.selectionErrorText != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      widget.viewModel.selectionErrorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                CustomButton(
                  text: 'Tạo khuyến mãi',
                  onPressed: _handleCreatePromotion,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // Loading overlay
          if (widget.viewModel.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
