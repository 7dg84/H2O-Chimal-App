import 'package:app/models/review_model.dart';
import 'package:app/services/api_service.dart';

class ReviewService {
  final ApiService _apiService;

  ReviewService(this._apiService);

  Future<ReviewModel?> getReviewByReport(String reportId) async {
    try {
      final response = await _apiService.get('/reviews/', queryParameters: {'report': reportId});
      
      // La API devuelve un objeto con la estructura { "results": [...] }
      if (response.data != null && response.data['results'] is List) {
        final List results = response.data['results'];
        if (results.isNotEmpty) {
          return ReviewModel.fromJson(results.first);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<ReviewModel> createReview({
    String? tramite,
    String? report,
    required int value,
  }) async {
    try {
      final response = await _apiService.post(
        '/reviews/',
        data: {'tramite': tramite, 'report': report, 'value': value},
      );
      return ReviewModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
