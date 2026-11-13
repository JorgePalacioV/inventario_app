class Producto {
  final int? id;
  final String nombre;
  final double precio;
  final int stock;
  final int proveedorId;

  /// Nombre del proveedor, llega desde el INNER JOIN (no se guarda en la tabla).
  final String? proveedorNombre;

  const Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.stock,
    required this.proveedorId,
    this.proveedorNombre,
  });

  factory Producto.fromMap(Map<String, Object?> map) {
    return Producto(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      precio: (map['precio'] as num).toDouble(),
      stock: map['stock'] as int,
      proveedorId: map['proveedor_id'] as int,
      proveedorNombre: map['proveedor_nombre'] as String?,
    );
  }

  /// Solo las columnas de la tabla productos.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'stock': stock,
      'proveedor_id': proveedorId,
    };
  }
}
