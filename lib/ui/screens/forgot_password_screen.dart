import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../providers/auth_provider.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _handleRequestReset() async {
    if (_formKey.currentState!.validate()) {
      final result = await context.read<AuthProvider>().requestPasswordReset(
        _emailController.text,
      );

      if (mounted) {
        if (result.containsKey('message')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(email: _emailController.text),
            ),
          );
        } else {
          final errorMessage = result['error'] ?? 'Ocurrió un error inesperado';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.lock_reset,
                  size: 64,
                  color: AppConfig.primaryBlue,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa tu correo electrónico y te enviaremos un código para restablecer tu contraseña.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 32),
              const Text('Correo Electrónico', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingrese su correo';
                  if (!value.contains('@')) return 'Ingrese un correo válido';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleRequestReset,
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Continuar'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
