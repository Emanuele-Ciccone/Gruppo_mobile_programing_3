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
            Prezzo DOUBLE,
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
            ListaId INTEGER,
            OggettoId INTEGER,
            Quantita INTEGER NOT NULL,
            Data DATETIME NOT NULL,
            PRIMARY KEY (ListaId, OggettoId),
            FOREIGN KEY (ListaId) REFERENCES Lista(Id) ON DELETE CASCADE,
            FOREIGN KEY (OggettoId) REFERENCES Oggetto(Id) ON DELETE CASCADE
          )'''
        );
      },
      version: 1,
    );
  }

  Future<void> insertLista(Lista lista) async {
    final db = await database;
    await db.insert(
      'lista',
      lista.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}