import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../routes/app_routes.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/estado_vacio.dart';
import 'producto_form_screen.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final _buscador = TextEditingController();
  late Future<List<Producto>> _productos;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _productos =
          DatabaseService.instance.listProductos(filtro: _buscador.text);
    });
  }

  Future<void> _abrirFormulario([Producto? producto]) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ProductoFormScreen(producto: producto)),
    );
    if (guardado == true) _recargar();
  }

  Future<void> _eliminar(Producto p) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${p.nombre}" del inventario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await DatabaseService.instance.deleteProducto(p.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado')),
    );
    _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            tooltip: 'Ir al inicio',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.home, (r) => false),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _buscador,
              onChanged: (_) => _recargar(),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscador.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscador.clear();
                          _recargar();
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Producto>>(
              future: _productos,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error al cargar: ${snap.error}'));
                }
                final lista = snap.data ?? [];
                if (lista.isEmpty) {
                  return EstadoVacio(
                    icono: Icons.inventory_2_outlined,
                    mensaje: _buscador.text.isEmpty
                        ? 'No hay productos registrados.\nPulse "Nuevo" para agregar uno.'
                        : 'Ningún producto coincide con la búsqueda.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ProductoCard(
                    producto: lista[i],
                    onEditar: () => _abrirFormulario(lista[i]),
                    onEliminar: () => _eliminar(lista[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _ProductoCard({
    required this.producto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final bajoStock = producto.stock <= 5;
    final color = bajoStock ? AppTheme.danger : AppTheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(producto.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                ),
                Text('\$${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(producto.proveedorNombre ?? 'Sin proveedor',
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Stock: ${producto.stock}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEditar,
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                  onPressed: onEliminar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
