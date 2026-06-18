import 'dart:io' show File, Platform;
import 'package:app_machin/models/Tienda.dart';
import 'package:app_machin/providers/AnalysisProvider.dart';
import 'package:app_machin/providers/ImageProvider.dart';
import 'package:app_machin/providers/RouteProvider.dart';
import 'package:app_machin/utils/colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final imageSearchProvider = Provider.of<ImageSearchProvider>(context, listen: false);
      final analysisProvider = Provider.of<AnalysisProvider>(context, listen: false);
      if (imageSearchProvider.selectedImage != null && 
          !analysisProvider.isLoading && 
          analysisProvider.tiendas == null) {
        analysisProvider.analyzeImage(File(imageSearchProvider.selectedImage!.path));
      }
    });
  }

  // Cross-platform map check
  bool get _isMapSupported {
    if (kIsWeb) return true;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
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
              const Text("No has seleccionado ninguna imagen para analizar.", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => routeProvider.navigateTo('/'),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Volver al Inicio"),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      );
    }

    // Handles the loading state
    if (analysisProvider.isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Analizando Imagen", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                _ImageScanner(imagePath: imageProvider.selectedImage!.path),
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
                    "Buscando coincidencia de tiendas, coordenadas de GPS y planos de distribución (grafos)...",
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
                    analysisProvider.clear();
                    analysisProvider.analyzeImage(File(imageProvider.selectedImage!.path));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue, foregroundColor: Colors.white),
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

    final tiendas = analysisProvider.tiendas;
    final selectedTienda = analysisProvider.selectedTienda;

    if (tiendas == null || tiendas.isEmpty || selectedTienda == null) {
      return const Scaffold(body: Center(child: Text("Sin resultados")));
    }

    // Build map markers
    final markers = tiendas.map((tienda) {
      final isSelected = tienda.tiendaId == selectedTienda.tiendaId;
      return Marker(
        markerId: MarkerId(tienda.tiendaId.toString()),
        position: LatLng(tienda.latitud, tienda.longitud),
        infoWindow: InfoWindow(
          title: tienda.nombre,
          snippet: "Lat: ${tienda.latitud.toStringAsFixed(6)}, Lng: ${tienda.longitud.toStringAsFixed(6)}",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueCyan : BitmapDescriptor.hueRed,
        ),
        onTap: () {
          analysisProvider.selectTienda(tienda);
          if (_mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(LatLng(tienda.latitud, tienda.longitud)),
            );
          }
        },
      );
    }).toSet();

    // Trigger camera update if selected store changes
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(selectedTienda.latitud, selectedTienda.longitud)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Detalles de Resultados", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          
          Widget mapWidget = Container(
            height: isWide ? 300 : 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: _isMapSupported
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(selectedTienda.latitud, selectedTienda.longitud),
                      zoom: 15.0,
                    ),
                    markers: markers,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    onMapCreated: (controller) => _mapController = controller,
                  )
                : _SimulatedMap(
                    tiendas: tiendas,
                    selectedTienda: selectedTienda,
                    onSelectTienda: (tienda) {
                      analysisProvider.selectTienda(tienda);
                    },
                  ),
          );

          Widget imageCard = Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: AppColors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: const [
                      Icon(Icons.photo_outlined, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Imagen Cargada", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 180,
                  child: Image.file(
                    File(imageProvider.selectedImage!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          );

          Widget storeDetailsCard = Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          selectedTienda.nombre,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blue),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.yellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Identificada",
                          style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.location_on, "Latitud", selectedTienda.latitud.toString()),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.location_on, "Longitud", selectedTienda.longitud.toString()),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.aspect_ratio, "Dimensiones", "${selectedTienda.ancho.toInt()} x ${selectedTienda.alto.toInt()}"),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.hub_outlined, "Nodos (Áreas)", selectedTienda.grafo.nodes.length.toString()),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.settings_ethernet, "Conexiones", selectedTienda.grafo.edges.length.toString()),
                ],
              ),
            ),
          );

          Widget graphCard = Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: AppColors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Plano del Grafo: ${selectedTienda.nombre.split(' ').first}",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Distribución Interna de la Tienda",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.blue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Representación visual en 2D basada en los centroides de distribución.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // The custom canvas rendering
                      Container(
                        height: 280,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50]?.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueGrey[100]!),
                        ),
                        child: CustomPaint(
                          painter: GrafoPainter(grafo: selectedTienda.grafo),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Legend of Node Types
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildLegendItem(Colors.amber[700]!, "Recepción"),
                          _buildLegendItem(Colors.deepOrange, "Oficina"),
                          _buildLegendItem(Colors.purple, "Reunión"),
                          _buildLegendItem(Colors.teal, "Almacén"),
                          _buildLegendItem(Colors.lightBlue, "Baño"),
                          _buildLegendItem(Colors.grey[600]!, "Pasillos"),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );

          Widget nodesTableCard = Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Desglose de Áreas (Nodos)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blue),
                  ),
                  const Divider(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: selectedTienda.grafo.nodes.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final node = selectedTienda.grafo.nodes[index];
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: _getNodeColor(node.type),
                            child: Text(
                              node.id.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(
                                  node.type.toUpperCase(),
                                  style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${node.sqm} SQM", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              Text("Área: ${node.area}", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );

          if (isWide) {
            // Wide Screen double column layout
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        imageCard,
                        const SizedBox(height: 20),
                        mapWidget,
                        const SizedBox(height: 20),
                        storeDetailsCard,
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 24, bottom: 24, right: 24),
                    child: Column(
                      children: [
                        graphCard,
                        const SizedBox(height: 20),
                        nodesTableCard,
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Mobile vertical layout
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  imageCard,
                  const SizedBox(height: 16),
                  mapWidget,
                  const SizedBox(height: 16),
                  storeDetailsCard,
                  const SizedBox(height: 16),
                  graphCard,
                  const SizedBox(height: 16),
                  nodesTableCard,
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.gray),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue)),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Color _getNodeColor(String type) {
    switch (type.toLowerCase()) {
      case 'bathroom':
        return Colors.lightBlue;
      case 'reception':
        return Colors.amber[700]!;
      case 'storage':
        return Colors.teal;
      case 'meeting_room':
        return Colors.purple;
      case 'office':
        return Colors.deepOrange;
      case 'hallway':
        return Colors.grey[600]!;
      default:
        return Colors.indigo;
    }
  }
}

// Glowing scanner line animation for image loading screen
class _ImageScanner extends StatefulWidget {
  final String imagePath;
  const _ImageScanner({required this.imagePath});

  @override
  State<_ImageScanner> createState() => _ImageScannerState();
}

class _ImageScannerState extends State<_ImageScanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.blue.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),
          // Animated Scan Line
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: _controller.value * 250,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.yellow.withValues(alpha: 0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          // Futuristic corner decors
          Positioned(
            top: 10, left: 10,
            child: Container(width: 15, height: 15, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.yellow, width: 3), left: BorderSide(color: AppColors.yellow, width: 3)))),
          ),
          Positioned(
            top: 10, right: 10,
            child: Container(width: 15, height: 15, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.yellow, width: 3), right: BorderSide(color: AppColors.yellow, width: 3)))),
          ),
          Positioned(
            bottom: 10, left: 10,
            child: Container(width: 15, height: 15, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.yellow, width: 3), left: BorderSide(color: AppColors.yellow, width: 3)))),
          ),
          Positioned(
            bottom: 10, right: 10,
            child: Container(width: 15, height: 15, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.yellow, width: 3), right: BorderSide(color: AppColors.yellow, width: 3)))),
          ),
        ],
      ),
    );
  }
}

