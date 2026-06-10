import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _reportService;
  List<ReportModel> _recentReports = [];
  List<ReportCoordinate> _reportCoordinates = [];
  bool _isLoading = false;

  ReportProvider(this._reportService);

  List<ReportModel> get recentReports => _recentReports;
  List<ReportCoordinate> get reportCoordinates => _reportCoordinates;
  bool get isLoading => _isLoading;

  Future<void> fetchRecentReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      _recentReports = await _reportService.getRecentReports(limit: 20);
    } catch (e) {
      print("Error fetching recent reports: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReportCoordinates() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reportCoordinates = await _reportService.getReportCoordinates();
    } catch (e) {
      print("Error fetching report coordinates: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReportModel?> getReportDetail(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _reportService.getReportDetail(id);
    } catch (e) {
      print("Error fetching report detail: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ReportModel?> createReport({
    required double latitude,
    required double longitude,
    required String locationText,
    required String reportType,
    required String description,
    List<File> images = const [],
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final report = await _reportService.createReport(
        latitude: latitude,
        longitude: longitude,
        locationText: locationText,
        reportType: reportType,
        description: description,
      );

      for (var image in images) {
        try {
          await _reportService.uploadMedia(report.id, image);
        } catch (e) {
          print("Error uploading image: $e");
        }
      }

      await fetchRecentReports();
      await fetchReportCoordinates();
      return report;
    } catch (e) {
      print("Error creating report: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReport(String id, {
    double? latitude,
    double? longitude,
    String? locationText,
    String? reportType,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _reportService.updateReport(id,
        latitude: latitude,
        longitude: longitude,
        locationText: locationText,
        reportType: reportType,
        description: description,
      );
      await fetchRecentReports();
      await fetchReportCoordinates();
      return true;
    } catch (e) {
      print("Error updating report: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReport(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _reportService.deleteReport(id);
      _recentReports.removeWhere((r) => r.id == id);
      _reportCoordinates.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      print("Error deleting report: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
