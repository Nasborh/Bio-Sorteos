import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para usar debugPrint
import '../main.dart'; // Para acceder a biopagoService
import 'dart:convert'; // Necesario para pretty-print el JSON

class InstallationPage extends StatefulWidget {
  const InstallationPage({super.key});

  @override
  State<InstallationPage> createState() => _InstallationPageState();
}

class _InstallationPageState extends State<InstallationPage> {
  // --- Variables de Estado y Controladores ---
  final _formKey = GlobalKey<FormState>();
  // Usar TextEditingController directamente
  final TextEditingController _affiliateCodeController =
      TextEditingController();
  final TextEditingController _installKeyController = TextEditingController();

  // El estado inicial ahora es mostrar el formulario directamente.
  String _statusMessage =
      "Ingrese el Código de Afiliado y la Clave de Instalación para registrar el certificado.";
  String _errorDetail = ""; // Detalle del error de Biopago o la excepción.
  bool _isProcessing = false; // Inicia en false para mostrar el formulario
  bool _hasError = false; // Bandera para el estado de error

  final Color customPrimaryColor = const Color(0xFF004A72); // Azul BDV
  final Color customErrorColor = const Color(0xFFD32F2F); // Rojo de error

  @override
  void initState() {
    super.initState();
    // No se realiza ninguna verificación de estado local, se muestra el formulario inmediatamente.
  }

  @override
  void dispose() {
    _affiliateCodeController.dispose();
    _installKeyController.dispose();
    super.dispose();
  }

  /// Ejecuta el comando 'install' de Biopago.
  Future<void> _executeInstallation() async {
    // 1. Validación del formulario
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _hasError = true;
        _isProcessing = false;
        _statusMessage = "Error en el formulario.";
        _errorDetail =
            "Por favor, complete correctamente el Código de Afiliado y la Clave de Instalación.";
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = "Ejecutando comando 'install' de Biopago...";
      _hasError = false;
      _errorDetail = "";
    });

    try {
      final String affiliateCode = _affiliateCodeController.text.trim();
      final String installKey = _installKeyController.text.trim();

      // Llamada al servicio
      final Map<String, String?> result = await biopagoService.install(
        affiliateCode: affiliateCode,
        installKey: installKey,
      );

      final status = result["result"];
      debugPrint('[INSTALL DEBUG] Resultado de Biopago: $result');

      // 2. Manejo de Éxito: Solo si el resultado es EXACTAMENTE "Installed"
      if (status == "Installed") {
        if (!mounted) return;

        // Redirigir directamente a la página principal (IndexPage).
        debugPrint('[INSTALL DEBUG] Instalación OK. Redirigiendo a IndexPage.');
        if (mounted) {
          Navigator.pushReplacementNamed(context, 'IndexPage');
        }
      } else {
        // 3. Manejo de Error de Biopago (Resultado no es "Installed" o es "CancelByUser")
        final errorMessage = result["message"] ?? "Fallo de instalación";
        final errorType = result["errorType"] ?? "Error Desconocido";

        // Prepara el mensaje principal para la UI (prioriza errorType sobre message).
        // Si el errorType es el mensaje de cancelación por defecto, mostramos el mensaje.
        final principalMessage =
            (errorType != "null" &&
                errorType.isNotEmpty &&
                errorType != "Error Desconocido" &&
                errorType != "El usuario canceló la operación.")
            ? errorType
            : errorMessage;

        // Formatea el resultado completo (que ahora incluye todos los extras de Kotlin) en JSON legible
        final Map<String, dynamic> dynamicResult = result.map(
          (k, v) => MapEntry(k, v),
        );
        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        final fullResponseJson = encoder.convert(dynamicResult);

        // Muestra el error
        _displayError(principalMessage, fullResponseJson);
      }
    } catch (e) {
      // 4. Manejo de Excepción de Flutter/Plataforma
      debugPrint('[INSTALL ERROR] Excepción al instalar: $e');
      _displayError("Error de plataforma al ejecutar el Intent.", e.toString());
    } finally {
      // Si no hubo error ni éxito, terminamos el proceso
      if (mounted && _isProcessing && !_hasError) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Muestra el estado de error en la interfaz.
  void _displayError(String errorMessage, String errorDetail) {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _hasError = true;
      _statusMessage = "ERROR: $errorMessage"; // Mensaje principal del error
      _errorDetail =
          errorDetail; // Detalle (respuesta JSON completa o stack trace)
    });
  }

  // --- Renderización de la Interfaz ---

  @override
  Widget build(BuildContext context) {
    // La vista siempre será el Scaffold principal con el formulario/estado.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instalación del Certificado'),
        backgroundColor: customPrimaryColor,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Icono de estado
              Icon(
                _isProcessing
                    ? Icons.lock_open
                    : (_hasError ? Icons.error_outline : Icons.vpn_key),
                color: _isProcessing
                    ? customPrimaryColor
                    : (_hasError ? customErrorColor : customPrimaryColor),
                size: 80,
              ),
              const SizedBox(height: 30),

              // Título y Mensaje de estado
              Text(
                'Paso 2: Registro de Afiliado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: customPrimaryColor,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: _hasError ? customErrorColor : Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              // Si está procesando la instalación, muestra solo el spinner.
              if (_isProcessing && !_hasError)
                const Center(child: CircularProgressIndicator())
              else if (_hasError)
                // Si hay un error, muestra el detalle del error y el botón de reintentar.
                _buildErrorView()
              else
                // Muestra el formulario.
                _buildFormView(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la vista del formulario de instalación.
  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo de Código de Afiliado
          TextFormField(
            controller: _affiliateCodeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Código de Afiliado (affiliateCode)',
              hintText: 'Mínimo 8 dígitos',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.person_pin),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El código de afiliado es requerido.';
              }
              // Asumiendo 8 dígitos como formato mínimo común
              if (value.length < 8 || !RegExp(r'^\d+$').hasMatch(value)) {
                return 'Debe ser al menos 8 dígitos numéricos.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Campo de Clave de Instalación
          TextFormField(
            controller: _installKeyController,
            keyboardType: TextInputType.text,
            obscureText: true, // Ocultar la clave
            decoration: InputDecoration(
              labelText: 'Clave de Instalación (installKey)',
              hintText: 'Clave única proporcionada por el banco.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.key),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La clave de instalación es requerida.';
              }
              // Usamos una longitud mínima de 7 caracteres para asegurar que no esté vacío.
              if (value.length < 7) {
                return 'La clave debe tener al menos 7 caracteres.';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),

          // Botón de Instalación
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _executeInstallation,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: customPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'INSTALAR CERTIFICADO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la vista de error.
  Widget _buildErrorView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Contenedor para mostrar el detalle del error
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: customErrorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: customErrorColor.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detalle de la Respuesta (Biopago Service):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              // SelectableText permite al usuario copiar el detalle del error
              SelectableText(
                _errorDetail.isNotEmpty
                    ? _errorDetail
                    : 'No se recibió una respuesta detallada del servicio.',
                textAlign: TextAlign.left,
                // Usamos monospace para que el JSON o el stack trace se vean bien
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            // Reinicia el estado para mostrar el formulario de nuevo
            setState(() {
              _hasError = false;
              _isProcessing = false;
              _statusMessage =
                  "Ingrese el Código de Afiliado y la Clave de Instalación para registrar el certificado.";
              _errorDetail = "";
            });
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            backgroundColor: customPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'VOLVER AL FORMULARIO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
