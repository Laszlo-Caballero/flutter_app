import 'dart:async';
import 'package:app_machin/models/Product.dart';
import 'package:app_machin/services/ProductsApi.dart';
import 'package:app_machin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Galerypage extends StatefulWidget {
  const Galerypage({super.key});

  @override
  State<Galerypage> createState() => _GalerypageState();
}

class _GalerypageState extends State<Galerypage> {
  final Productsapi _productsApi = Productsapi();
  final TextEditingController _searchController = TextEditingController();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _performSearch("");
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _productsApi.getProducts(query);
      setState(() {
        _products = results ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error al buscar productos";
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search Header Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: const InputDecoration(
                          hintText: "Buscar productos...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.gray),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch("");
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.mic, color: AppColors.blue),
                      onPressed: () {
                        // Simulated speech recognition
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Búsqueda por voz iniciada")),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.blue))
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                    : _products.isEmpty
                        ? _buildEmptyState()
                        : _buildProductsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 72, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                "No se encontraron productos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blue),
              ),
              const SizedBox(height: 8),
              Text(
                "Intenta buscar con otros términos o palabras clave.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        final priceString = product.precios != null && product.precios!.isNotEmpty
            ? "S/. ${product.precios!.first.toStringAsFixed(2)}"
            : "S/. 0.00";

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey[100],
                    child: product.imagenes != null && product.imagenes!.isNotEmpty
                        ? Image.network(
                            product.imagenes!.first.url!.startsWith('http')
                                ? product.imagenes!.first.url!
                                : '${dotenvGetApi()}${product.imagenes!.first.url}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.shopping_bag, size: 30, color: AppColors.gray),
                          )
                        : const Icon(Icons.shopping_bag, size: 30, color: AppColors.gray),
                  ),
                ),
                const SizedBox(width: 16),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nombre ?? "Producto Genérico",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.blue),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.marca ?? "Sin marca",
                            style: const TextStyle(color: AppColors.gray, fontSize: 12),
                          ),
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
              ],
            ),
          ),
        );
      },
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
