// TODO: insights provider | Author: Rajat Mahajan
// Provider: InsightsProvider — state management for insights/patterns

import 'package:flutter/foundation.dart';

import '../services/insight_service.dart';

class InsightsProvider extends ChangeNotifier {
  final InsightService _insightService = InsightService();

  // Temporary placeholder user until auth is implemented in Month 2
  static const String _tempUserId = 'local_user_01';

  Insights _insights = Insights.empty();
  bool _isLoading = false;
  String? _error;

  Insights get insights => _insights;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> calculateInsights() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _insights = await _insightService.getInsights(_tempUserId);
    } catch (e) {
      _error = 'Error calculating insights.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
