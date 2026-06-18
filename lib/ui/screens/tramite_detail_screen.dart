import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config.dart';
import '../../core/file_helper.dart';
import '../../models/document_model.dart';
import '../../models/tramite_model.dart';
import '../../models/service_model.dart';
import '../../providers/tramite_provider.dart';
import '../../providers/service_provider.dart';
import '../widgets/buttons.dart';
import '../widgets/delete_dialog.dart';
import '../widgets/requirement_card.dart';

class TramiteDetailScreen extends StatefulWidget {
  final String tramiteId;

  const TramiteDetailScreen({super.key, required this.tramiteId});

  @override
  State<TramiteDetailScreen> createState() => _TramiteDetailScreenState();
}

class _TramiteDetailScreenState extends State<TramiteDetailScreen> {
  TramiteModel? _tramite;
  ServiceModel? _service;
  bool _isLoading = true;
  bool _isActionInProgress = false;
  
  // Almacena archivos seleccionados localmente antes de subirlos
  final Map<String, File> _newFiles = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tramite = await context.read<TramiteProvider>().getTramiteDetail(widget.tramiteId);
      if (mounted && tramite != null) {
        _tramite = tramite;
        // Obtenemos los requisitos del servicio asociado
        final service = await context.read<ServiceProvider>().getServiceDetail(tramite.service);
        if (mounted) {
          setState(() {
            _service = service;
            _isLoading = false;
          });
        }
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshTramite() async {
    final tramite = await context.read<TramiteProvider>().getTramiteDetail(widget.tramiteId);
    if (mounted) {
      setState(() {
        _tramite = tramite;
        _newFiles.clear(); // Limpiar selección tras subir con éxito
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _tramite == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_tramite == null) {
      return const Scaffold(body: Center(child: Text('Trámite no encontrado')));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConfig.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detalle de Solicitud'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildStatusCard(),
                const SizedBox(height: 24),
                _buildAdminNotesSection(),
                const SizedBox(height: 24),
                _buildDocumentManagementSection(), // Integración directa de tarjetas
                const SizedBox(height: 24),
                _buildDangerZone(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isActionInProgress)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: AppConfig.primaryBlue, width: 6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FOLIO DEL TRÁMITE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.1)),
                  Text('#T-${_tramite!.folio}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue)),
                ],
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 24),
          Text('SERVICIO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.1)),
          Text(_tramite!.serviceName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text('FECHA DE SOLICITUD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Text(DateFormat('dd \'de\' MMMM, yyyy', 'es').format(_tramite!.createdAt), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(Icons.sync, size: 14, color: Colors.orange[800]),
          const SizedBox(width: 4),
          Text(_tramite!.statusText, style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado del Proceso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineStep('Creado', TramiteStatus.creado),
              _buildTimelineConnector(TramiteStatus.creado),
              _buildTimelineStep('En trámite', TramiteStatus.enTramite),
              _buildTimelineConnector(TramiteStatus.enTramite),
              _buildTimelineStep('Completado', TramiteStatus.completado),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, TramiteStatus step) {
    bool isDone = _tramite!.status.index >= step.index;
    bool isCurrent = _tramite!.status == step;
    return Column(
      children: [
        Container(
          width: 36, height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppConfig.primaryBlue : const Color(0xFFCBD5E1),
            border: Border.all(color: isDone ? AppConfig.primaryBlue : Colors.white, width: 2),
          ),
          child: isCurrent ? const Icon(Icons.radio_button_checked, size: 18, color: Colors.white) : isDone ? const Icon(Icons.check, size: 18, color: Colors.white) : const Icon(Icons.more_horiz, size: 18, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDone ? AppConfig.primaryBlue : Colors.grey[500])),
      ],
    );
  }

  Widget _buildTimelineConnector(TramiteStatus stepBefore) {
    bool isDone = _tramite!.status.index > stepBefore.index;
    return Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 20), color: isDone ? AppConfig.primaryBlue : const Color(0xFFCBD5E1)));
  }

