import 'package:flutter/material.dart';
import 'database_helper.dart';
import '../model/lista_model.dart';
import '../model/oggetto_model.dart';
import '../model/categoria_model.dart';
import '../model/oggettoCategoria_model.dart';
import '../model/listaOggetto_model.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ListeScreen(),
    );
  }
}

class ListeScreen extends StatefulWidget {
  const ListeScreen({super.key});

  @override
  State<ListeScreen> createState() => _ListeScreenState();
}

class _ListeScreenState extends State<ListeScreen> {
  final TextEditingController _nomeController = TextEditingController();
  List<Lista> _liste = [];

  @override
  void initState() {
    super.initState();
    _fetchListe();
  }

  Future<void> _fetchListe() async {
    final db = DatabaseHelper.instance;
    final List<Map<String, dynamic>> maps =
        await db.database.then((db) => db.query('Lista'));

    setState(() {
      _liste = List.generate(maps.length, (i) {
        final nome = maps[i]['Nome'] as String;
        return Lista(nome: nome);
      });
    });
  }

  Future<void> _addLista() async {
    final nome = _nomeController.text;

    final lista = Lista(nome: nome);
    await DatabaseHelper.instance.insertLista(lista);
    _fetchListe();

    _nomeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _nomeController,
            decoration: InputDecoration(labelText: 'Nome Lista'),
          ),
          ElevatedButton(
            onPressed: _addLista,
            child: Text('Aggiungi Lista'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _liste.length,
              itemBuilder: (context, index) {
                final lista = _liste[index];
                return ListTile(
                  title: Text(lista.nome),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}