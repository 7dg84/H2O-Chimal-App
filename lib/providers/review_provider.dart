import 'package:app/models/review_model.dart';
import 'package:app/services/review_service.dart';
import 'package:flutter/material.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService;
  bool _isLoading = false;

  ReviewProvider(this._reviewService);

  Future<ReviewModel?> getReviewByReport(String reportId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());
    try {
      return await _reviewService.getReviewByReport(reportId);
    } catch (e) {
      debugPrint("Error fetching review: $e");
      return Future.error(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReviewModel?> getReviewByTramite(String tramiteId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());
    try {
      return await _reviewService.getReviewByTramite(tramiteId);
    } catch (e) {
      debugPrint("Error fetching review: $e");
      return Future.error(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReviewModel> createReview({
    String? tramite,
    String? report,
    required int value,
  }) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());
    try {
      if (tramite == null && report == null) {
        throw Exception("At least one of tramite or report must be provided");
      }
      if (tramite != null && report != null) {
        throw Exception("Only one of tramite or report can be provided");
      }
      return await _reviewService.createReview(
        tramite: tramite,
        report: report,
        value: value,
      );
    } catch (e) {
      print("Error creating review: $e");
      return Future.error(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
