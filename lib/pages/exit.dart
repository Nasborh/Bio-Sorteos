import 'package:flutter/material.dart';

// Definición de la página de pago aceptado
class PagoAceptadoPage extends StatelessWidget {
  // ATRIBUTOS REQUERIDOS EN EL CONSTRUCTOR (Esta es la parte CRÍTICA)
  final String transactionId;
  final String amount;
  final String result;

  const PagoAceptadoPage({
    super.key,
    required this.transactionId,
    required this.amount,
    required this.result,
  });

  // Función auxiliar para construir las filas de detalle
  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color successColor = Color(0xFF388E3C); // Green
    const Color customPrimaryColor = Color(0xFF004A72);

    // Formatear el monto si es un número (opcional, para mejor visualización)
    final formattedAmount = double.tryParse(amount) != null
        ? 'Bs. ${double.parse(amount).toStringAsFixed(2)}'
        : 'Bs. $amount';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado del Pago'),
        backgroundColor: customPrimaryColor,
        automaticallyImplyLeading: false, // No permitir volver con la flecha
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Icono de Éxito
                Icon(
                  Icons.check_circle_outline,
                  color: successColor,
                  size: 100,
                ),
                const SizedBox(height: 30),

                // Título Principal
                const Text(
                  '¡PAGO ACEPTADO!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: successColor,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'La transacción con Biopago BDV se realizó con éxito.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 40),

                // --- DETALLE DE LA TRANSACCIÓN ---
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalles de la Transacción',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: customPrimaryColor,
                          ),
                        ),
                        const Divider(height: 20, thickness: 1),

                        // Detalle: Amount
                        _buildDetailRow(
                          'Monto Pagado:',
                          formattedAmount,
                          successColor,
                        ),

                        // Detalle: Transaction ID
                        _buildDetailRow(
                          'ID de Transacción:',
                          transactionId,
                          Colors.black87,
                        ),

                        // Detalle: Result
                        _buildDetailRow('Resultado:', result, successColor),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Botón Finalizar
                ElevatedButton(
                  onPressed: () {
                    // Navegar de vuelta a la página que inició el pago
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: customPrimaryColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Finalizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
