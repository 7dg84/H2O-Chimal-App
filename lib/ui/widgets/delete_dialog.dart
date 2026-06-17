import 'package:flutter/material.dart';

void showDeleteDialog({
  required BuildContext context,
  String title = '¿Eliminar?',
  String message = 'Esta acción no se puede deshacer.',
  required Future<bool> Function() onConfirm,
  String successMessage = 'Eliminado con éxito',
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () async {
            // 1. Cerramos el diálogo usando su propio contexto
            Navigator.pop(dialogContext);

            // 2. Ejecutamos la acción de eliminación (pasada por parámetro)
            final success = await onConfirm();

            // 3. Si tuvo éxito y la pantalla sigue montada, regresamos y notificamos
            if (success && context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(successMessage),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: const Text('Eliminar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
          ),
        ),
      ],
    ),
  );
}