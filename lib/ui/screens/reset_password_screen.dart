import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config.dart';
import '../../providers/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final result = await context.read<AuthProvider>().confirmPasswordReset(
        _emailController.text,
        _codeController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (result.containsKey('message')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          // Volver al login después de éxito
          Navigator.of(context).popUntil((route) => route.isFirst);
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
        title: const Text('Restablecer Contraseña'),
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
                  Icons.vpn_key_outlined,
                  size: 64,
                  color: AppConfig.primaryBlue,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Casi listo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConfig.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa el código que enviamos a tu correo y tu nueva contraseña.',
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
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Código de Verificación', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: 'Ingresa el código',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingrese el código';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Nueva Contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '********',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingrese su nueva contraseña';
                  if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleResetPassword,
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Restablecer Contraseña'),
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
