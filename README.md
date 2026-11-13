# Inventario Pro — Flutter + SQLite (sqflite)

Aplicación móvil para administrar **productos** y **proveedores** con una base de datos local SQLite.

## Ejecutar

```bash
flutter pub get
flutter run
```

## Estructura

```
lib/
├── main.dart                     # Punto de entrada
├── models/                       # Modelos: Proveedor, Producto (toMap / fromMap)
├── services/database_service.dart # Creación de tablas, PRAGMA foreign_keys, CRUD y consultas
├── routes/app_routes.dart        # Rutas nombradas
├── screens/                      # Dashboard, productos, proveedores y sus formularios
├── widgets/                      # ResumenCard, EstadoVacio (reutilizables)
├── theme/app_theme.dart          # Paleta, tarjetas, botones, inputs
└── utils/validators.dart         # Validaciones de formularios
```

## Base de datos

```sql
CREATE TABLE proveedores (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  telefono TEXT,
  correo TEXT
);

CREATE TABLE productos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  precio REAL NOT NULL,
  stock INTEGER NOT NULL,
  proveedor_id INTEGER NOT NULL,
  FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);
```

- **Relación 1:N**: un proveedor puede suministrar muchos productos; cada producto pertenece a un solo proveedor.
- **Clave foránea**: SQLite no las activa por defecto, por eso `DatabaseService` ejecuta `PRAGMA foreign_keys = ON` en `onConfigure`.
- **Integridad**: `ON DELETE RESTRICT` impide borrar un proveedor con productos. Además, `deleteProveedor` cuenta los productos asociados antes de borrar y lanza `ProveedorConProductosException`, que la pantalla muestra como mensaje al usuario.

### Consulta con INNER JOIN (listado de productos)

```sql
SELECT p.id, p.nombre, p.precio, p.stock, p.proveedor_id,
       pr.nombre AS proveedor_nombre
FROM productos p
INNER JOIN proveedores pr ON pr.id = p.proveedor_id
WHERE p.nombre LIKE ?
ORDER BY p.nombre COLLATE NOCASE;
```

El `INNER JOIN` une cada producto con su proveedor para mostrar el nombre del proveedor en el listado. El filtro `LIKE ?` implementa la búsqueda por nombre.

## Funcionalidades

| Sección | Crear | Consultar | Editar | Eliminar |
|---|---|---|---|---|
| Proveedores | ✔ | ✔ | ✔ | ✔ (bloqueado si tiene productos) |
| Productos | ✔ (dropdown de proveedor) | ✔ (INNER JOIN + búsqueda) | ✔ | ✔ |

Los datos se guardan en `inventario.db` dentro del directorio de bases de datos del dispositivo, por lo que persisten al cerrar la app.
