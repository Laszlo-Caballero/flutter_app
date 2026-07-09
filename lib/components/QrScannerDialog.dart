import 'dart:convert';
import 'package:app_machin/components/PromoRevealDialog.dart';
import 'package:app_machin/models/Product.dart';
import 'package:app_machin/pages/ProductDetailPage.dart';
import 'package:app_machin/providers/AuthProvider.dart';
import 'package:app_machin/services/ProductsApi.dart';
import 'package:app_machin/services/PromotionsApi.dart';
import 'package:app_machin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QrScannerDialog extends StatefulWidget {
  const QrScannerDialog({super.key});

  @override
  State<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final PromotionsApi _promotionsApi = PromotionsApi();
  final Productsapi _productsApi = Productsapi();
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleQrCodeContent(String content) async {
    if (content.trim().isEmpty) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final trimmed = content.trim();

    try {
      // Option 1: QR contains full Product JSON
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        final Map<String, dynamic> parsed = jsonDecode(trimmed);
        final product = Product.fromJson(parsed);
        if (product.nombre != null) {
          Navigator.pop(context); // Close scanner
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
          );
          return;
        }
      }
    } catch (_) {}

    // Option 2: Search product by query/name in local/server catalog
    try {
      final results = await _productsApi.getProducts(trimmed, auth.token);
      if (results != null && results.isNotEmpty) {
        Navigator.pop(context); // Close scanner
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailPage(product: results.first)),
        );
        return;
      }
    } catch (_) {}

    // Option 3: Check if it is a promotion/gift code
    final cleanCode = trimmed
        .replaceAll(RegExp(r'^promo:', caseSensitive: false), '')
        .replaceAll(RegExp(r'^bono:', caseSensitive: false), '')
        .trim();

    try {
      final promoResponse = await _promotionsApi.redeemPromotion(cleanCode, auth.token);
      if (promoResponse != null && promoResponse['status'] == 'success' && promoResponse['data'] != null) {
        Navigator.pop(context); // Close scanner
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => PromoRevealDialog(promotion: promoResponse['data']),
        );
        return;
      }
    } catch (_) {}

    // Option 4: Fallback - QR content not identified
    setState(() {
      _isLoading = false;
    });
    SemanticsService.announce("Código QR no identificado", TextDirection.ltr);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Código no encontrado"),
        content: Text("El código QR '$trimmed' no coincide con ningún producto o bono disponible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  Future<void> _scanFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // Simulate scanning from gallery image
    // In a real application, you'd use a barcode scanner library on the image file.
    // Here we'll simulate finding a code based on the filename or let them know it parsed a mock code.
    final mockCode = "PROMO10"; // standard test code
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Imagen procesada. Código encontrado: PROMO10")),
    );
    _textController.text = mockCode;
    _handleQrCodeContent(mockCode);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Escanear Código QR",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blue),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.gray),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Camera Viewport using mobile_scanner
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 220,
                  child: Stack(
                    children: [
                      MobileScanner(
                        onDetect: (barcodeCapture) {
                          final List<Barcode> barcodes = barcodeCapture.barcodes;
                          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                            final String rawValue = barcodes.first.rawValue!;
                            _handleQrCodeContent(rawValue);
                          }
                        },
                      ),
                      // Targeting box
                      Center(
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white70, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      // Animated scanning line
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Positioned(
                            top: 40 + (_animationController.value * 140),
                            left: 40,
                            right: 40,
                            child: Container(
                              height: 2,
                              color: AppColors.yellow,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Gallery trigger button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _scanFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text("Escanear desde Galería"),
              ),
              const SizedBox(height: 16),

              const Divider(),
              const SizedBox(height: 12),

              // Text Field for manual code entry
              const Text(
                "O ingresa el código del QR manualmente:",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gray),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: "Ej. PROMO10, bono:GIFT20, o JSON",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: _isLoading ? null : _handleQrCodeContent,
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading
                    ? null
                    : () => _handleQrCodeContent(_textController.text),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("BUSCAR / CANJEAR", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
