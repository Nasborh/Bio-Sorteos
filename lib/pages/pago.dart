import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../main.dart';
import 'exit.dart';
import 'error.dart';

class PagoPage extends StatefulWidget {
  const PagoPage({super.key});

  @override
  State<PagoPage> createState() => _PagoPageState();
}

class _PagoPageState extends State<PagoPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _dialogKey = GlobalKey<State>();
  final Color customPrimaryColor = const Color(0xFF004A72);

  // Valores seleccionados
  String? _selectedDocumentType;
  String? _selectedBank = 'Banco de Venezuela';
  String? _selectedPaymentMethod;

  // Listas de opciones
  final List<String> _documentTypes = ['V', 'E'];
  final List<String> _paymentMethods = ['Ahorro', 'Corriente'];

  // Controladores para los campos de texto
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _diagnosticData = 'Esperando intento de pago...';

  // --- ESTRUCTURA DE DATOS CON WIDGET Image.asset PARA LOGOS ---
  final List<Map<String, dynamic>> _bankOptions = [
    {
      'name': 'Banco de Venezuela',
      'code': '0102',
      'icon': Image.asset('assets/BDV.png', height: 24),
    },
    {
      'name': 'Banesco',
      'code': '0134',
      'icon': Image.asset('assets/BANESCO.png', height: 24),
    },
    {
      'name': 'BBVA Provincial',
      'code': '0108',
      'icon': Image.asset('assets/provincial.png', height: 24),
    },
    {
      'name': 'Mercantil',
      'code': '0105',
      'icon': Image.asset('assets/mercantil.png', height: 24),
    },
    {
      'name': 'Banco Digital de los trabajadores',
      'code': '0175',
      'icon': Image.asset('assets/bdt.png', height: 24),
    },
    {
      'name': 'BNC',
      'code': '0191',
      'icon': Image.asset('assets/bnc.png', height: 24),
    },
    {
      'name': 'Bancamiga',
      'code': '0172',
      'icon': Image.asset('assets/bancamiga.png', height: 24),
    },
    {
      'name': 'Banco del Tesoro',
      'code': '0163',
      'icon': Image.asset('assets/tesoro.png', height: 24),
    },
    {
      'name': 'BANFANB',
      'code': '0177',
      'icon': Image.asset('assets/banfanb.png', height: 24),
    },
    {
      'name': 'Banplus',
      'code': '0174',
      'icon': Image.asset('assets/banplus.png', height: 24),
    },
    {
      'name': 'Bancaribe',
      'code': '0114',
      'icon': Image.asset('assets/bancaribe.png', height: 24),
    },
    {
      'name': 'Banco Exterior',
      'code': '0115',
      'icon': Image.asset('assets/exterior.jpg', height: 24),
    },
    {
      'name': 'Banco Caroní',
      'code': '0128',
      'icon': Image.asset('assets/caroni.png', height: 24),
    },
    {
      'name': 'Banco Fondo Común',
      'code': '0151',
      'icon': Image.asset('assets/bfc.png', height: 24),
    },
    {
      'name': 'Venezolano de Crédito',
      'code': '0104',
      'icon': Image.asset('assets/vdc.png', height: 24),
    },
    {
      'name': 'Banco Activo',
      'code': '0171',
      'icon': Image.asset('assets/activo.png', height: 24),
    },
    {
      'name': 'Banco Plaza',
      'code': '0138',
      'icon': Image.asset('assets/plaza.png', height: 24),
    },
    {
      'name': '100% Banco',
      'code': '0156',
      'icon': Image.asset('assets/100banco.png', height: 24),
    },
    {
      'name': 'Bancrecer',
      'code': '0168',
      'icon': Image.asset('assets/bancrecer.png', height: 24),
    },
    {
      'name': 'Del Sur',
      'code': '0157',
      'icon': Image.asset('assets/delsur.png', height: 24),
    },
    {
      'name': 'R4',
      'code': '0169',
      'icon': Image.asset('assets/r4.png', height: 24),
    },
  ];

  // --- Mapeo de Códigos MODIFICADO para usar _bankOptions ---
  String _getPaymentGroupCode(String? bankName) {
    final selectedBankData = _bankOptions.firstWhere(
      (bank) => bank['name'] == bankName,
      orElse: () => {'code': '0000', 'name': '', 'icon': null},
    );
    return selectedBankData['code'] ?? '0000';
  }

  String _getPaymentMethodCode(String? paymentMethod) {
    if (paymentMethod == 'Ahorro') return 'CA';
    if (paymentMethod == 'Corriente') return 'CC';
    return 'XX'; // Default
  }
  // --------------------------

  /// Función para cerrar el diálogo de carga usando el GlobalKey
  void _dismissLoadingDialog() {
    final dialogContext = _dialogKey.currentContext;
    if (dialogContext != null && mounted) {
      Navigator.of(dialogContext, rootNavigator: true).pop();
    }
  }

  // Función que se llama al presionar el botón de pagar
  Future<void> _handlePayment() async {
    // 1. VALIDACIÓN INICIAL
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _diagnosticData = 'Error: Campos del formulario inválidos.';
      });
      return;
    }

    // --- Extracción y Preparación de Datos ---
    final identificationNumber = _numberController.text.trim();
    final amountTextForParsing = _amountController.text
        .replaceAll(',', '.')
        .trim();
    final double? rawAmount = double.tryParse(amountTextForParsing);

    if (rawAmount == null || rawAmount <= 0) {
      setState(
        () => _diagnosticData = 'Error: Monto no válido después de validación.',
      );
      return;
    }

    final double amountForBiopago = rawAmount;
    final identificationLetter = _selectedDocumentType ?? 'V';
    final paymentGroupCode = _getPaymentGroupCode(_selectedBank);
    final paymentMethodCode = _getPaymentMethodCode(_selectedPaymentMethod);

    // Datos que serán enviados (útiles para diagnóstico en caso de error)
    final Map<String, dynamic> dataToSend = {
      "paymentGroup": paymentGroupCode,
      "paymentMethod": paymentMethodCode,
      "identificationLetter": identificationLetter,
      "identificationNumber": identificationNumber,
      "amount": amountForBiopago,
    };

    // 2. MOSTRAR DIÁLOGO DE CARGA Y DATOS DE ENVÍO
    setState(() {
      _diagnosticData =
          'Datos a enviar a BiopagoService (Monto como Double):\n' +
          dataToSend.entries.map((e) => '  ${e.key}: ${e.value}').join('\n');
    });

    // Mostrar diálogo de carga.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          key: _dialogKey,
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(
                "Esperando App Biopago BDV...",
                style: TextStyle(color: customPrimaryColor),
              ),
            ],
          ),
        );
      },
    );

    // Limpiamos el formulario antes de la llamada
    _numberController.clear();
    _amountController.clear();

    try {
      // 3. Llamada al servicio Biopago (Comando: process)
      final Map<String, String?> result = await biopagoService.process(
        paymentGroup: paymentGroupCode,
        paymentMethod: paymentMethodCode,
        identificationLetter: identificationLetter,
        identificationNumber: identificationNumber,
        amount: amountForBiopago, // Pasamos el double directamente
      );

      // 4. OCULTAR DIÁLOGO
      _dismissLoadingDialog();

      // 5. Manejo de la Respuesta Final
      if (mounted) {
        _handleResult(context, result, dataToSend);
      }
    } catch (e) {
      // 6. Manejo de Errores Críticos
      _dismissLoadingDialog();

      String criticalError = "Excepción Crítica";
      String errorDetails = e.toString();
      debugPrint('[DIAGNÓSTICO CRÍTICO] ERROR: $errorDetails');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PagoFallidoPage(
              title: criticalError,
              mainMessage:
                  "El sistema no pudo iniciar la aplicación de Biopago BDV o ocurrió un fallo de plataforma.",
              errorDetail: errorDetails,
              dataSent: dataToSend,
              resultReceived: {},
            ),
          ),
        );
      }
    }
  }

  // --- Función para Manejar y Navegar el Resultado del Servicio (MODIFICADA) ---
  void _handleResult(
    BuildContext context,
    Map<String, String?> result,
    Map<String, dynamic> dataSent,
  ) {
    setState(() {
      _diagnosticData =
          'Respuesta recibida de BiopagoService:\n' +
          result.entries.map((e) => '  ${e.key}: ${e.value}').join('\n');
    });

    final resultCode = result["result"] ?? "UnknownError";
    final errorType = result["errorType"];

    if (resultCode == "Accepted" || resultCode == "Success") {
      // PAGO EXITOSO

      // 1. Extraer los datos necesarios de la respuesta y el dato enviado
      final String transactionId = result["transactionId"] ?? "N/A";
      // Usar el monto enviado (dataSent) si el resultado no lo incluye o si es más seguro.
      final String amount =
          (dataSent["amount"] as double?)?.toStringAsFixed(2) ?? "0.00";
      final String finalResult = result["result"] ?? "Success";

      // 2. Navegar usando pushReplacementNamed con argumentos
      Navigator.of(context).pushReplacementNamed(
        'PagoAceptadoPage',
        arguments: {
          'transactionId': transactionId,
          'amount': amount,
          'result': finalResult,
        },
      );
    } else {
      // PAGO FALLIDO / RECHAZADO / CANCELADO O ERROR CONTROLADO
      String finalDetail =
          errorType ?? result["message"] ?? "Código de Respuesta: $resultCode";

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PagoFallidoPage(
            title: 'Pago Fallido/Rechazado',
            mainMessage: 'La transacción no pudo completarse. Razón:',
            errorDetail: finalDetail,
            dataSent: dataSent, // Datos enviados para el diagnóstico
            resultReceived: result, // Resultado de la API para el diagnóstico
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusedBorderStyle = OutlineInputBorder(
      borderSide: BorderSide(color: customPrimaryColor, width: 2.0),
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    );

    final defaultBorderStyle = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade400),
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    );

    final titleTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: customPrimaryColor,
    );

    const uniformContentPadding = EdgeInsets.fromLTRB(12, 14, 12, 14);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago'),
        backgroundColor: customPrimaryColor,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Título y descripción
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Detalles del Pago',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: customPrimaryColor,
                  ),
                ),
              ),

              // 1. Letra y Número de Cédula
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Letra:', style: titleTextStyle),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            border: defaultBorderStyle,
                            contentPadding: uniformContentPadding,
                            hintText: 'V o E',
                            focusedBorder: focusedBorderStyle,
                          ),
                          style: const TextStyle(color: Colors.black),
                          hint: const Text('V o E'),
                          value: _selectedDocumentType,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Tipo req.'
                              : null,
                          items: _documentTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDocumentType = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Número de Cédula', style: titleTextStyle),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _numberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            border: defaultBorderStyle,
                            hintText: 'Ingrese su número de cédula',
                            contentPadding: uniformContentPadding,
                            focusedBorder: focusedBorderStyle,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Número requerido.'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // 2. Selector de Banco CON IMAGE.ASSET
              Text('Banco:', style: titleTextStyle),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: defaultBorderStyle,
                  contentPadding: uniformContentPadding,
                  focusedBorder: focusedBorderStyle,
                ),
                style: const TextStyle(color: Colors.black),
                hint: const Text('Seleccione el Banco'),
                value: _selectedBank,
                validator: (value) => value == null || value.isEmpty
                    ? 'Seleccione el banco.'
                    : null,
                // *** IMPLEMENTACIÓN DEL DropdownMenuItem CON IMAGE.ASSET ***
                items: _bankOptions.map((Map<String, dynamic> bankData) {
                  final String bankName = bankData['name'];
                  final Widget bankIcon = bankData['icon']; // Es un Image.asset

                  return DropdownMenuItem<String>(
                    value: bankName,
                    child: Row(
                      // Usa Row para alinear horizontalmente la imagen y el texto
                      children: [
                        SizedBox(
                          width: 30, // Define un ancho para la imagen
                          child: bankIcon,
                        ),
                        const SizedBox(
                          width: 10,
                        ), // Espacio entre imagen y texto
                        Text(
                          bankName,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                // FIN DE IMPLEMENTACIÓN CON IMAGE.ASSET
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBank = newValue;
                  });
                },
              ),

              const SizedBox(height: 25),

              // 3. Selector de Métodos de Pago
              Text('Método de Pago:', style: titleTextStyle),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: defaultBorderStyle,
                  contentPadding: uniformContentPadding,
                  focusedBorder: focusedBorderStyle,
                ),
                style: const TextStyle(color: Colors.black),
                hint: const Text('Seleccione el Tipo de Cuenta'),
                value: _selectedPaymentMethod,
                validator: (value) => value == null || value.isEmpty
                    ? 'Seleccione el método de pago.'
                    : null,
                items: _paymentMethods.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      'Cuenta de $value',
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPaymentMethod = newValue;
                  });
                },
              ),

              const SizedBox(height: 25),

              // 4. Monto
              Text('Monto a Pagar (Bs.)', style: titleTextStyle),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*([,.]\d{0,2})?$'),
                  ),
                ],
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  border: defaultBorderStyle,
                  contentPadding: uniformContentPadding,
                  hintText: 'Ej: 100.50',
                  focusedBorder: focusedBorderStyle,
                ),
                validator: (value) {
                  final text = value?.replaceAll(',', '.').trim() ?? '';
                  if (text.isEmpty) {
                    return 'El monto no puede estar vacío.';
                  }
                  if (double.tryParse(text) == null ||
                      double.parse(text) <= 0) {
                    return 'Ingrese un monto válido mayor a cero.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // 5. Botón de Pagar
              ElevatedButton(
                onPressed: _handlePayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: customPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('INICIAR PAGO BIOPAGO BDV'),
              ),

              const SizedBox(height: 50),

              // Aquí podría ir el diagnóstico si lo mantienes visible para debug
              /*
              Text(
                'Diagnóstico:',
                style: titleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                _diagnosticData,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              */
            ],
          ),
        ),
      ),
    );
  }
}