  Widget _buildAdminNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [Icon(Icons.chat_bubble_outline, color: AppConfig.primaryBlue), SizedBox(width: 12), Text('Notas del Administrador', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConfig.primaryBlue))]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(12), border: const Border(left: BorderSide(color: AppConfig.primaryBlue, width: 4))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Administración H2O', style: TextStyle(fontWeight: FontWeight.bold, color: AppConfig.primaryBlue)), Text('Actualizado', style: TextStyle(fontSize: 12, color: Colors.grey[600]))]),
              const SizedBox(height: 12),
              Text(_tramite!.notes ?? 'No hay notas adicionales del administrador.', style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentManagementSection() {
    bool canEdit = _tramite!.status == TramiteStatus.creado;
    
    // OBTENER NOMBRES DE DOCUMENTOS YA SUBIDOS
    final uploadedTypeNames = _tramite!.documents?.map((doc) => doc.name).toSet() ?? {};
    
    // FILTRAR REQUISITOS FALTANTES
    final missingRequirements = _service?.requirements.where(
      (req) => !uploadedTypeNames.contains(req.documentTypeName)
    ).toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Documentación del Trámite', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        // 1. Documentos actuales (Revisión/Descarga)
        if (_tramite!.documents != null && _tramite!.documents!.isNotEmpty) ...[
          const Text('Archivos subidos actualmente:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          ..._tramite!.documents!.map((doc) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: ListTile(
              leading: const Icon(Icons.description_outlined, color: AppConfig.primaryBlue),
              title: Text(doc.name, style: const TextStyle(fontSize: 14, decoration: TextDecoration.underline)),
              onTap: () => _downloadDocument(doc.id),
              trailing: canEdit ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDeleteDocument(doc.id),
              ) : null,
            ),
          )),
          const SizedBox(height: 24),
        ],

        // 2. Subida de requisitos faltantes (SOLO LOS QUE NO ESTÁN ARRIBA)
        if (canEdit && missingRequirements.isNotEmpty) ...[
          const Text('Añadir documentación faltante:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          ...missingRequirements.map((req) => RequirementCard(
            requirement: req,
            pickedFile: _newFiles[req.documentTypeId],

            onPickFile: () async {
              final file = await FileHelper.pickDocument(context);
              if (file != null) setState(() => _newFiles[req.documentTypeId] = file);
            },
          )),
          const SizedBox(height: 16),
          if (_newFiles.isNotEmpty)
            ElevatedButton.icon(
              onPressed: _isActionInProgress ? null : _submitNewDocuments,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Enviar Documentos Seleccionados'),
              style: ElevatedButton.styleFrom(backgroundColor: AppConfig.primaryBlue, minimumSize: const Size(double.infinity, 54)),
            ),
        ] else if (canEdit && missingRequirements.isEmpty) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Has cumplido con todos los requisitos.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDangerZone() {
    if (_tramite!.status != TramiteStatus.creado) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 48),
        const Text('Zona de Peligro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 12),
        DeleteButton(
          onPressed: _confirmCancelTramite,
          label: 'Cancelar toda la solicitud',
        ),
      ],
    );
  }

  Future<void> _submitNewDocuments() async {
    setState(() => _isActionInProgress = true);
    try {
      for (var entry in _newFiles.entries) {
        await context.read<TramiteProvider>().uploadAdditionalDocument(
          _tramite!.id, 
          entry.key, 
          entry.value
        );
      }
      await _refreshTramite();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documentos actualizados con éxito')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir documentos: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isActionInProgress = false);
    }
  }

  void _confirmDeleteDocument(String id) {
    showDeleteDialog(
      context: context,
      title: '¿Eliminar documento?',
      onConfirm: () async {
        final ok = await context.read<TramiteProvider>().deleteDocument(id);
        if (ok) await _refreshTramite();
        return ok;
      }
    );
  }

  void _confirmCancelTramite() {
    showDeleteDialog(
      context: context,
      title: '¿Cancelar Trámite?',
      message: 'Esta acción eliminará permanentemente tu solicitud.',
      successMessage: 'Trámite cancelado',
      onConfirm: () async {
        final ok = await context.read<TramiteProvider>().deleteTramite(_tramite!.id);
        if (ok && mounted) Navigator.pop(context);
        return ok;
      }
    );
  }

  Future<void> _downloadDocument(String id) async {
    try {
      final docDetail = await context.read<TramiteProvider>().getDocumentDetail(id);
      if (docDetail?.presignedUrl != null) {
        final Uri url = Uri.parse(docDetail!.presignedUrl!);
        if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error al descargar: $e');
    }
  }
}
