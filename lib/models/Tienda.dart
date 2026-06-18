class Tienda {
  final int tiendaId;
  final String nombre;
  final double latitud;
  final double longitud;
  final int? nodoId;
  final Grafo grafo;
  final double ancho;
  final double alto;

  Tienda({
    required this.tiendaId,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    this.nodoId,
    required this.grafo,
    required this.ancho,
    required this.alto,
  });

  factory Tienda.fromJson(Map<String, dynamic> json) {
    return Tienda(
      tiendaId: json['tiendaId'] as int,
      nombre: json['nombre'] as String? ?? '',
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      nodoId: json['nodo_id'] as int?,
      grafo: Grafo.fromJson(json['grafo'] as Map<String, dynamic>),
      ancho: (json['ancho'] as num? ?? 300).toDouble(),
      alto: (json['alto'] as num? ?? 208).toDouble(),
    );
  }
}

class Grafo {
  final List<GrafoEdge> edges;
  final List<GrafoNode> nodes;
  final double width;
  final double height;

  Grafo({
    required this.edges,
    required this.nodes,
    required this.width,
    required this.height,
  });

  factory Grafo.fromJson(Map<String, dynamic> json) {
    return Grafo(
      edges: (json['edges'] as List<dynamic>?)
              ?.map((e) => GrafoEdge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nodes: (json['nodes'] as List<dynamic>?)
              ?.map((e) => GrafoNode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      width: (json['width'] as num? ?? 300).toDouble(),
      height: (json['height'] as num? ?? 208).toDouble(),
    );
  }
}

class GrafoEdge {
  final int source;
  final int target;
  final double weight;
  final String connectionType;

  GrafoEdge({
    required this.source,
    required this.target,
    required this.weight,
    required this.connectionType,
  });

  factory GrafoEdge.fromJson(Map<String, dynamic> json) {
    return GrafoEdge(
      source: json['source'] as int,
      target: json['target'] as int,
      weight: (json['weight'] as num).toDouble(),
      connectionType: json['connection_type'] as String? ?? '',
    );
  }
}

class GrafoNode {
  final int id;
  final double sqm;
  final double area;
  final String name;
  final String type;
  final List<double> centroid;

  GrafoNode({
    required this.id,
    required this.sqm,
    required this.area,
    required this.name,
    required this.type,
    required this.centroid,
  });

  factory GrafoNode.fromJson(Map<String, dynamic> json) {
    var centroidList = json['centroid'] as List<dynamic>? ?? [];
    List<double> c = centroidList.map((e) => (e as num).toDouble()).toList();
    return GrafoNode(
      id: json['id'] as int,
      sqm: (json['sqm'] as num).toDouble(),
      area: (json['area'] as num).toDouble(),
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'unknown',
      centroid: c,
    );
  }
}
