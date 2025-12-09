import 'package:flutter/material.dart';

// Definición de la página de pago aceptado
class PagoAceptadoPage extends StatelessWidget {
  const PagoAceptadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color successColor = Color(0xFF388E3C); // Green
    const Color customPrimaryColor = Color(0xFF004A72);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado del Pago'),
        backgroundColor: customPrimaryColor,
        automaticallyImplyLeading: false, // No permitir volver con la flecha
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Icono y Título Principal
              Icon(Icons.check_circle_outline, color: successColor, size: 100),
              const SizedBox(height: 30),
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
              const SizedBox(height: 50),

              // Aquí podrías mostrar detalles de la transacción si los tuvieras
              ElevatedButton(
                onPressed: () {
                  // Navegar de vuelta a la página principal o de pago
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: customPrimaryColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Finalizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
