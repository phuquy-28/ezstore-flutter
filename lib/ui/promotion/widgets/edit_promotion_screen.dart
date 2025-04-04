import 'package:ezstore_flutter/ui/core/shared/custom_button.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_app_bar.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_date_input.dart';
import 'package:ezstore_flutter/ui/core/shared/detail_text_field.dart';
import 'package:ezstore_flutter/ui/promotion/widgets/category_selector_widget.dart';
import 'package:ezstore_flutter/ui/promotion/widgets/product_selector_widget.dart';
import 'package:ezstore_flutter/ui/promotion/view_models/edit_promotion_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditPromotionScreen extends StatefulWidget {
  final EditPromotionViewModel viewModel;
  final int promotionId;

  const EditPromotionScreen({
    Key? key,
    required this.viewModel,
    required this.promotionId,
  }) : super(key: key);

  @override
  State<EditPromotionScreen> createState() => _EditPromotionScreenState();
}

class _EditPromotionScreenState extends State<EditPromotionScreen> {
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

    // Tải dữ liệu khuyến mãi cần chỉnh sửa
    _loadPromotionData();
  }

  Future<void> _loadPromotionData() async {
    await widget.viewModel.loadPromotionById(widget.promotionId);

    if (widget.viewModel.isInitialized) {
      // Điền dữ liệu vào các trường nhập liệu
      _nameController.text = widget.viewModel.name;
      _descriptionController.text = widget.viewModel.description;
      _discountController.text = widget.viewModel.discountRate.toString();

      if (widget.viewModel.startDate != null) {
        _startDateController.text =
            widget.viewModel.formatDate(widget.viewModel.startDate!);
      }

      if (widget.viewModel.endDate != null) {
        _endDateController.text =
            widget.viewModel.formatDate(widget.viewModel.endDate!);
      }
    }
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

  // Xử lý khi bấm nút cập nhật khuyến mãi
  Future<void> _handleUpdatePromotion() async {
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

    // Thực hiện cập nhật khuyến mãi
    final success = await widget.viewModel.updatePromotion();

    if (!mounted) return;

    if (success) {
      // Lưu context để sử dụng sau khi pop
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      // Quay về màn hình trước đó với kết quả true để báo hiệu cập nhật thành công
      Navigator.of(context).pop(true);

      // Hiện thông báo thành công sau khi đã rời khỏi màn hình hiện tại
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Cập nhật khuyến mãi thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              widget.viewModel.errorMessage ?? 'Cập nhật khuyến mãi thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị màn hình loading khi đang tải dữ liệu ban đầu
    if (!widget.viewModel.isInitialized && widget.viewModel.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Hiển thị thông báo lỗi nếu không thể tải dữ liệu
    if (!widget.viewModel.isInitialized &&
        widget.viewModel.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chỉnh sửa khuyến mãi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPromotionData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DetailAppBar(
        title: 'Chỉnh sửa khuyến mãi',
        onEditToggle: () {},
        isEditMode: true,
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
                  text: 'Cập nhật khuyến mãi',
                  onPressed: _handleUpdatePromotion,
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
