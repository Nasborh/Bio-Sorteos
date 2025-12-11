import 'package:flutter/material.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  void _goToPagoPage() {
    Navigator.pushNamed(context, "PagoPage");
  }

  // NUEVO: Función para ir a la página de administración
  void _goToAdminPage() {
    // Usamos Navigator.pushNamed para ir a la nueva ruta 'AdminPage'
    Navigator.pushNamed(context, "AdminPage");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // No usamos AppBar ya que todo está en el Stack
      // appBar: AppBar(title: const Text('Inicio')),
      body: Stack(
        children: [
          // Contenedor de la imagen de fondo
          Container(
            height: size.height,
            width: size.width,

            child: Image.asset(
              "assets/Index.png",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  alignment: Alignment.center,
                  child: const Text(
                    'Error: Imagen no encontrada.\nVerifica la ruta en pubspec.yaml.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              },
            ),
          ),

          // NUEVO: Botón de Configuración en la esquina superior derecha
          Positioned(
            top: 40.0, // Ajusta para evitar el notch/barra de estado
            right: 10.0,
            child: SafeArea(
              // Usar SafeArea asegura que esté debajo de la barra de estado
              child: IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Color(0xFF004A72), // Color corporativo
                  size: 30.0,
                ),
                onPressed:
                    _goToAdminPage, // Llama a la nueva función de navegación
                tooltip: 'Configuración de Administración',
              ),
            ),
          ),

          // Contenedor del botón INICIAR (el resto de tu código)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 40.0,
                left: 20.0,
                right: 20.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56.0,
                child: ElevatedButton(
                  onPressed: _goToPagoPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004A72),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 10,
                  ),
                  child: const Text(
                    'INICIAR',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
