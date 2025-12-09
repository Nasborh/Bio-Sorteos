import 'package:flutter/material.dart';
import 'dart:convert'; // Para usar jsonEncode

class PagoFallidoPage extends StatelessWidget {
  final String title;
  final String mainMessage;
  final String errorDetail;
  // Mapa que contiene los datos que Flutter envió al servicio nativo.
  final Map<String, dynamic> dataSent;
  // Mapa que contiene la respuesta completa que se recibió de BiopagoService (puede ser null).
  final Map<String, dynamic>? resultReceived;

  const PagoFallidoPage({
    super.key,
    required this.title,
    required this.mainMessage,
    required this.errorDetail,
    required this.dataSent,
    this.resultReceived,
  });

  final Color customPrimaryColor = const Color(0xFF004A72);
  final Color customErrorColor = const Color(0xFFD32F2F); // Rojo para error

  // Función auxiliar para formatear un Map a una cadena JSON legible
  String _formatMap(Map<String, dynamic> map) {
    // Usar una función para formatear JSON con indentación
    try {
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(map);
    } catch (e) {
      return map.entries.map((e) => '  ${e.key}: ${e.value}').join('\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: customPrimaryColor,
        automaticallyImplyLeading: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Icon(Icons.cancel, color: customErrorColor, size: 100),
            ),
            const SizedBox(height: 20),
            Text(
              mainMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // --- SECCIÓN DE DETALLE DEL ERROR (Diagnóstico) ---
            Text(
              '1. Detalle del Error (Diagnóstico)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: customErrorColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: customErrorColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                errorDetail,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- SECCIÓN DE RESPUESTA DE BIOPAGO SERVICE (Si hay) ---
            if (resultReceived != null) ...[
              Text(
                '2. Respuesta recibida de BiopagoService (JSON)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: customPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _formatMap(resultReceived!),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],

            // --- SECCIÓN DE DATOS ENVIADOS ---
            Text(
              '3. Datos enviados por Flutter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: customPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _formatMap(dataSent),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Botón para volver al formulario
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Volver a la página de pago
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: customPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'VOLVER AL FORMULARIO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
