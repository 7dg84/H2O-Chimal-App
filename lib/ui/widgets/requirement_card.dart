import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/config.dart';
import '../../models/service_model.dart';

class RequirementCard extends StatelessWidget {
  final ServiceRequirement requirement;
  final File? pickedFile;
  final VoidCallback onPickFile;
  final bool isUploading;

  const RequirementCard({
    super.key,
    required this.requirement,
    this.pickedFile,
    required this.onPickFile,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = pickedFile != null;
    final isPdf = hasFile && pickedFile!.path.toLowerCase().endsWith('.pdf');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                requirement.isRequired ? 'REQUERIDO' : 'OPCIONAL',
                style: const TextStyle(
                  color: AppConfig.primaryBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                hasFile 
                  ? (isPdf ? Icons.picture_as_pdf : Icons.image)
                  : _getIconForDocType(requirement.documentTypeName), 
                color: hasFile ? AppConfig.primaryBlue : Colors.grey[400], 
                size: 20
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            requirement.documentTypeName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            requirement.notes,
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: isUploading ? null : onPickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD1E0FF), style: BorderStyle.solid),
              ),
              child: isUploading 
                ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(hasFile ? Icons.check_circle : Icons.file_upload_outlined, 
                          size: 18, 
                          color: hasFile ? Colors.green : AppConfig.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        hasFile ? 'Cambiar archivo' : 'Adjuntar archivo',
                        style: TextStyle(
                          color: hasFile ? Colors.green : AppConfig.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
            ),
          ),
          if (hasFile) ...[
            const SizedBox(height: 8),
            Text(
              'Seleccionado: ${pickedFile!.path.split('/').last}',
              style: const TextStyle(fontSize: 11, color: Colors.grey, overflow: TextOverflow.ellipsis),
              maxLines: 1,
            ),
          ]
        ],
      ),
    );
  }

  IconData _getIconForDocType(String name) {
    final n = name.toLowerCase();
    if (n.contains('ine') || n.contains('identificación')) return Icons.badge_outlined;
    if (n.contains('domicilio')) return Icons.home_work_outlined;
    if (n.contains('escrituras') || n.contains('propiedad')) return Icons.assignment_outlined;
    return Icons.insert_drive_file_outlined;
  }
}
