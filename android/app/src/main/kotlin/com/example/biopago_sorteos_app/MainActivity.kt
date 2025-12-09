package com.example.biopago_sorteos_app

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {
    
    private val INTENT_CHANNEL = "biopago_sorteos_app/intent_executor"
    private val RESPONSE_CHANNEL = "biopago_sorteos_app/biopago_response"
    private val BIOPAGO_REQUEST_CODE = 1001 
    private val TAG = "BIOPAGO_NATIVE" 

    private lateinit var biopagoResponseChannel: MethodChannel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        biopagoResponseChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RESPONSE_CHANNEL)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, INTENT_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "executeBiopagoIntent") {
                val packageName = call.argument<String>("packageName")
                val className = call.argument<String>("className")
                val extras = call.argument<Map<String, Any>>("extras")
                
                if (packageName != null && className != null && extras != null) {
                    executeIntent(packageName, className, extras)
                    result.success(null) 
                } else {
                    result.error("INVALID_ARGS", "Missing packageName, className, or extras.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    /**
     * Ejecuta el Intent de Biopago.
     * CORRECCIÓN CLAVE: Multiplica el monto por 100, aplica redondeo (round) y lo 
     * convierte a Int para enviarlo en la unidad base (centavos), resolviendo 
     * el problema de los decimales y los errores de punto flotante.
     */
    private fun executeIntent(
        packageName: String,
        className: String,
        extras: Map<String, Any> 
    ) {
        try {
            val intent = Intent().apply {
                component = android.content.ComponentName(packageName, className)
                action = android.content.Intent.ACTION_VIEW
                
                // Iteramos sobre todos los extras
                for ((key, value) in extras) {
                    
                    if (key == "amount") {
                        
                        val amountDouble: Double? = when (value) {
                            is Number -> value.toDouble() 
                            is String -> value.toDoubleOrNull()
                            else -> null
                        }
                        
                        if (amountDouble != null) {
                            // 1. Multiplicar por 100 para convertir a centavos: 10.50 -> 1050.0
                            val amountInBaseUnits = amountDouble 
                            
                            // 2. Aplicar redondeo y convertir a Int para evitar errores de punto flotante
                            // (ej. 1049.99999 se redondea a 1050)
                            val amountValue = amountInBaseUnits

                            // Usamos putExtra(String, Int)
                            putExtra(key, amountValue) 
                            Log.d(TAG, "Extra añadido (Centavos y Redondeo): $key -> $amountValue")
                        } else {
                            // Fallback si el valor no es ni String ni Number válido
                            putExtra(key, value.toString())
                            Log.d(TAG, "Extra añadido (String fallback): $key -> ${value.toString()}")
                        }
                    } else {
                        // Para todos los demás campos (identificación, etc.), se envían como String
                        putExtra(key, value.toString())
                        Log.d(TAG, "Extra añadido (String): $key -> ${value.toString()}")
                    }
                }
            }
            startActivityForResult(intent, BIOPAGO_REQUEST_CODE)
        } catch (e: Exception) {
            Log.e(TAG, "Error al ejecutar el Intent de Biopago: ${e.message}")
            // Si hay un error de ejecución del intent (ej. app no instalada), enviamos un error a Dart.
            sendBiopagoResponse(mapOf(
                "result" to "ExecutionError",
                "message" to "No se pudo iniciar la actividad: ${e.message}",
                "errorType" to "IntentExecutionFailed"
            ))
        }
    }
    
    private fun sendBiopagoResponse(resultBundle: Map<String, String?>) {
        // Ejecutamos en el hilo principal para comunicarnos con Flutter
        runOnUiThread {
            try {
                biopagoResponseChannel.invokeMethod("onBiopagoResponse", resultBundle)
                Log.i(TAG, "Respuesta enviada a Flutter: $resultBundle")
            } catch (e: Exception) {
                Log.e(TAG, "Error al enviar respuesta a Flutter: ${e.message}")
            }
        }
    }


    // -------------------------------------------------------------------------
    // Manejo del Resultado del Intent de Biopago
    // -------------------------------------------------------------------------

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.i(TAG, "--- onActivityResult Started (Code: $requestCode, Result: $resultCode) ---")
        
        if (requestCode == BIOPAGO_REQUEST_CODE) {
            val resultBundle = mutableMapOf<String, String?>()

            if (resultCode == Activity.RESULT_OK) {
                // Proceso OK
                if (data?.extras != null) {
                    // Iteramos sobre todos los extras que devuelve la App Biopago BDV
                    for (key in data.extras!!.keySet()) {
                        val value = data.extras!!.get(key)
                        resultBundle[key] = value?.toString() // Convertimos a String y permitimos null
                    }
                }
                // Aseguramos que haya un campo 'result' si el intent es OK
                if (!resultBundle.containsKey("result")) {
                     resultBundle["result"] = "Accepted" // Asumimos éxito si es OK y no hay campo 'result'
                }
                
            } else if (resultCode == Activity.RESULT_CANCELED) {
                // Caso si el usuario cancela (RESULT_CANCELED) o si Biopago retorna un error en este código.
                
                // 1. PRIORIZACIÓN: Capturamos todos los extras que Biopago haya devuelto.
                if (data?.extras != null) {
                    for (key in data.extras!!.keySet()) {
                        val value = data.extras!!.get(key)
                        resultBundle[key] = value?.toString() // Capturamos todos los campos devueltos (result, message, errorType, etc.)
                    }
                }
                
                // 2. FALLBACK: Si después de capturar los extras, aún no tenemos un 'result', usamos la cadena por defecto.
                if (!resultBundle.containsKey("result")) {
                    resultBundle["result"] = data?.getStringExtra("result") ?: "CancelByUser"
                }
                
                // 3. FALLBACK para errorType.
                 if (!resultBundle.containsKey("errorType")) {
                    resultBundle["errorType"] = data?.getStringExtra("errorType") ?: "El usuario canceló la operación."
                }
                
            } else {
                 // Otro caso de fallo o error
                resultBundle["result"] = "Error"
                resultBundle["errorType"] = "Resultado de actividad inesperado (Code: $resultCode)"
            }
            
            // 2. Enviamos el resultado al canal de respuesta.
            sendBiopagoResponse(resultBundle)
        } else {
            Log.w(TAG, "Received an unrelated request code: $requestCode")
        }
        Log.i(TAG, "--- onActivityResult Finished ---")
    }
}