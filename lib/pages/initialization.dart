import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../main.dart'; // Asegúrate de que biopagoService esté aquí

class InitializationPage extends StatefulWidget {
  const InitializationPage({super.key});

  @override
  State<InitializationPage> createState() => _InitializationPageState();
}

class _InitializationPageState extends State<InitializationPage> {
  // --- Variables de Estado y Controladores ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _environmentController = TextEditingController(
    text: 'production',
  );
  final TextEditingController _connectionTypeController = TextEditingController(
    text: 'direct',
  );

  String _statusMessage =
      "Seleccione los parámetros e inicie la configuración de Biopago.";
  String _errorDetail = "";
  bool _isProcessing = false;
  bool _hasError = false;

  final List<String> environments = ['production', 'development'];
  final List<String> connectionTypes = ['direct'];

  final Color customPrimaryColor = const Color(0xFF004A72);
  final Color customErrorColor = const Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    // Intenta auto-inicializar o se queda esperando la interacción
  }

  @override
  void dispose() {
    _environmentController.dispose();
    _connectionTypeController.dispose();
    super.dispose();
  }

  /// Ejecuta el comando 'initialize' de Biopago.
  Future<void> _executeInitialization() async {
    // 1. Validación del formulario
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _hasError = true;
        _isProcessing = false;
        _statusMessage = "Error en el formulario.";
        _errorDetail =
            "Por favor, seleccione el ambiente y el tipo de conexión.";
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = "Ejecutando comando 'initialize' de Biopago...";
      _hasError = false;
      _errorDetail = "";
    });

    try {
      final String environment = _environmentController.text;
      final String connectionType = _connectionTypeController.text;

      // Llamada al servicio
      final Map<String, String?> result = await biopagoService.initialize(
        environment: environment,
        connectionType: connectionType,
      );

      final status = result["result"];
      debugPrint('[INIT DEBUG] Resultado de Biopago: $result');

      // 2. Manejo de Éxito: LA CLAVE ESTÁ AQUÍ. El resultado debe ser "Initialized".
      if (status == "Initialized") {
        if (!mounted) return;

        // Redirigir a la siguiente página (InstallationPage)
        debugPrint(
          '[INIT DEBUG] Inicialización OK. Redirigiendo a InstallationPage.',
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, 'InstallationPage');
        }
      } else {
        // 3. Manejo de Fallo de Biopago (cualquier otro resultado)
        final errorMessage = result["message"] ?? "Fallo inesperado";
        final errorType = result["errorType"] ?? status ?? "Error Desconocido";

        // Prepara el mensaje principal para la UI
        final principalMessage =
            (errorType != "null" &&
                errorType.isNotEmpty &&
                errorType != "Error Desconocido")
            ? errorType
            : errorMessage;

        // Formatea el resultado completo en JSON legible
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
      debugPrint('[INIT ERROR] Excepción al inicializar: $e');
      _displayError("Error de plataforma al ejecutar el Intent.", e.toString());
    } finally {
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
      _statusMessage = "ERROR: $errorMessage";
      _errorDetail = errorDetail;
    });
  }

  // --- Renderización de la Interfaz ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Biopago BDV'),
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
                    ? Icons.settings
                    : (_hasError
                          ? Icons.error_outline
                          : Icons.settings_input_component),
                color: _isProcessing
                    ? customPrimaryColor
                    : (_hasError ? customErrorColor : customPrimaryColor),
                size: 80,
              ),
              const SizedBox(height: 30),

              Text(
                'Paso 1: Parámetros de Inicialización',
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

              if (_isProcessing && !_hasError)
                const Center(child: CircularProgressIndicator())
              else if (_hasError)
                _buildErrorView()
              else
                _buildFormView(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la vista del formulario de inicialización.
  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dropdown de Ambiente (Environment)
          _buildDropdownField(
            controller: _environmentController,
            label: 'Ambiente (Environment)',
            options: environments,
            icon: Icons.cloud_queue,
          ),
          const SizedBox(height: 20),

          // Dropdown de Tipo de Conexión (ConnectionType)
          _buildDropdownField(
            controller: _connectionTypeController,
            label: 'Tipo de Conexión (ConnectionType)',
            options: connectionTypes,
            icon: Icons.wifi,
          ),
          const SizedBox(height: 40),

          // Botón de Inicialización
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _executeInitialization,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: customPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'INICIAR COMUNICACIÓN',
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

  /// Widget Helper para los Dropdowns
  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required List<String> options,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: Icon(icon),
      ),
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.toUpperCase()),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          controller.text = newValue;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es requerido.';
        }
        return null;
      },
    );
  }

  /// Construye la vista de error.
  Widget _buildErrorView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
              SelectableText(
                _errorDetail.isNotEmpty
                    ? _errorDetail
                    : 'No se recibió una respuesta detallada del servicio.',
                textAlign: TextAlign.left,
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
            setState(() {
              _hasError = false;
              _isProcessing = false;
              _statusMessage =
                  "Seleccione los parámetros e inicie la configuración de Biopago.";
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
            'REINTENTAR COMUNICACIÓN',
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
