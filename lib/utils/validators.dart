class Validators {
  static String? requerido(String? v, [String campo = 'Este campo']) {
    if (v == null || v.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

  static String? correo(String? v) {
    if (v == null || v.trim().isEmpty) return null; // opcional
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    return regex.hasMatch(v.trim()) ? null : 'Correo no válido';
  }

  static String? precio(String? v) {
    if (v == null || v.trim().isEmpty) return 'El precio es obligatorio';
    final n = double.tryParse(v.replaceAll(',', '.'));
    if (n == null) return 'Ingrese un número válido';
    if (n < 0) return 'El precio no puede ser negativo';
    return null;
  }

  static String? stock(String? v) {
    if (v == null || v.trim().isEmpty) return 'El stock es obligatorio';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Ingrese un entero válido';
    if (n < 0) return 'El stock no puede ser negativo';
    return null;
  }
}
