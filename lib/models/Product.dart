class Product {
  final int? productoId;
  final String? nombre;
  final List<double>? precios;
  final String? vendido_por;
  final String? marca;
  final String? url_venta;
  final List<String>? caracteristicas;
  final String? categoria;
  final String? sub_categoria;
  final List<String>? especificaciones;
  final double? similitud;
  final List<ImageProduct>? imagenes;

  Product({
    this.productoId,
    this.nombre,
    this.precios,
    this.vendido_por,
    this.marca,
    this.url_venta,
    this.caracteristicas,
    this.categoria,
    this.sub_categoria,
    this.especificaciones,
    this.similitud,
    this.imagenes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productoId: json['productoId'],
      nombre: json['nombre'],
      precios: (json['precios'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      vendido_por: json['vendido_por'],
      marca: json['marca'],
      url_venta: json['url_venta'],
      caracteristicas: List<String>.from(json['caracteristicas'] ?? []),
      categoria: json['categoria'],
      sub_categoria: json['sub_categoria'],
      especificaciones: List<String>.from(json['especificaciones'] ?? []),
      similitud: (json['similitud'] as num?)?.toDouble(),
      imagenes: (json['imagenes'] as List<dynamic>?)
          ?.map((e) => ImageProduct.fromJson(e))
          .toList(),
    );
  }
}

class ImageProduct {
  final int? imagenId;
  final String? url;

  ImageProduct({this.imagenId, this.url});

  factory ImageProduct.fromJson(Map<String, dynamic> json) {
    return ImageProduct(imagenId: json['imagenId'], url: json['url']);
  }
}
