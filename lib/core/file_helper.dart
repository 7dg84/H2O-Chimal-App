import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FileHelper {
  static Future<File?> pickDocument(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar archivo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
              title: const Text('Cámara (Foto)'),
              onTap: () async {
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80, // Comprimimos un poco para la subida
                );
                if (context.mounted) Navigator.pop(context, image != null ? File(image.path) : null);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.blue),
              title: const Text('Galería (Imagen)'),
              onTap: () async {
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (context.mounted) Navigator.pop(context, image != null ? File(image.path) : null);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
              title: const Text('Documento PDF'),
              onTap: () async {
                try {
                  // Implementación compatible con la versión 11.x
                  final result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                    allowMultiple: false,
                    withData: true,
                    readSequential: true,
                  );
                  
                  if (context.mounted) {
                    if (result != null && result.files.isNotEmpty) {
                      final path = result.files.first.path;
                      Navigator.pop(context, path != null ? File(path) : null);
                    } else {
                      Navigator.pop(context, null);
                    }
                  }
                } catch (e) {
                  debugPrint('Error en FilePicker: $e');
                  if (context.mounted) {
                    Navigator.pop(context, null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al acceder a los archivos')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<File?> pickImage(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar archivo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
              title: const Text('Cámara (Foto)'),
              onTap: () async {
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80, // Comprimimos un poco para la subida
                );
                if (context.mounted) Navigator.pop(context, image != null ? File(image.path) : null);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.blue),
              title: const Text('Galería (Imagen)'),
              onTap: () async {
                final picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (context.mounted) Navigator.pop(context, image != null ? File(image.path) : null);
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
            //   title: const Text('Documento PDF'),
            //   onTap: () async {
            //     try {
            //       // Implementación compatible con la versión 11.x
            //       final result = await FilePicker.pickFiles(
            //         type: FileType.custom,
            //         allowedExtensions: ['pdf'],
            //         allowMultiple: false,
            //         withData: true,
            //         readSequential: true,
            //       );
            //
            //       if (context.mounted) {
            //         if (result != null && result.files.isNotEmpty) {
            //           final path = result.files.first.path;
            //           Navigator.pop(context, path != null ? File(path) : null);
            //         } else {
            //           Navigator.pop(context, null);
            //         }
            //       }
            //     } catch (e) {
            //       debugPrint('Error en FilePicker: $e');
            //       if (context.mounted) {
            //         Navigator.pop(context, null);
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           const SnackBar(content: Text('Error al acceder a los archivos')),
            //         );
            //       }
            //     }
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
