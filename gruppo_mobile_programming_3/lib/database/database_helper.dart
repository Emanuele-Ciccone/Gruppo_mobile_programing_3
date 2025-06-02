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
            IsCheck INTEGER NOT NULL,
            PRIMARY KEY (ListaId, OggettoId),
            FOREIGN KEY (ListaId) REFERENCES Lista(nome) ON DELETE CASCADE,
            FOREIGN KEY (OggettoId) REFERENCES Oggetto(Id) ON DELETE CASCADE
          )'''
        );
      },
      version: 1,
      onOpen: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },

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

  Future<int> getListaOggettiCount(String nomeLista) async {
  final db = await database;
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM ListaOggetto WHERE ListaId = ?', [nomeLista]
  );
  return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<ListaOggetto>> getListaOggettoByListaId(String listaId) async {
  final db = await database;
  final result = await db.query(
    'ListaOggetto',
    where: 'ListaId = ?',
    whereArgs: [listaId],
  );

  // Mappiamo i risultati in ListaOggetto
  return result.map((json) => ListaOggetto.fromMap(json)).toList();
}





  Future<List<Oggetto>> getOggettiByCategoria(String categoriaNome) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT Oggetto.*
      FROM Categoria
      INNER JOIN OggettoCategoria on Categoria.ID=OggettoCategoria.CategoriaId
      INNER JOIN Oggetto ON Oggetto.Id = OggettoCategoria.OggettoId
      WHERE Categoria.nome = ?
    ''', [categoriaNome]);
    return maps.map((map) => Oggetto.fromMap(map)).toList();
  }

  

  Future<double> getSpesaTotale() async {
  final db = await database;
  var result = await db.rawQuery(
    '''SELECT SUM(Oggetto.Prezzo * ListaOggetto.Quantita) AS SpesaTotale
       FROM ListaOggetto
       JOIN Oggetto ON ListaOggetto.OggettoId = Oggetto.Id
       WHERE strftime('%Y-%m', ListaOggetto.Data) = strftime('%Y-%m', 'now');'''
  );

  return result.isNotEmpty && result.first['SpesaTotale'] != null
    ? (result.first['SpesaTotale'] as num).toDouble()
    : 0.0;

}

Future<double> getMediaSettimanale() async {
  final db = await database;
  var result = await db.rawQuery(
    '''SELECT avg(Oggetto.prezzo * ListaOggetto.Quantita) AS MediaSettimanale
       FROM ListaOggetto
       JOIN Oggetto ON ListaOggetto.OggettoId = Oggetto.Id
      WHERE ListaOggetto.Data >= date('now', '-7 days');'''
  );

  return result.isNotEmpty && result.first['SpesaTotale'] != null
    ? (result.first['SpesaTotale'] as num).toDouble()
    : 0.0;
}

Future<List<Map<String, dynamic>>> getTotSpesaSettimana() async {
  final db = await database;
  var result = await db.rawQuery(
    '''SELECT strftime('%Y - %W', ListaOggetto.Data) as Settimana, 
              SUM(Oggetto.prezzo * ListaOggetto.Quantita) AS SpesaSettimanale
       FROM ListaOggetto
       JOIN Oggetto ON ListaOggetto.OggettoId = Oggetto.Id
       GROUP BY Settimana
       ORDER BY Settimana DESC;'''
  );

  return result;
}



Future<List<Map<String, dynamic>>> getCategorie() async {
  final db = await database;
  var result = await db.rawQuery(
    '''SELECT C.Nome, COUNT(OC.CategoriaId) AS Frequenza
       FROM Categoria C
       JOIN OggettoCategoria OC ON OC.CategoriaId = C.Id
       GROUP BY C.Nome
       ORDER BY Frequenza DESC
       LIMIT 5;'''
  );
  return result;
}

  Future<Oggetto> getOggetto(int oggettoId) async {
    final db = await database;
    final result = await db.query(
    'Oggetto',
    where: 'id = ?',
    whereArgs: [oggettoId],
  );
  return result.isNotEmpty
      ? Oggetto.fromMap(result.first)
      : throw Exception('Oggetto non trovato');
  }

  Future<List<Map<String, dynamic>>> getOggFrequenti() async {
  final db = await database;
  var result = await db.rawQuery(
    '''
    SELECT Oggetto.Nome, SUM(ListaOggetto.Quantita) AS QuantitaTotale
    FROM ListaOggetto
    JOIN Oggetto ON ListaOggetto.OggettoId = Oggetto.Id
    GROUP BY ListaOggetto.OggettoId
    ORDER BY QuantitaTotale DESC
    LIMIT 3;
    '''
  );
  return result;
}



  Future<void> aggiornaQuantitaOggetto(ListaOggetto lo, int nuovaQuantita) async {
  final db = await database;
  await db.update(
    'ListaOggetto',
    {
      'quantita': nuovaQuantita,
    },
    where: 'oggettoId = ? and listaId = ?',
    whereArgs: [lo.oggettoId, lo.listaId],
  );
  }

  Future<void> updateOggetto(Oggetto oggetto, String nome, double prezzo) async {
  final db = await database;
  await db.update(
    'Oggetto',
    {
      'nome': nome,
      'prezzo': prezzo,
    },
    where: 'id = ?',
    whereArgs: [oggetto.id],
  );
  }


  Future<void> aggiornaStatoOggetto(ListaOggetto lo, int check) async {
  final db = await database;
  await db.update(
    'ListaOggetto',
    {
      'IsCheck': check,
    },
    where: 'oggettoId = ? and listaId = ?',
    whereArgs: [lo.oggettoId, lo.listaId],
  );
  }

  

}
