import 'package:flutter/material.dart';
// Importa tus páginas
import 'package:biopago_sorteos_app/pages/index.dart'; // Página principal después de la instalación
import 'package:biopago_sorteos_app/pages/pago.dart'; // Página de pago
import 'package:biopago_sorteos_app/pages/exit.dart'; // Página de pago aceptado
import 'package:biopago_sorteos_app/pages/error.dart'; // Página de pago fallido
import 'package:biopago_sorteos_app/pages/initialization.dart'; // Nueva página de inicio (Botón Iniciar)
import 'package:biopago_sorteos_app/pages/biopago_service.dart'; // Servicio de Biopago
import 'package:biopago_sorteos_app/pages/installation.dart'; // Página de instalación

// Instancia global del servicio de Biopago (asumimos que está definida en tu proyecto real)
final BiopagoService biopagoService = BiopagoService();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos los colores para usar en todo el tema
    const Color customPrimaryColor = Color(0xFF004A72);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biopago BDV App',
      theme: ThemeData(
        // Usamos el color corporativo como principal
        primaryColor: customPrimaryColor,
        // Usamos un esquema de color para que los widgets se vean consistentes
        colorScheme: ColorScheme.fromSeed(seedColor: customPrimaryColor),
        // Configuraciones adicionales
        appBarTheme: const AppBarTheme(
          color: customPrimaryColor,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      // CRÍTICO: La aplicación debe iniciar en la página de inicialización interactiva.
      initialRoute: 'InitializationPage',

      // Definición de las rutas de tu aplicación
      routes: {
        '/': (context) =>
            const IndexPage(), // Ruta raíz (aunque usamos initialRoute)
        'IndexPage': (context) => const IndexPage(),
        'InitializationPage': (context) => const InitializationPage(),
        'InstallationPage': (context) => const InstallationPage(),
        'PagoPage': (context) => const PagoPage(),
        // Debes asegurar que estas páginas acepten argumentos si son llamadas con pushNamed.
        'PagoAceptadoPage': (context) => const PagoAceptadoPage(),
        'PagoFallidoPage': (context) => const PagoFallidoPage(
          // Asumo que esta es la ruta de error
          title: 'Error de Pago',
          mainMessage: 'Ha ocurrido un error inesperado.',
          errorDetail: 'Detalle no disponible.',
          dataSent: {},
        ),
      },
    );
  }
}
