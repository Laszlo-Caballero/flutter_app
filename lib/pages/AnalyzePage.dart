import 'dart:io' show File;
import 'package:app_machin/providers/AnalysisProvider.dart';
import 'package:app_machin/providers/ImageProvider.dart';
import 'package:app_machin/providers/RouteProvider.dart';
import 'package:app_machin/providers/AuthProvider.dart';
import 'package:app_machin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_machin/pages/ProductDetailPage.dart';
import 'package:provider/provider.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final imageSearchProvider = Provider.of<ImageSearchProvider>(context, listen: false);
      final analysisProvider = Provider.of<AnalysisProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (imageSearchProvider.selectedImage != null &&
          !analysisProvider.isLoading &&
          analysisProvider.products == null) {
        analysisProvider.analyzeImage(
          File(imageSearchProvider.selectedImage!.path),
          authProvider.token,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<Routeprovider>();
    final imageProvider = context.watch<ImageSearchProvider>();
    final analysisProvider = context.watch<AnalysisProvider>();

    if (imageProvider.selectedImage == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_not_supported, size: 64, color: AppColors.gray),
              const SizedBox(height: 16),
              const Text(
                "No has seleccionado ninguna imagen para analizar.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => routeProvider.navigateTo('/'),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Volver al Inicio"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      );
    }

    if (analysisProvider.isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            "Analizando Imagen",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.blue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              analysisProvider.clear();
              routeProvider.navigateTo('/');
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'selectedImage',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(imageProvider.selectedImage!.path),
                      width: 280,
                      height: 280,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(color: AppColors.blue),
                const SizedBox(height: 24),
                const Text(
                  "Analizando imagen...",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.blue),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Buscando coincidencia de productos, precios y similitudes semánticas en tiempo real...",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (analysisProvider.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  analysisProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    analysisProvider.clear();
                    analysisProvider.analyzeImage(
                      File(imageProvider.selectedImage!.path),
                      authProvider.token,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Reintentar"),
                ),
                TextButton(
                  onPressed: () {
                    analysisProvider.clear();
                    imageProvider.clearSelectedImage();
                    routeProvider.navigateTo('/');
                  },
                  child: const Text("Regresar"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final products = analysisProvider.products ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Resultados del Análisis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            analysisProvider.clear();
            imageProvider.clearSelectedImage();
            routeProvider.navigateTo('/');
          },
        ),
      ),
      body: Column(
        children: [
          // Scan completion summary card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.center_focus_strong, color: AppColors.blue),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ESTADO DEL ESCANEO",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gray),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Análisis Completado",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.blue),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "OBJETOS ENCONTRADOS",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gray),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${products.length.toString().padLeft(2, '0')} Elementos",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Similar products list
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text("No se encontraron coincidencias"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final confidence = (product.similitud ?? 0.0).round();
                      final priceString = product.precios != null && product.precios!.isNotEmpty
                          ? "S/. ${product.precios!.first.toStringAsFixed(2)}"
                          : "S/. 0.00";

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(product: product),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Image banner area
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Container(
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: product.imagenes != null && product.imagenes!.isNotEmpty
                                      ? Image.network(
                                          product.imagenes!.first.url!.startsWith('http')
                                              ? product.imagenes!.first.url!
                                              : '${dotenvGetApi()}${product.imagenes!.first.url}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.shopping_bag, size: 64, color: AppColors.gray),
                                        )
                                      : const Icon(Icons.shopping_bag, size: 64, color: AppColors.gray),
                                ),
                              ),
                              // Content information
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.nombre ?? "Producto",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.blue,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  product.sub_categoria ?? product.categoria ?? "General",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 13, color: AppColors.gray),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                priceString,
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Confidence badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.yellow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "$confidence%\nConfianza",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String dotenvGetApi() {
    final api = dotenv.get("PUBLIC_API", fallback: "");
    if (api.endsWith('/api')) {
      return api.substring(0, api.length - 4);
    }
    return api;
  }
}
