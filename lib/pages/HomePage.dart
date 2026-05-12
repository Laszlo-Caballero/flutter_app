import 'package:app_machin/components/ButtonImage.dart';
import 'package:app_machin/providers/ImageProvider.dart';
import 'package:app_machin/providers/RouteProvider.dart';
import 'package:app_machin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<Routeprovider>();
    final imageProvider = context.watch<ImageSearchProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Text(
            "Inicio - Análisis Accesible",
            style: TextStyle(
              fontSize: 48,
              overflow: TextOverflow.clip,
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
            ),
          ),
          Text(
            "Bienvenido. ¿Qué te gustaría analizar hoy? Selecciona una opción para comenzar.",
            style: TextStyle(fontSize: 20, overflow: TextOverflow.clip),
          ),
          SizedBox(height: 40),
          ButtonImage(
            onTap: () async {
              final bool redirect = await imageProvider.pickImageFromCamera();
              if (redirect) {
                routeProvider.navigateTo('/analyze');
              }
            },
            backgroundColor: AppColors.blue,
            textColor: Colors.white,
            icon: Icons.camera_alt,
            text: "Tomar Foto",
          ),
          SizedBox(height: 36),
          ButtonImage(
            backgroundColor: AppColors.yellow,
            textColor: AppColors.brown,
            icon: Icons.upload_file_outlined,
            text: "Subir desde Galeria",
            onTap: () async {
              final bool redirect = await imageProvider.pickImageFromGallery();
              if (redirect) {
                routeProvider.navigateTo('/analyze');
              }
            },
          ),
        ],
      ),
    );
  }
}
