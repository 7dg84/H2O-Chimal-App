import 'package:flutter/material.dart';
import '../core/config.dart';
import '../models/document_model.dart';

enum TramiteStatus { creado, enTramite, completado }

class TramiteModel {
  final String id;
  final String folio;
  final String service;
  final String serviceName;
  final DateTime createdAt;
  final TramiteStatus status;
  final String? notes;
  final List<TramiteDocumentModel>? documents;

  TramiteModel({
    required this.id,
    required this.folio,
    required this.service,
    required this.serviceName,
    required this.createdAt,
    required this.status,
    this.notes,
    this.documents,
  });

  factory TramiteModel.fromJson(Map<String, dynamic> json) {
    // Asegurar que el ID del servicio sea String
    String sId = '';
    if (json['service'] is String) {
      sId = json['service'];
    } else if (json['service'] is Map) {
      sId = json['service']['id']?.toString() ?? '';
    }

    // Asegurar que el nombre del servicio nunca sea nulo
    String sName = 'Servicio';
    if (json['service_name'] != null) {
      sName = json['service_name'].toString();
    } else if (json['service'] is Map) {
      sName = json['service']['name']?.toString() ?? 'Servicio';
    }

    return TramiteModel(
      id: json['id']?.toString() ?? '',
      folio: json['folio']?.toString() ?? '',
      service: sId,
      serviceName: sName,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      status: _parseStatus(json['status']),
      notes: json['notes'],
      documents: json['documents'] != null
          ? List<TramiteDocumentModel>.from(
              json['documents'].map((doc) => TramiteDocumentModel.fromJson(doc))
            )
          : null,
    );
  }

  static TramiteStatus _parseStatus(String? status) {
    switch (status) {
      case 'En tramite':
        return TramiteStatus.enTramite;
      case 'Completado':
        return TramiteStatus.completado;
      default:
        return TramiteStatus.creado;
    }
  }

  String get statusText {
    switch (status) {
      case TramiteStatus.enTramite: return 'En trámite';
      case TramiteStatus.completado: return 'Completado';
      default: return 'Creado';
    }
  }

  Color get statusColor {
    switch (status) {
      case TramiteStatus.enTramite: return AppConfig.statusInAttention;
      case TramiteStatus.completado: return AppConfig.statusResolved;
      default: return AppConfig.statusInReview;
    }
  }
}
