// lib/pages/admin.dart

import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Clave de administrador fija
  static const String _adminPassword = "bio2025";

  // Controlador para el campo de texto de la contraseña
  final TextEditingController _passwordController = TextEditingController();

  // Estado para el mensaje de error
  String _errorMessage = '';

  // Función de validación y navegación
  void _authenticateAndNavigate() {
    final enteredPassword = _passwordController.text;

    if (enteredPassword == _adminPassword) {
      // Contraseña correcta: Limpiar mensaje de error y navegar
      setState(() {
        _errorMessage = '';
      });
      // Navegar a InitializationPage (Asegúrate de que esta ruta exista en main.dart)
      Navigator.pushReplacementNamed(context, 'InitializationPage');
    } else {
      // Contraseña incorrecta: Mostrar mensaje de error
      setState(() {
        _errorMessage = 'Contraseña incorrecta. Inténtalo de nuevo.';
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso de Administración')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Color(0xFF004A72),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ingresa la clave de administrador:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              // Campo de texto para la contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true, // Para ocultar la contraseña
                decoration: InputDecoration(
                  labelText: 'Clave de Administrador',
                  hintText: 'Ingresa tu clave',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                onFieldSubmitted: (value) =>
                    _authenticateAndNavigate(), // Permite usar Enter para enviar
              ),

              const SizedBox(height: 10),

              // Mensaje de error
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const SizedBox(height: 30),

              // Botón de acceso
              ElevatedButton(
                onPressed: _authenticateAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004A72),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 5,
                ),
                child: const Text(
                  'ACCEDER',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
