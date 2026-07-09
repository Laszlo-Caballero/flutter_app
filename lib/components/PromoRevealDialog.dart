import 'package:app_machin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PromoRevealDialog extends StatefulWidget {
  final Map<String, dynamic> promotion;

  const PromoRevealDialog({super.key, required this.promotion});

  @override
  State<PromoRevealDialog> createState() => _PromoRevealDialogState();
}

class _PromoRevealDialogState extends State<PromoRevealDialog> {
  bool _isClaimed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final title = widget.promotion['title'] ?? 'Bono';
      final code = widget.promotion['discount_code'] ?? '';
      final description = widget.promotion['description'] ?? '';
      SemanticsService.announce(
        "¡Bono especial desbloqueado! $title. Código: $code. $description",
        TextDirection.ltr,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final promo = widget.promotion;
    final title = promo['title'] ?? 'Bono Especial';
    final description = promo['description'] ?? '¡Felicidades! Tienes un nuevo descuento listo para usar.';
    final code = promo['discount_code'] ?? 'PROMO_TEMP';
    final qrUrl = promo['qr_code_url'] ?? '';

    final imageUrl = qrUrl.startsWith('http')
        ? qrUrl
        : '${dotenvGetApi()}${qrUrl.startsWith('/') ? qrUrl.substring(1) : qrUrl}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Promo Image / QR Code
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 150,
                height: 150,
                color: Colors.grey[100],
                child: qrUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.qr_code_2,
                          size: 80,
                          color: AppColors.gray,
                        ),
                      )
                    : const Icon(
                        Icons.qr_code_2,
                        size: 80,
                        color: AppColors.gray,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Code Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.yellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.yellow, width: 2),
            ),
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppColors.brown,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Claim Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isClaimed ? Colors.green : AppColors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isClaimed
                ? null
                : () {
                    setState(() {
                      _isClaimed = true;
                    });
                    SemanticsService.announce(
                      "Bono $title reclamado con éxito. El descuento se aplicará a tu cuenta.",
                      TextDirection.ltr,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("¡Cupón $code activado!"), backgroundColor: Colors.green),
                    );
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (mounted) Navigator.pop(context);
                    });
                  },
            child: Text(
              _isClaimed ? "¡Bono Reclamado! 🎉" : "RECLAMAR BONO",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: AppColors.gray)),
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
