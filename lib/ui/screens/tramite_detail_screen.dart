import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/config.dart';
import '../../models/document_model.dart';
import '../../models/tramite_model.dart';
import '../../providers/tramite_provider.dart';

class TramiteDetailScreen extends StatefulWidget {
  final String tramiteId;

  const TramiteDetailScreen({super.key, required this.tramiteId});

  @override
  State<TramiteDetailScreen> createState() => _TramiteDetailScreenState();
}

class _TramiteDetailScreenState extends State<TramiteDetailScreen> {
  TramiteModel? _tramite;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadTramite());
  }

  Future<void> _loadTramite() async {
    setState(() => _isLoading = true);
    final tramite = await context.read<TramiteProvider>().getTramiteDetail(
        widget.tramiteId);
    if (mounted) {
      setState(() {
        _tramite = tramite;
        _isLoading = false;
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
        title: const Text('Gestión de Agua'),
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
                _buildActionsSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading)
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
        border: const Border(
          left: BorderSide(color: AppConfig.primaryBlue, width: 6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
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
                  Text(
                    'FOLIO DEL TRÁMITE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    '#T-${_tramite!.folio}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppConfig.primaryBlue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sync, size: 14, color: Colors.orange[800]),
                    const SizedBox(width: 4),
                    Text(
                      _tramite!.statusText,
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'SERVICIO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.1,
            ),
          ),
          Text(
            _tramite!.serviceName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Text(
            'FECHA DE SOLICITUD',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18,
                  color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd \'de\' MMMM, yyyy', 'es').format(
                    _tramite!.createdAt),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado del Proceso',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
          width: 36,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppConfig.primaryBlue : const Color(0xFFCBD5E1),
            border: Border.all(
                color: isDone ? AppConfig.primaryBlue : Colors.white, width: 2),
          ),
          child: isCurrent
              ? const Icon(
              Icons.radio_button_checked, size: 18, color: Colors.white)
              : isDone
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : const Icon(Icons.more_horiz, size: 18, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDone ? AppConfig.primaryBlue : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(TramiteStatus stepBefore) {
    bool isDone = _tramite!.status.index > stepBefore.index;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isDone ? AppConfig.primaryBlue : const Color(0xFFCBD5E1),
      ),
    );
  }

  Widget _buildAdminNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: AppConfig.primaryBlue),
            SizedBox(width: 12),
            Text(
              'Notas del Administrador',
              style: TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.primaryBlue),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(12),
            border: const Border(
              left: BorderSide(color: AppConfig.primaryBlue, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Administración H2O',
                    style: TextStyle(fontWeight: FontWeight.bold,
                        color: AppConfig.primaryBlue),
                  ),
                  Text(
                    'Actualizado',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _tramite!.notes == null || _tramite!.notes!.isEmpty
                    ? 'No hay notas adicionales del administrador en este momento.'
                    : _tramite!.notes!,
                style: const TextStyle(
                    fontSize: 15, height: 1.5, color: Colors.black87),
              ),
              if (_tramite!.documents != null && _tramite!.documents!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Documentos adjuntos:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tramite!.documents!
                      .map((document) => _buildDocument(document))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    // Solo permitir acciones si el trámite no está completado
    bool canEdit = _tramite!.status != TramiteStatus.completado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Disponibles',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child:
            ElevatedButton(
              onPressed: canEdit ? () => _confirmCancelTramite() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppConfig.primaryBlue,
                side: const BorderSide(color: AppConfig.primaryBlue),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Editar Documentos'),
            ),
            ),
            const SizedBox(height: 12),
            Expanded(child:
            OutlinedButton.icon(
              onPressed: canEdit ? () => _confirmCancelTramite() : null,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Eliminar Reporte', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            ),
              const SizedBox(height: 40),
            // Expanded(
            //   child: OutlinedButton.icon(
            //     onPressed: canEdit ? () => _showEditDocumentsDialog() : null,
            //     icon: const Icon(Icons.edit_document),
            //     label: const Text('Editar Documentos'),
            //     style: OutlinedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(vertical: 12),
            //       side: const BorderSide(color: AppConfig.primaryBlue),
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 12),

            // Expanded(
            //   child: OutlinedButton.icon(
            //     onPressed: canEdit ? () => _confirmCancelTramite() : null,
            //     icon: const Icon(Icons.cancel_outlined),
            //     label: const Text('Cancelar Trámite'),
            //     style: OutlinedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(vertical: 12),
            //       foregroundColor: Colors.red,
            //       side: const BorderSide(color: Colors.red),
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  void _showEditDocumentsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gestionar Documentos',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (_tramite!.documents == null || _tramite!.documents!.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('No hay documentos subidos.')),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _tramite!.documents!.length,
                        itemBuilder: (context, index) {
                          final doc = _tramite!.documents![index];
                          return ListTile(
                            leading: const Icon(Icons.description, color: AppConfig.primaryBlue),
                            title: Text(doc.filename, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteDocument(doc.id, setModalState),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _uploadNewDocument(setModalState),
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Subir Nuevo Documento'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteDocument(String documentId, StateSetter setModalState) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar documento?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await context.read<TramiteProvider>().deleteDocument(documentId);
      if (success) {
        await _loadTramite();
        setModalState(() {});
      }
    }
  }

  Future<void> _uploadNewDocument(StateSetter setModalState) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Nota: Aquí necesitaríamos el documentTypeId. Para este ejemplo rápido, 
      // usaremos uno genérico o pediremos al usuario que lo identifique.
      // Por ahora, asumiremos que el backend acepta un ID por defecto para adjuntos adicionales.
      
      final success = await context.read<TramiteProvider>().uploadAdditionalDocument(
        _tramite!.id, 
        'default', // Idealmente obtener de los requisitos del servicio
        File(image.path)
      );

      if (success) {
        await _loadTramite();
        setModalState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documento subido con éxito')),
          );
        }
      }
    }
  }

  Future<void> _confirmCancelTramite() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar Trámite?'),
        content: const Text('Se eliminará tu solicitud. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No, mantener')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await context.read<TramiteProvider>().deleteTramite(_tramite!.id);
      if (success && mounted) {
        Navigator.pop(context); // Volver a la lista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trámite cancelado con éxito')),
        );
      }
    }
  }

  Widget _buildDocument(TramiteDocumentModel document) {
    return InkWell(
      onTap: () => _downloadDocument(document.id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
                Icons.attachment, size: 16, color: AppConfig.primaryBlue),
            const SizedBox(width: 8),
            Text(
                document.filename,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  decoration: TextDecoration.underline,
                )
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadDocument(String documentId) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparando descarga...'),
            duration: Duration(seconds: 1)),
      );

      final docDetail = await context.read<TramiteProvider>().getDocumentDetail(
          documentId);

      if (docDetail != null && docDetail.presignedUrl != null) {
        final Uri url = Uri.parse(docDetail.presignedUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw 'No se pudo abrir el enlace de descarga';
        }
      } else {
        throw 'No se encontró la URL del documento';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }
}
