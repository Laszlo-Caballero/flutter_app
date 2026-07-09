# Documentación del Proyecto: AI Visual Shopper

Esta es la documentación técnica de la aplicación Flutter **AI Visual Shopper**, diseñada para la detección, identificación y mapeo de tiendas/sucursales a partir de imágenes cargadas por cámara o galería, representando internamente su distribución física mediante estructuras de grafos.

---

## 1. Estructura General del Proyecto

El proyecto sigue una arquitectura modular en Flutter organizada en la carpeta `lib/`:

*   **[`main.dart`](file:///c:/Users/laszlo/Downloads/uni/inteligencia%20y%20machin/app_machin/lib/main.dart)**: Punto de entrada de la aplicación. Configura cargado de variables de entorno y los proveedores de estado globales.
*   **`models/`**: Definición de objetos de datos estructurados para la transferencia e interpretación de la información del backend.
*   **`providers/`**: Controladores de estado global que implementan el patrón *ChangeNotifier* (Provider).
*   **`services/`**: Módulos encargados de interactuar con APIs externas y lógica de datos crudos.
*   **`layout/`**: Componentes contenedores de la UI (estructuras principales, barras de navegación).
*   **`pages/`**: Vistas principales o pantallas que el usuario puede visitar.
*   **`components/`**: Reutilizables de interfaz de usuario.
*   **`utils/`**: Constantes y colores globales definidos para el estilo visual.

---

## 2. Configuración del Sistema

### Variables de Entorno
Ubicado en el archivo de la raíz del proyecto **[`.env`](file:///c:/Users/laszlo/Downloads/uni/inteligencia%20y%20machin/app_machin/.env)**:
```env
PUBLIC_API='https://9276-190-232-53-69.ngrok-free.app/api'
```
*   Define la URL base de la API utilizada para enviar la imagen capturada para su análisis.

### Constantes de Aplicación
Ubicado en **[`lib/utils/constants.dart`](file:///c:/Users/laszlo/Downloads/uni/inteligencia%20y%20machin/app_machin/lib/utils/constants.dart)**:
```dart
class AppConstants {
  static const String googleMapsApiKey =
      "AIzaSyBikKXSiGiRSQW5UWgCHGfBrLQM9T__Dfg";
}
```
*   Contiene la clave de API necesaria para los servicios integrados de Google Maps.

### Paleta de Colores
Ubicada en **[`lib/utils/colors.dart`](file:///c:/Users/laszlo/Downloads/uni/inteligencia%20y%20machin/app_machin/lib/utils/colors.dart)**:
```dart
class AppColors {
  static const blue = Color(0xFF001E40);
  static const gray = Color(0xFF64748B);
  static const yellow = Color(0xFFFCD400);
  static const brown = Color(0xFF6E5C00);
}
```

---

## 3. Flujo de Navegación y Punto de Entrada

### Inicialización
En **[`lib/main.dart`](file:///c:/Users/laszlo/Downloads/uni/inteligencia%20y%20machin/app_machin/lib/main.dart)** se inician las variables de entorno de `flutter_dotenv` y se inyectan los proveedores de cambio de estado:
```dart
Future<void> main() async {
  await dotenv.load();
  runApp(const MyApp());
}
```
Los `providers` asignados (Líneas 40-47) son:
*   `ImageSearchProvider`
*   `Routeprovider`
*   `AnalysisProvider`

### Contenedor Principal (Layout)
En **[`lib/layout/MainLayout.dart`](file:///c:/Users/laszlo/Downloads/uni/inteligencia%20y%20machin/app_machin/lib/layout/MainLayout.dart)** se decide qué página mostrar en base a la ruta del `Routeprovider` y se provee la navegación inferior:
```dart
Widget _getCurrentPage(String currentRoute) {
  switch (currentRoute) {
    case "/":
      return HomePage();
    case "/galery":
      return Galerypage();
    case "/history":
      return Historypage();
    case "/settings":
      return Settingspage();
    case "/analyze":
      return const AnalyzePage();
    default:
      return HomePage();
  }
}
```

---

## 4. Gestión de Estado (Providers)

### ImageSearchProvider
Ubicado en **[`lib/providers/ImageProvider.dart`](file:///c:/Users/laszlo/Downloads/uni/inteligencia%20y%20machin/app_machin/lib/providers/ImageProvider.dart)**. Se encarga de seleccionar imágenes desde la galería o la cámara utilizando el paquete `image_picker`:
```dart
Future<bool> pickImageFromCamera() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? photo = await _picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 80,
  );
  setSelectedImage(photo);
  return photo != null;
}
```

### AnalysisProvider
Ubicado en **[`lib/providers/AnalysisProvider.dart`](file:///c:/Users/laszlo/Downloads/uni/inteligencia%20y%20machin/app_machin/lib/providers/AnalysisProvider.dart)**. Controla el estado del proceso de llamada a la API y el análisis de la imagen, almacenando la lista de tiendas identificadas y la tienda actualmente seleccionada:
```dart
Future<void> analyzeImage(File imageFile) async {
  _isLoading = true;
  _errorMessage = null;
  _tiendas = null;
  _selectedTienda = null;
  notifyListeners();

  try {
    // Simula retraso para animación de carga premium
    await Future.delayed(const Duration(seconds: 2));
    
    final results = await _tiendasApi.getTiendasByImage(imageFile);
    if (results != null && results.isNotEmpty) {
      _tiendas = results;
      _selectedTienda = results.first; // Selecciona por defecto la primera tienda
    } else {
      _errorMessage = "No se encontraron tiendas en la imagen.";
    }
  } catch (e) {
    _errorMessage = "Error al analizar la imagen: ${e.toString()}";
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

---

## 5. Modelado de Datos (Models)

Definido en el archivo **[`lib/models/Tienda.dart`](file:///c:/Users/laszlo/Downloads/uni/inteligencia%20y%20machin/app_machin/lib/models/Tienda.dart)**. La estructura de clases deserializa la información de las tiendas y la estructura interna del plano basada en un **Grafo** (Nodos y Aristas).

### Clases Principales

1.  **`Tienda`**: Estructura principal con ubicación GPS, escala y el grafo físico.
    ```dart
    class Tienda {
      final int tiendaId;
      final String nombre;
      final double latitud;
      final double longitud;
      final int? nodoId;
      final Grafo grafo;
      final double ancho;
      final double alto;
      // ...
    }
    ```
2.  **`Grafo`**: Contiene la lista de nodos y aristas (edges), además de las dimensiones del plano virtual.
    ```dart
    class Grafo {
      final List<GrafoEdge> edges;
      final List<GrafoNode> nodes;
      final double width;
      final double height;
      // ...
    }
    ```
3.  **`GrafoNode`**: Representa una sección física de la tienda (oficina, pasillo, baño, almacén) con su tamaño en metros cuadrados (sqm) y su centroide (`centroid` expresado como `[X, Y]`).
4.  **`GrafoEdge`**: Almacena las conexiones físicas entre las diferentes secciones y el peso de proximidad (`weight`).

---

## 6. Servicio de API y Datos Mock

Implementado en **[`lib/services/TiendasApi.dart`](file:///c:/Users/laszlo/Downloads/uni/inteligencia%20y%20machin/app_machin/lib/services/TiendasApi.dart)**. Hace uso de la librería `dio` para realizar peticiones HTTP Multipart.

### Envío y Detección de Fallback
Si el servidor no está disponible, el sistema intercepta la excepción en un bloque `catch` y retorna datos simulados locales estructurados de manera idéntica al backend:
```dart
Future<List<Tienda>?> getTiendasByImage(File image) async {
  try {
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      ),
    });

    final res = await dio.post(
      '/products/identify',
      data: formData,
    );

    if (res.data != null && res.data['data'] != null) {
      final dataJson = res.data['data'];
      if (dataJson is Map<String, dynamic> && dataJson.containsKey('tiendas')) {
        final List<dynamic> tiendasList = dataJson['tiendas'];
        return tiendasList.map((e) => Tienda.fromJson(e)).toList();
      }
      if (dataJson is List<dynamic>) {
        return dataJson.map((e) => Tienda.fromJson(e)).toList();
      }
    }
    throw Exception("No stores found in response");
  } catch (e) {
    // Fallback a datos simulados locales en caso de desconexión o fallo
    return getMockTiendas();
  }
}
```

---

## 7. Pantalla de Resultados y Renderizado del Grafo

Ubicada en **[`lib/pages/AnalyzePage.dart`](file:///c:/Users/laszlo/Downloads/uni/inteligencia%20y%20machin/app_machin/lib/pages/AnalyzePage.dart)**.

Esta pantalla realiza múltiples tareas importantes:
1.  **Animación de Carga (`_ImageScanner`)**: Presenta un visor de la imagen cargada con una línea amarilla flotante y parpadeante que simula un láser de escaneo.
2.  **Mapa de Ubicaciones**: Implementa Google Maps si está en un entorno móvil compatible, o en su defecto invoca a un componente personalizado de simulación de radar (`_SimulatedMap` y `_MapGridPainter`) para plataformas de escritorio.
3.  **Renderizado en Lienzo del Grafo (`GrafoPainter`)**: Dibuja usando `CustomPaint` la distribución física de la tienda a partir de la escala y los centroides provistos.

### Pintura Personalizada del Grafo (Líneas 866-1025)
Utiliza fórmulas matemáticas de interpolación y escalado de píxeles basadas en la pantalla para posicionar y conectar los nodos dinámicamente:
```dart
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

  // Cálculo de alineación centrada
  double offsetX = padding + (drawW - (graphW * scale)) / 2;
  double offsetY = padding + (drawH - (graphH * scale)) / 2;

  Offset getOffset(List<double> centroid) {
    if (centroid.length < 2) return Offset.zero;
    return Offset(
      centroid[0] * scale + offsetX,
      centroid[1] * scale + offsetY,
    );
  }
  
  // 1. Dibuja las conexiones (aristas)
  // 2. Dibuja los círculos representativos de cada nodo con su tipo de color
  // 3. Imprime etiquetas de identificación y nombres de secciones (ej. Oficina, Baño, Recepción)
}
```
Los colores de los nodos varían de forma inteligente de acuerdo al tipo de sala:
*   **Baño (`bathroom`)**: Celeste/Azul claro (`Colors.lightBlue`)
*   **Recepción (`reception`)**: Ámbar (`Colors.amber[700]`)
*   **Almacén (`storage`)**: Turquesa (`Colors.teal`)
*   **Sala de Reuniones (`meeting_room`)**: Púrpura (`Colors.purple`)
*   **Oficina (`office`)**: Naranja (`Colors.deepOrange`)
*   **Pasillo (`hallway`)**: Gris (`Colors.grey[600]`)
