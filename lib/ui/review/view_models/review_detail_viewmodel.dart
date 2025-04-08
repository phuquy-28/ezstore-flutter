import 'package:ezstore_flutter/domain/models/review/widgets/review_response.dart';
import 'package:ezstore_flutter/data/repositories/review_repository.dart';
import 'package:ezstore_flutter/data/models/review/req_publish_review.dart';
import 'package:flutter/foundation.dart';

class ReviewDetailViewModel extends ChangeNotifier {
  final ReviewRepository _reviewRepository;
  ReviewResponse? _review;
  bool _isLoading = false;
  String? _error;

  ReviewDetailViewModel(this._reviewRepository);

  ReviewResponse? get review => _review;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setReview(ReviewResponse review) {
    _review = review;
    notifyListeners();
  }

  Future<void> togglePublished() async {
    if (_review != null) {
      try {
        _isLoading = true;
        notifyListeners();

        final reqPublishReview = ReqPublishReview(
          reviewId: _review!.reviewId!,
          published: !(_review!.published ?? false),
        );

        final updatedReview =
            await _reviewRepository.publishReview(reqPublishReview);
        if (updatedReview != null) {
          _review = updatedReview;
        }
      } catch (e) {
        _error = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> deleteReview() async {
    if (_review != null) {
      try {
        _isLoading = true;
        notifyListeners();

        await _reviewRepository.deleteReview(_review!.reviewId!);
      } catch (e) {
        _error = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}
