import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../core/file_helper.dart';
import '../../models/service_model.dart';
import '../../providers/tramite_provider.dart';
import '../widgets/show_success_dialog.dart';
import '../widgets/requirement_card.dart';

class TramiteFormScreen extends StatefulWidget {
  final ServiceModel service;

  const TramiteFormScreen({super.key, required this.service});

  @override
  State<TramiteFormScreen> createState() => _TramiteFormScreenState();
}

class _TramiteFormScreenState extends State<TramiteFormScreen> {
  final Map<String, File> _pickedFiles = {};
  bool _isSubmitting = false;

  Future<void> _pickFile(String documentTypeId) async {
    final file = await FileHelper.pickDocument(context);
    if (file != null) {
      setState(() {
        _pickedFiles[documentTypeId] = file;
      });
    }
  }

  Future<void> _submit() async {
    for (var req in widget.service.requirements) {
      if (req.isRequired && !_pickedFiles.containsKey(req.documentTypeId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor adjunta: ${req.documentTypeName}')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final tramite = await context.read<TramiteProvider>().createTramite(
      widget.service.id,
      _pickedFiles,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (tramite != null) {
        showSuccessDialog(
          context: context, 
          folio: tramite.folio, 
          title: '¡Solicitud Enviada!', 
          message: 'Tu tramite ha sido registrado con el folio:'
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el trámite. Inténtalo de nuevo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Catalogo', style: TextStyle(fontSize: 18)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  widget.service.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConfig.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa el formulario y adjunta la documentación solicitada para iniciar tu trámite.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.5,
                          minHeight: 8,
                          backgroundColor: Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Paso 1 de 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Documentación Requerida',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...widget.service.requirements.map((req) => RequirementCard(
                  requirement: req,
                  pickedFile: _pickedFiles[req.documentTypeId],
                  onPickFile: () => _pickFile(req.documentTypeId),
                )),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003D82),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Enviar Solicitud', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Transform.rotate(angle: -0.5, child: const Icon(Icons.send, size: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF4B5563))),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
