import 'package:flutter/material.dart';

import '../models/proveedor.dart';
import '../routes/app_routes.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/estado_vacio.dart';
import 'proveedor_form_screen.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  late Future<List<Proveedor>> _proveedores;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  void _recargar() {
    setState(() {
      _proveedores = DatabaseService.instance.listProveedores();
    });
  }

  Future<void> _abrirFormulario([Proveedor? proveedor]) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProveedorFormScreen(proveedor: proveedor),
      ),
    );
    if (guardado == true) _recargar();
  }

  Future<void> _eliminar(Proveedor p) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar proveedor'),
        content: Text('¿Seguro que desea eliminar a "${p.nombre}"?'),
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

    try {
      await DatabaseService.instance.deleteProveedor(p.id!);
      messenger.showSnackBar(
        const SnackBar(content: Text('Proveedor eliminado')),
      );
      _recargar();
    } on ProveedorConProductosException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.danger,
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
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
      body: FutureBuilder<List<Proveedor>>(
        future: _proveedores,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error al cargar: ${snap.error}'));
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return const EstadoVacio(
              icono: Icons.local_shipping_outlined,
              mensaje: 'Aún no hay proveedores.\nPulse "Nuevo" para registrar uno.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: lista.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final p = lista[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primarySoft,
                        child: const Icon(Icons.local_shipping,
                            color: AppTheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.nombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                            if (p.telefono?.isNotEmpty ?? false)
                              Text('📞 ${p.telefono}'),
                            if (p.correo?.isNotEmpty ?? false)
                              Text('✉️ ${p.correo}'),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _abrirFormulario(p),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete_outline,
                            color: AppTheme.danger),
                        onPressed: () => _eliminar(p),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
