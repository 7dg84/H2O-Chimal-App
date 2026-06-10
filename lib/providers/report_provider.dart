import 'dart:io';
import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _reportService;
  List<ReportModel> _recentReports = [];
  bool _isLoading = false;

  ReportProvider(this._reportService);

  List<ReportModel> get recentReports => _recentReports;
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
      // 0. Validar que haya al menos una imagen y que las coordenadas sean válidas
      if (images.isEmpty || latitude == null || longitude == null) {
        return null;
      }
      latitude = double.parse(latitude.toStringAsFixed(10));
      longitude = double.parse(longitude.toStringAsFixed(10));

      // 1. Crear el reporte
      final report = await _reportService.createReport(
        latitude: latitude,
        longitude: longitude,
        locationText: locationText,
        reportType: reportType,
        description: description,
      );

      // 2. Subir múltiples imágenes asociadas al ID del reporte
      for (var image in images) {
        try {
          await _reportService.uploadMedia(report.id, image);
        } catch (e) {
          print("Error uploading image: $e");
          // Podríamos continuar con las demás imágenes o manejar el error
        }
      }

      await fetchRecentReports();
      return report;
    } catch (e) {
      print("Error creating report: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
