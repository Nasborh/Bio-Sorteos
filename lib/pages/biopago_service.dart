import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// --- Constantes de la aplicación Biopago (Confirmar estos valores) ---
// 💡 NOTA: Verifique que estos nombres de paquete sean correctos para su versión.
const String BIOPAGO_PACKAGE_NAME = "excle.biopos.mobile";
const String BIOPAGO_MAIN_ACTIVITY = "excle.biopos.mobile.MainActivity";

/// Clase de servicio para interactuar con la aplicación Biopago BDV a través de Android Intents.
class BiopagoService {
  // CANAL 1 (RESPONSE): Para recibir la respuesta FINAL de la operación desde Android.
  static const MethodChannel _biopagoResponseChannel = MethodChannel(
    'biopago_sorteos_app/biopago_response',
  );

  // CANAL 2 (REQUEST): Para enviar la solicitud al código nativo para ejecutar el Intent.
  static const MethodChannel _intentExecutorChannel = MethodChannel(
    'biopago_sorteos_app/intent_executor',
  );

  // Completer: Objeto para esperar la respuesta asíncrona de la operación.
  Completer<Map<String, String?>>? _operationCompleter;

  BiopagoService() {
    // Configura el manejador para escuchar las respuestas que vienen desde el código nativo.
    _biopagoResponseChannel.setMethodCallHandler(_handleIntentResponse);
  }

  /// Manejador que se invoca cuando el código nativo envía la respuesta.
  Future<dynamic> _handleIntentResponse(MethodCall call) async {
    if (call.method == 'onBiopagoResponse') {
      final Map<String, dynamic> responseMap = Map<String, dynamic>.from(
        call.arguments,
      );

      // Convertir Map<String, dynamic> a Map<String, String?>
      final Map<String, String?> result = responseMap.map(
        (key, value) => MapEntry(key, value?.toString()),
      );

      if (_operationCompleter != null && !_operationCompleter!.isCompleted) {
        _operationCompleter!.complete(result);
      } else {
        debugPrint(
          '[BIOPAGO SERVICE WARNING] Respuesta recibida, pero no había un completer esperando.',
        );
      }
    }
  }

  /// Función interna para ejecutar el Intent de Biopago BDV.
  Future<Map<String, String?>> _executeCommand(
    String command,
    Map<String, dynamic> extras,
  ) async {
    _operationCompleter = Completer<Map<String, String?>>();

    // Agregar el comando al mapa de extras
    final Map<String, dynamic> commandExtras = {"command": command, ...extras};

    try {
      // 1. Enviar el comando al código nativo (MainActivity.kt)
      await _intentExecutorChannel.invokeMethod('executeBiopagoIntent', {
        'packageName': BIOPAGO_PACKAGE_NAME,
        'className': BIOPAGO_MAIN_ACTIVITY,
        'extras': commandExtras,
      });

      // 2. Esperar la respuesta asíncrona a través del completer
      final response = await _operationCompleter!.future.timeout(
        const Duration(seconds: 30), // Tiempo de espera máximo
        onTimeout: () => {
          "result": "Timeout",
          "message":
              "La operación de Biopago BDV ha excedido el tiempo de espera (30s).",
          "errorType": "ClientTimeout",
        },
      );
      return response;
    } on PlatformException catch (e) {
      debugPrint(
        '[BIOPAGO SERVICE ERROR] Error de Plataforma al ejecutar el Intent: $e',
      );
      return {
        "result": "Failure",
        "message": "Error de plataforma al ejecutar el Intent: ${e.message}",
        "errorType": "PlatformException",
        "errorCode": e.code,
      };
    } catch (e) {
      debugPrint(
        '[BIOPAGO SERVICE ERROR] Error desconocido al ejecutar el Intent: $e',
      );
      return {
        "result": "Failure",
        "message": "Error desconocido al ejecutar el Intent: $e",
        "errorType": "UnknownError",
      };
    } finally {
      _operationCompleter = null; // Limpiar el completer
    }
  }

  // ----------------------------------------------------------------------
  //                         COMANDOS DE BIOPAGO BDV
  // ----------------------------------------------------------------------

  /// Comando: initialize (ACTUALIZADO para recibir parámetros)
  Future<Map<String, String?>> initialize({
    required String environment,
    required String connectionType,
    String? serviceUrl,
  }) async {
    final Map<String, dynamic> extras = {
      "environment": environment,
      "connectionType": connectionType,
    };
    if (connectionType == "middleware" && serviceUrl != null) {
      extras["serviceUrl"] = serviceUrl;
    }
    return _executeCommand("initialize", extras);
  }

  /// Comando: install
  Future<Map<String, String?>> install({
    required String affiliateCode,
    required String installKey,
  }) async {
    return _executeCommand("install", {
      "affiliateCode": affiliateCode,
      "installKey": installKey,
    });
  }

  /// Comando: process
  /// Permite realizar un pago.
  Future<Map<String, String?>> process({
    required String paymentGroup,
    required String paymentMethod,
    required String identificationLetter,
    required String identificationNumber,
    required double amount,
  }) async {
    debugPrint(
      '[BIOPAGO DEBUG] Ejecutando Process con valores reales del formulario.',
    );

    return _executeCommand("process", {
      "paymentGroup": paymentGroup,
      "paymentMethod": paymentMethod,
      "identificationLetter": identificationLetter,
      "identificationNumber": identificationNumber,
      "amount": amount,
    });
  }

  /// Comando: lastTransaction
  Future<Map<String, String?>> lastTransaction() async {
    return _executeCommand("lastTransaction", {});
  }
}
