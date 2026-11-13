import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/resumen_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<(int, int)> _resumen;

  @override
  void initState() {
    super.initState();
    _resumen = _cargarResumen();
  }

  Future<(int, int)> _cargarResumen() async {
    final db = DatabaseService.instance;
    return (await db.countProductos(), await db.countProveedores());
  }

  Future<void> _ir(String ruta) async {
    await Navigator.pushNamed(context, ruta);
    if (!mounted) return;
    // Al volver, refrescamos los contadores. El Future se calcula fuera de
    // setState (que no debe recibir un Future) y luego se asigna dentro.
    final nuevo = _cargarResumen();
    setState(() {
      _resumen = nuevo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
              title: const Text('Inventario Pro',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              background: Container(
                color: AppTheme.primary,
                child: const Align(
                  alignment: Alignment(-0.8, -0.3),
                  child: Icon(Icons.inventory_2_rounded,
                      size: 64, color: Colors.white38),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: FutureBuilder<(int, int)>(
                future: _resumen,
                builder: (context, snap) {
                  final productos = snap.data?.$1 ?? 0;
                  final proveedores = snap.data?.$2 ?? 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resumen',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ResumenCard(
                              titulo: 'Productos',
                              valor: '$productos',
                              icono: Icons.shopping_bag_outlined,
                              onTap: () => _ir(AppRoutes.productos),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ResumenCard(
                              titulo: 'Proveedores',
                              valor: '$proveedores',
                              icono: Icons.local_shipping_outlined,
                              onTap: () => _ir(AppRoutes.proveedores),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Secciones',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      _SeccionTile(
                        icono: Icons.shopping_bag,
                        titulo: 'Productos',
                        subtitulo: 'Stock, precios y proveedor asociado',
                        onTap: () => _ir(AppRoutes.productos),
                      ),
                      const SizedBox(height: 12),
                      _SeccionTile(
                        icono: Icons.local_shipping,
                        titulo: 'Proveedores',
                        subtitulo: 'Contactos y datos de suministro',
                        onTap: () => _ir(AppRoutes.proveedores),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionTile extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _SeccionTile({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primarySoft,
          child: Icon(icono, color: AppTheme.primary),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
