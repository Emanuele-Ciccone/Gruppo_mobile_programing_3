import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/lista_model.dart';
import '../model/oggetto_model.dart';
import '../model/categoria_model.dart';
import '../model/oggettoCategoria_model.dart';
import '../model/listaOggetto_model.dart';



class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'mydatabase.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE Categoria (
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            Nome TEXT NOT NULL UNIQUE
          )'''
        );

        await db.execute(
          '''CREATE TABLE Lista(
          Nome TEXT PRIMARY KEY
          )'''
        );

        await db.execute(
          '''CREATE TABLE Oggetto (
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            Nome TEXT NOT NULL,
            Prezzo REAL,
            Categoria TEXT,
            UNIQUE(Nome)
          )'''
        );

         await db.execute(
          '''CREATE TABLE OggettoCategoria (
            OggettoId INTEGER,
            CategoriaId INTEGER,
            PRIMARY KEY (OggettoId, CategoriaId),
            FOREIGN KEY (OggettoId) REFERENCES Oggetto(Id) ON DELETE CASCADE ON UPDATE CASCADE,
            FOREIGN KEY (CategoriaId) REFERENCES Categoria(Id) ON DELETE CASCADE ON UPDATE CASCADE
          )'''
        );

        await db.execute(
          '''CREATE TABLE ListaOggetto (
            ListaId TEXT,
            OggettoId INTEGER,
            Quantita INTEGER NOT NULL,
            Data DATETIME NOT NULL,
            PRIMARY KEY (ListaId, OggettoId),
            FOREIGN KEY (ListaId) REFERENCES Lista(nome) ON DELETE CASCADE,
            FOREIGN KEY (OggettoId) REFERENCES Oggetto(Id) ON DELETE CASCADE
          )'''
        );
      },
      version: 1,
    );
  }

  

  Future<List<Lista>> getAllListe() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Lista');
    return maps.map((map) => Lista.fromMap(map)).toList();
  }

  Future<List<Oggetto>> getAllOggetti() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Oggetto');
    return maps.map((map) => Oggetto.fromMap(map)).toList();
  }

  Future<List<Categoria>> getAllCategorie() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Categoria');
    return maps.map((map) => Categoria.fromMap(map)).toList();
  }

  Future<List<OggettoCategoria>> getAllOggettoCategorie() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('OggettoCategoria');
    return maps.map((map) => OggettoCategoria.fromMap(map)).toList();
  }

  Future<List<ListaOggetto>> getAllOggettoListe() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ListaOggetto');
    return maps.map((map) => ListaOggetto.fromMap(map)).toList();
  }

  Future<void> insertLista(String nomeLista) async {
    var lista= Lista(nome: nomeLista);
    final db = await database;
    await db.insert(
      'Lista',
      lista.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteLista(String nome) async {
    final db = await database;
    await db.delete(
      'Lista',
      where: 'Nome = ?',
      whereArgs: [nome],
    );
  }

  Future<void> insertOggetto(Oggetto oggetto) async {
    final db = await database;
    await db.insert(
      'Oggetto',
      oggetto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteOggetto(String nome) async {
    final db = await database;
    await db.delete(
      'Oggetto',
      where: 'Nome = ?',
      whereArgs: [nome],
    );
  }

  Future<void> insertCategoria(Categoria categoria)async  {
    final db = await database;
    await db.insert(
      'Categoria',
      categoria.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCategoria(String nome) async {
    final db = await database;
    await db.delete(
      'Categoria',
      where: 'Nome = ?',
      whereArgs: [nome],
    );
  }

  Future<void> insertOggettoCategoria(OggettoCategoria oc) async {
    final db = await database;
    await db.insert(
      'OggettoCategoria',
      oc.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteOggettoCategoria(OggettoCategoria oc) async {
    final db = await database;
    await db.delete(
      'OggettoCategoria',
      where: 'OggettoId = ? and CategoriaId = ?',
      whereArgs: [oc.oggettoId, oc.categoriaId],
    );
  }

  Future<void> insertListaOggetto(ListaOggetto ol) async {
    final db = await database;
    await db.insert(
      'ListaOggetto',
      ol.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteListaOggetto(ListaOggetto ol) async {
    final db = await database;
    await db.delete(
      'ListaOggetto',
      where: 'ListaId = ? and OggettoId = ?',
      whereArgs: [ol.listaId,ol.oggettoId],
    );
  }
}