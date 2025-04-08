import 'package:ezstore_flutter/domain/models/review/widgets/review_response.dart';
import 'package:ezstore_flutter/ui/core/view_models/paginated_view_model_mixin.dart';
import 'package:ezstore_flutter/ui/review/widgets/review_filter.dart';
import 'package:ezstore_flutter/data/repositories/review_repository.dart';
import 'package:ezstore_flutter/data/models/review/req_publish_review.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class ReviewScreenViewModel extends ChangeNotifier
    with PaginatedViewModelMixin<ReviewResponse> {
  final ReviewRepository _reviewRepository;
  String? _searchKeyword;
  String? _lastAppliedSearchKeyword;
  bool _isSearching = false;
  Map<String, List<ReviewResponse>> _cachedReviews = {};
  final TextEditingController searchController = TextEditingController();
  String? _errorMessage;

  // Filter states
  int? _ratingFilter;
  bool? _publishedFilter;

  ReviewScreenViewModel(this._reviewRepository) {
    setPageSize(10); // Set default page size
  }

  String? get searchKeyword => _searchKeyword;
  int get totalReviews => totalItems;
  String? get error => _errorMessage;
  bool get hasMorePages => hasMoreData;
  bool get isSearching => _isSearching;
  int? get ratingFilter => _ratingFilter;
  bool? get publishedFilter => _publishedFilter;

  bool get hasActiveFilters =>
      _ratingFilter != null || _publishedFilter != null;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void initData() {
    if (items == null) {
      loadFirstPage();
    }
  }

  @override
  Future<PaginationResult<ReviewResponse>?> fetchData(
      int page, int pageSize) async {
    try {
      final response = await _reviewRepository.getAllReviews(
        page: page,
        pageSize: pageSize,
        keyword: _searchKeyword,
        rating: _ratingFilter,
        published: _publishedFilter,
      );

      if (response != null) {
        return PaginationResult<ReviewResponse>(
          data: response.data,
          totalItems: response.meta.total,
          totalPages: response.meta.pages,
          currentPage: page,
        );
      }
      return null;
    } catch (e) {
      dev.log('Error fetching reviews: $e');
      _errorMessage = 'Không thể tải danh sách đánh giá. Vui lòng thử lại.';
      notifyListeners();
      return null;
    }
  }

  Future<void> searchReviews(String keyword) async {
    if (_searchKeyword == keyword && _lastAppliedSearchKeyword == keyword) {
      return;
    }

    _searchKeyword = keyword.isNotEmpty ? keyword : null;
    searchController.text = keyword;
    await refresh();
  }

  void clearSearch() {
    if (_searchKeyword != null) {
      _searchKeyword = null;
      _lastAppliedSearchKeyword = null;
      searchController.clear();
      _cachedReviews.clear();
      refresh();
    }
  }

  void setRatingFilter(int? rating) {
    if (_ratingFilter != rating) {
      _ratingFilter = rating;
      _cachedReviews.clear();
      refresh();
    }
  }

  void setPublishedFilter(bool? published) {
    if (_publishedFilter != published) {
      _publishedFilter = published;
      _cachedReviews.clear();
      refresh();
    }
  }

  void clearFilters() {
    bool hasFilters = _ratingFilter != null || _publishedFilter != null;

    if (hasFilters) {
      _ratingFilter = null;
      _publishedFilter = null;
      _cachedReviews.clear();
      refresh();
    }
  }

  List<ReviewResponse> getFilteredReviews() {
    if (items == null) return [];

    var filteredItems = List<ReviewResponse>.from(items!);

    if (_ratingFilter != null) {
      filteredItems = filteredItems
          .where((review) => review.rating == _ratingFilter)
          .toList();
    }

    if (_publishedFilter != null) {
      filteredItems = filteredItems
          .where((review) => review.published == _publishedFilter)
          .toList();
    }

    return filteredItems;
  }

  Future<void> loadFirstPage() {
    return loadData(page: 0);
  }

  Future<void> loadNextPage() {
    return loadMoreData();
  }

  @override
  Future<void> refresh() async {
    _cachedReviews.clear();
    super.refresh();
  }

  void handleSearchSubmitted(String value) {
    searchReviews(value);
  }

  void handleClearSearch() {
    clearSearch();
  }

  void handleScrollToEnd() {
    if (!isLoading && hasMoreData) {
      loadMoreData();
    }
  }

  void handleRetry() {
    _cachedReviews.clear();
    loadFirstPage();
  }

  Future<void> handleRefresh() async {
    await refresh();
  }

  void showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ReviewFilter(viewModel: this),
    );
  }

  Future<void> togglePublished(ReviewResponse review) async {
    try {
      final reqPublishReview = ReqPublishReview(
        reviewId: review.reviewId!,
        published: !(review.published ?? false),
      );

      final updatedReview =
          await _reviewRepository.publishReview(reqPublishReview);
      if (updatedReview != null) {
        // Update the review in the list
        final index = items?.indexWhere((r) => r.reviewId == review.reviewId);
        if (index != null && index != -1) {
          items![index] = updatedReview;
          notifyListeners();
        }
      }
    } catch (e) {
      dev.log('Error toggling review published status: $e');
      _errorMessage =
          'Không thể cập nhật trạng thái đánh giá. Vui lòng thử lại.';
      notifyListeners();
    }
  }

  Future<void> deleteReview(ReviewResponse review) async {
    try {
      await _reviewRepository.deleteReview(review.reviewId!);
      // Remove the review from the list
      items?.removeWhere((r) => r.reviewId == review.reviewId);
      notifyListeners();
    } catch (e) {
      dev.log('Error deleting review: $e');
      _errorMessage = 'Không thể xóa đánh giá. Vui lòng thử lại.';
      notifyListeners();
    }
  }
}
