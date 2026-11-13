import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/producto.dart';
import '../models/proveedor.dart';

/// Excepción de negocio: el proveedor tiene productos asociados.
class ProveedorConProductosException implements Exception {
  final int cantidad;
  ProveedorConProductosException(this.cantidad);

  @override
  String toString() =>
      'No se puede eliminar: el proveedor tiene $cantidad producto(s) asociado(s).';
}

/// Acceso centralizado a la base de datos SQLite (sqflite).
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const _dbName = 'inventario.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = p.join(await getDatabasesPath(), _dbName);
    return openDatabase(
      dbPath,
      version: _dbVersion,
      // Las claves foráneas están desactivadas por defecto en SQLite.
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE proveedores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            telefono TEXT,
            correo TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE productos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            precio REAL NOT NULL,
            stock INTEGER NOT NULL,
            proveedor_id INTEGER NOT NULL,
            FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
              ON DELETE RESTRICT ON UPDATE CASCADE
          )
        ''');
      },
    );
  }

  // ---------------- PROVEEDORES ----------------

  Future<int> countProveedores() async {
    final db = await database;
    final r = await db.rawQuery('SELECT COUNT(*) AS c FROM proveedores');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<List<Proveedor>> listProveedores() async {
    final db = await database;
    final rows = await db.query('proveedores', orderBy: 'nombre COLLATE NOCASE');
    return rows.map(Proveedor.fromMap).toList();
  }

  Future<int> insertProveedor(Proveedor pr) async {
    final db = await database;
    final map = pr.toMap()..remove('id');
    return db.insert('proveedores', map);
  }

  Future<int> updateProveedor(Proveedor pr) async {
    final db = await database;
    return db.update('proveedores', pr.toMap()..remove('id'),
        where: 'id = ?', whereArgs: [pr.id]);
  }

  /// Valida que no existan productos asociados antes de eliminar.
  Future<void> deleteProveedor(int id) async {
    final db = await database;
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM productos WHERE proveedor_id = ?',
      [id],
    );
    final cantidad = Sqflite.firstIntValue(r) ?? 0;
    if (cantidad > 0) {
      throw ProveedorConProductosException(cantidad);
    }
    await db.delete('proveedores', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------- PRODUCTOS ----------------

  Future<int> countProductos() async {
    final db = await database;
    final r = await db.rawQuery('SELECT COUNT(*) AS c FROM productos');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  /// Consulta con INNER JOIN: trae el nombre del proveedor de cada producto.
  Future<List<Producto>> listProductos({String filtro = ''}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT p.id, p.nombre, p.precio, p.stock, p.proveedor_id,
             pr.nombre AS proveedor_nombre
      FROM productos p
      INNER JOIN proveedores pr ON pr.id = p.proveedor_id
      WHERE p.nombre LIKE ?
      ORDER BY p.nombre COLLATE NOCASE
    ''', ['%${filtro.trim()}%']);
    return rows.map(Producto.fromMap).toList();
  }

  Future<int> insertProducto(Producto pr) async {
    final db = await database;
    final map = pr.toMap()..remove('id');
    return db.insert('productos', map);
  }

  Future<int> updateProducto(Producto pr) async {
    final db = await database;
    return db.update('productos', pr.toMap()..remove('id'),
        where: 'id = ?', whereArgs: [pr.id]);
  }

  Future<int> deleteProducto(int id) async {
    final db = await database;
    return db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }
}
