import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../models/proveedor.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';

class ProductoFormScreen extends StatefulWidget {
  final Producto? producto;

  const ProductoFormScreen({super.key, this.producto});

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _precio;
  late final TextEditingController _stock;
  late Future<List<Proveedor>> _proveedores;
  int? _proveedorId;
  bool _guardando = false;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _precio = TextEditingController(text: p?.precio.toString() ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '');
    _proveedorId = p?.proveedorId;
    _proveedores = DatabaseService.instance.listProveedores();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_proveedorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un proveedor')),
      );
      return;
    }
    setState(() => _guardando = true);

    final producto = Producto(
      id: widget.producto?.id,
      nombre: _nombre.text.trim(),
      precio: double.parse(_precio.text.replaceAll(',', '.')),
      stock: int.parse(_stock.text.trim()),
      proveedorId: _proveedorId!,
    );

    try {
      final db = DatabaseService.instance;
      if (_esEdicion) {
        await db.updateProducto(producto);
      } else {
        await db.insertProducto(producto);
      }
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppTheme.primary, size: 48),
          title: const Text('Guardado'),
          content: Text(_esEdicion
              ? 'Producto actualizado correctamente.'
              : 'Producto registrado correctamente.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto *',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (v) => Validators.requerido(v, 'El nombre'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precio,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Precio unitario *',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: Validators.precio,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock (cantidad) *',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: Validators.stock,
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Proveedor>>(
                future: _proveedores,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const LinearProgressIndicator();
                  }
                  final lista = snap.data ?? [];
                  if (lista.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No hay proveedores. Registre uno primero en la sección Proveedores.',
                        ),
                      ),
                    );
                  }
                  return DropdownButtonFormField<int>(
                    initialValue: _proveedorId,
                    decoration: const InputDecoration(
                      labelText: 'Proveedor *',
                      prefixIcon: Icon(Icons.local_shipping_outlined),
                    ),
                    items: lista
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.nombre),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _proveedorId = v),
                  );
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: const Icon(Icons.save),
                label: Text(_esEdicion ? 'Actualizar' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
