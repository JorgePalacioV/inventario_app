import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tarjeta reutilizable de indicador (total de productos, proveedores...).
class ResumenCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final VoidCallback? onTap;

  const ResumenCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primarySoft,
                child: Icon(icono, color: AppTheme.primary),
              ),
              const SizedBox(height: 12),
              Text(valor,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      )),
              Text(titulo, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
