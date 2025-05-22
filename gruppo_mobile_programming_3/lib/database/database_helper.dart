import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'lista.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'mydatabase.db'),
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE Cateogria(Nome TEXT PRIMARY KEY)');
        await db.execute('CREATE TABLE Lista(Nome TEXT PRIMARY KEY)');
        await db.execute('CREATE TABLE Oggetto(Nome TEXT, Lista REFERENCES Lista(Nome) ON UPDATE cascade ON DELETE cascade, Prezzo DOUBLE NOT NULL,Data DATETIME NOT NULL, CONSTRAINT pk_oggetto PRIMARY KEY(Nome,Lista) )');
        await db.execute('CREATE TABLE OggettoCategoria(OggettoNOME REFERENCES Oggetto(Nome) ON UPDATE cascade ON DELETE cascade,OggettoLISTA REFERENCES Oggetto(Lista) ON UPDATE cascade ON DELETE cascade,Cateogria REFERENCES Categoria(Nome) ON UPDATE cascade ON DELETE cascade)');
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