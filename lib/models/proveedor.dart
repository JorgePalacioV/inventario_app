class Proveedor {
  final int? id;
  final String nombre;
  final String? telefono;
  final String? correo;

  const Proveedor({
    this.id,
    required this.nombre,
    this.telefono,
    this.correo,
  });

  factory Proveedor.fromMap(Map<String, Object?> map) {
    return Proveedor(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      telefono: map['telefono'] as String?,
      correo: map['correo'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
    };
  }
}
