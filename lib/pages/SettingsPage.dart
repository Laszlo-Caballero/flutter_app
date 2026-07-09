import 'package:app_machin/providers/AuthProvider.dart';
import 'package:app_machin/providers/SettingsProvider.dart';
import 'package:app_machin/services/HistoryApi.dart';
import 'package:app_machin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class Settingspage extends StatefulWidget {
  @override
  State<Settingspage> createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
  final HistoryApi _historyApi = HistoryApi();
  bool _isClearing = false;

  Future<void> _clearHistory(BuildContext context, SettingsProvider settings) async {
    setState(() {
      _isClearing = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await _historyApi.deleteHistory(auth.token);

    setState(() {
      _isClearing = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Historial eliminado exitosamente"),
          backgroundColor: Colors.green,
        ),
      );
      if (settings.audioAssistant) {
        // Speak if audio assistant is on (Simulated speak announcement via TTS or system announcement)
        SemanticsService.announce("Historial eliminado exitosamente", TextDirection.ltr);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al eliminar el historial"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final isHighContrast = settings.highContrastMode;

    final primaryColor = isHighContrast ? Colors.black : AppColors.blue;
    final secondaryTextColor = isHighContrast ? Colors.black : AppColors.gray;
    final backgroundColor = isHighContrast ? Colors.white : Colors.grey[50];
    final cardColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Configuración",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Personaliza las herramientas de asistencia y visualización para una mejor experiencia.",
              style: TextStyle(
                fontSize: 16,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 32),

            // Card ACCESIBILIDAD
            Card(
              color: cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ACCESIBILIDAD",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 40,
                      height: 3,
                      color: AppColors.yellow,
                    ),
                    const SizedBox(height: 20),

                    // High Contrast Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Alto Contraste",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isHighContrast ? Colors.black : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Aumenta el contraste y visibilidad del texto para lectura fácil",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: settings.highContrastMode,
                          activeColor: AppColors.yellow,
                          activeTrackColor: AppColors.blue,
                          onChanged: (val) {
                            settings.highContrastMode = val;
                          },
                        ),
                      ],
                    ),

                    const Divider(height: 24, color: Colors.grey),

                    // Audio Assistant Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Asistente de Voz",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isHighContrast ? Colors.black : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Activa la lectura por voz de pantallas y acciones del sistema",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: settings.audioAssistant,
                          activeColor: AppColors.yellow,
                          activeTrackColor: AppColors.blue,
                          onChanged: (val) {
                            settings.audioAssistant = val;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Connection Info Card
            Card(
              color: cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "INFORMACIÓN DE CONEXIÓN",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 40,
                      height: 3,
                      color: AppColors.yellow,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Servidor API Base:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dotenv.get("PUBLIC_API", fallback: "No configurado"),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Google Maps SDK:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Configurado con llave segura",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card HISTORIAL
            Card(
              color: cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "HISTORIAL DE BÚSQUEDAS",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 40,
                      height: 3,
                      color: AppColors.yellow,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isHighContrast ? Colors.black : const Color(0xFF4A5568),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isClearing ? null : () => _clearHistory(context, settings),
                        child: _isClearing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "BORRAR HISTORIAL",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Logout Card
            if (auth.isLoggedIn)
              Card(
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        auth.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sesión cerrada")),
                        );
                      },
                      child: const Text(
                        "CERRAR SESIÓN",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