// Simulated map widget for non-mobile platforms (Windows/macOS/Linux/Web fallback)
class _SimulatedMap extends StatefulWidget {
  final List<Tienda> tiendas;
  final Tienda selectedTienda;
  final Function(Tienda) onSelectTienda;

  const _SimulatedMap({
    required this.tiendas,
    required this.selectedTienda,
    required this.onSelectTienda,
  });

  @override
  State<_SimulatedMap> createState() => _SimulatedMapState();
}

class _SimulatedMapState extends State<_SimulatedMap> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, mapConstraints) {
        final double w = mapConstraints.maxWidth;
        final double h = mapConstraints.maxHeight;

        // Coordinates mapping
        // We will project coordinates relative to Trujillo center
        // Center lat: -8.1087, Lng: -79.0419
        double centerLat = -8.1087;
        double centerLng = -79.0419;

        // Calculate offset multiplier
        double latScale = h * 80; // Scale degrees to pixels
        double lngScale = w * 80;

        Offset getSimulatedPosition(double lat, double lng) {
          double x = (w / 2) + (lng - centerLng) * lngScale;
          double y = (h / 2) - (lat - centerLat) * latScale; // Latitudes decrease downwards

          // Clamping to fit the map widget
          x = x.clamp(30.0, w - 30.0);
          y = y.clamp(30.0, h - 30.0);

          return Offset(x, y);
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xFF002244), Color(0xFF001122)],
              center: Alignment.center,
              radius: 1.0,
            ),
          ),
          child: Stack(
            children: [
              // Grid background
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapGridPainter(radarValue: _radarController.value),
                ),
              ),

              // Title overlay
              Positioned(
                top: 8,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.yellow.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.radar, color: AppColors.yellow, size: 12),
                      SizedBox(width: 4),
                      Text(
                        "DESKTOP MAP SIMULATOR ACTIVE",
                        style: TextStyle(
                          color: AppColors.yellow,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Display markers
              ...widget.tiendas.map((tienda) {
                final isSelected = tienda.tiendaId == widget.selectedTienda.tiendaId;
                final pos = getSimulatedPosition(tienda.latitud, tienda.longitud);

                return Positioned(
                  left: pos.dx - 18,
                  top: pos.dy - 36,
                  child: GestureDetector(
                    onTap: () => widget.onSelectTienda(tienda),
                    child: Tooltip(
                      message: tienda.nombre,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 32,
                            color: isSelected ? AppColors.yellow : Colors.redAccent,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected ? AppColors.yellow : Colors.redAccent.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              tienda.nombre.split(' ').first,
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // Coordinate text readout overlay
              Positioned(
                bottom: 8,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Text(
                    "GPS SELECT: ${widget.selectedTienda.latitud.toStringAsFixed(6)}, ${widget.selectedTienda.longitud.toStringAsFixed(6)}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: "monospace",
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final double radarValue;
  _MapGridPainter({required this.radarValue});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    // Grid spacing
    const double spacing = 30.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Concentric sonar/radar rings from center
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width > size.height ? size.width : size.height;
    final radarRadius = maxRadius * radarValue;

    final radarPaint = Paint()
      ..color = AppColors.yellow.withValues(alpha: 0.15 * (1.0 - radarValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radarRadius, radarPaint);
    canvas.drawCircle(center, radarRadius / 2, radarPaint..color = AppColors.yellow.withValues(alpha: 0.08 * (1.0 - radarValue)));
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) {
    return oldDelegate.radarValue != radarValue;
  }
}

// Visual Graph Custom Painter class
class GrafoPainter extends CustomPainter {
  final Grafo grafo;
  final int? selectedNodeId;

  GrafoPainter({required this.grafo, this.selectedNodeId});

  @override
  void paint(Canvas canvas, Size size) {
    double graphW = grafo.width;
    double graphH = grafo.height;

    double padding = 24.0;
    double drawW = size.width - (padding * 2);
    double drawH = size.height - (padding * 2);

    double scaleX = drawW / graphW;
    double scaleY = drawH / graphH;
    double scale = scaleX < scaleY ? scaleX : scaleY;

    // Centering calculation
    double offsetX = padding + (drawW - (graphW * scale)) / 2;
    double offsetY = padding + (drawH - (graphH * scale)) / 2;

    Offset getOffset(List<double> centroid) {
      if (centroid.length < 2) return Offset.zero;
      return Offset(
        centroid[0] * scale + offsetX,
        centroid[1] * scale + offsetY,
      );
    }

    // Draw connection edges
    final linePaint = Paint()
      ..color = AppColors.blue.withValues(alpha: 0.4)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var edge in grafo.edges) {
      final sourceNode = grafo.nodes.firstWhere((n) => n.id == edge.source, orElse: () => grafo.nodes.first);
      final targetNode = grafo.nodes.firstWhere((n) => n.id == edge.target, orElse: () => grafo.nodes.first);

      final p1 = getOffset(sourceNode.centroid);
      final p2 = getOffset(targetNode.centroid);

      // Draw edge line
      canvas.drawLine(p1, p2, linePaint);

      // Draw connection weight values in the center point
      final midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      textPainter.text = TextSpan(
        text: edge.weight.toStringAsFixed(2),
        style: TextStyle(
          color: AppColors.brown,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(midPoint.dx - textPainter.width / 2, midPoint.dy - textPainter.height / 2),
      );
    }

    // Draw individual nodes
    for (var node in grafo.nodes) {
      final pos = getOffset(node.centroid);
      final nodeColor = _getNodeColor(node.type);

      // Draw node shadow
      canvas.drawCircle(
        pos,
        15.0,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
      );

      // Draw node circle background
      canvas.drawCircle(
        pos,
        13.0,
        Paint()
          ..color = nodeColor
          ..style = PaintingStyle.fill,
      );

      // Draw circle white border
      canvas.drawCircle(
        pos,
        13.0,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      // Draw node ID inside the circle
      textPainter.text = TextSpan(
        text: node.id.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );

      // Draw node Area Label text
      textPainter.text = TextSpan(
        text: node.name,
        style: TextStyle(
          color: AppColors.blue,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white.withValues(alpha: 0.85),
        ),
      );
      textPainter.layout();
      
      // Draw label offset vertically
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy + 16),
      );
    }
  }

  Color _getNodeColor(String type) {
    switch (type.toLowerCase()) {
      case 'bathroom':
        return Colors.lightBlue;
      case 'reception':
        return Colors.amber[700]!;
      case 'storage':
        return Colors.teal;
      case 'meeting_room':
        return Colors.purple;
      case 'office':
        return Colors.deepOrange;
      case 'hallway':
        return Colors.grey[600]!;
      default:
        return Colors.indigo;
    }
  }

  @override
  bool shouldRepaint(covariant GrafoPainter oldDelegate) {
    return oldDelegate.grafo != grafo || oldDelegate.selectedNodeId != selectedNodeId;
  }
}
