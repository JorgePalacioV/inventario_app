import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/productos_screen.dart';
import '../screens/proveedores_screen.dart';

class AppRoutes {
  static const home = '/';
  static const productos = '/productos';
  static const proveedores = '/proveedores';

  static Map<String, WidgetBuilder> routes = {
    home: (_) => const DashboardScreen(),
    productos: (_) => const ProductosScreen(),
    proveedores: (_) => const ProveedoresScreen(),
  };
}
