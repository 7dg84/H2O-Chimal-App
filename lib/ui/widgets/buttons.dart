import 'package:flutter/material.dart';
import '../../core/config.dart';

class EditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const EditButton({
    super.key,
    required this.onPressed,
    this.label = 'Editar',
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppConfig.primaryBlue,
        side: const BorderSide(color: AppConfig.primaryBlue),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const DeleteButton({
    super.key,
    required this.onPressed,
    this.label = 'Eliminar',
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      label: Text(
        label,
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
