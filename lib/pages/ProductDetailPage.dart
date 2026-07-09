import 'package:app_machin/models/Product.dart';
import 'package:app_machin/providers/SettingsProvider.dart';
import 'package:app_machin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isHighContrast = settings.highContrastMode;

    // Accessibility announcement when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (settings.audioAssistant) {
        SemanticsService.announce(
          "Detalle del producto cargado: ${product.nombre ?? 'Producto'}. Vendido por: ${product.vendido_por ?? 'Sin vendedor'}.",
          TextDirection.ltr,
        );
      }
    });

    final priceString = product.precios != null && product.precios!.isNotEmpty
        ? product.precios!.map((p) => "S/. ${p.toStringAsFixed(2)}").join(" - ")
        : "Precio no disponible";

    return Scaffold(
      backgroundColor: isHighContrast ? Colors.white : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          product.nombre ?? "Detalles del Producto",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isHighContrast ? Colors.black : AppColors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image area
            Container(
              height: 250,
              color: isHighContrast ? Colors.white : Colors.grey[200],
              child: product.imagenes != null && product.imagenes!.isNotEmpty
                  ? Image.network(
                      product.imagenes!.first.url!.startsWith('http')
                          ? product.imagenes!.first.url!
                          : '${dotenvGetApi()}${product.imagenes!.first.url}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.shopping_bag,
                        size: 100,
                        color: isHighContrast ? Colors.black : AppColors.gray,
                      ),
                    )
                  : Icon(
                      Icons.shopping_bag,
                      size: 100,
                      color: isHighContrast ? Colors.black : AppColors.gray,
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.nombre ?? "Producto Genérico",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isHighContrast ? Colors.black : AppColors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Brand and Seller
                  Row(
                    children: [
                      _buildChip(
                        isHighContrast,
                        Icons.branding_watermark,
                        product.marca ?? "Genérico",
                      ),
                      const SizedBox(width: 12),
                      _buildChip(
                        isHighContrast,
                        Icons.store,
                        product.vendido_por ?? "Local",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price
                  _buildSectionHeader(isHighContrast, "Rango de Precios"),
                  const SizedBox(height: 6),
                  Text(
                    priceString,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isHighContrast ? Colors.black : Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category
                  _buildSectionHeader(isHighContrast, "Categoría"),
                  const SizedBox(height: 6),
                  Text(
                    "${product.categoria ?? 'General'} > ${product.sub_categoria ?? 'General'}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isHighContrast ? FontWeight.bold : FontWeight.normal,
                      color: isHighContrast ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Features
                  if (product.caracteristicas != null && product.caracteristicas!.isNotEmpty) ...[
                    _buildSectionHeader(isHighContrast, "Características Principales"),
                    const SizedBox(height: 10),
                    ...product.caracteristicas!.map((feature) => _buildBulletPoint(isHighContrast, feature)),
                    const SizedBox(height: 20),
                  ],

                  // Specs
                  if (product.especificaciones != null && product.especificaciones!.isNotEmpty) ...[
                    _buildSectionHeader(isHighContrast, "Especificaciones Técnicas"),
                    const SizedBox(height: 10),
                    ...product.especificaciones!.map((spec) => _buildBulletPoint(isHighContrast, spec)),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(bool isHighContrast, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.transparent : Colors.grey[200],
        border: Border.all(color: isHighContrast ? Colors.black : Colors.transparent, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isHighContrast ? Colors.black : AppColors.gray),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighContrast ? Colors.black : AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isHighContrast, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighContrast ? Colors.black : AppColors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 3,
          color: isHighContrast ? Colors.black : AppColors.yellow,
        ),
      ],
    );
  }

  Widget _buildBulletPoint(bool isHighContrast, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Icon(
              Icons.circle,
              size: 8,
              color: isHighContrast ? Colors.black : AppColors.yellow,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighContrast ? FontWeight.bold : FontWeight.normal,
                color: isHighContrast ? Colors.black : Colors.black87,
              ),
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
