import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'oggetti_page.dart';
import '../model/lista_model.dart'; // importa la classe Lista
import '../provider/appData_provider.dart'; // importa il provider corretto

class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String _searchText = '';
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context); // ottieni il provider

    // Filtra le liste in base al testo di ricerca
    final filteredListe = data.liste
    .where((l) => l.nome.toLowerCase().contains(_searchText))
    .toList()
    .reversed
    .toList(); // ← QUESTO è ciò che cambia l’ordine

  
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.search, color: Colors.grey),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchText = '';
                searchController.clear();
              }
            });
          },
        ),
        centerTitle: true,
        title: const Text('Liste della Spesa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showSearch) ...[
              TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cerca tra le liste...',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value.trim().toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Nome nuova lista'),
              onSubmitted: (value) async {
                final name = value.trim();
                if (name.isNotEmpty) {
                  await data.aggiungiLista(name);
                  controller.clear();
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await data.aggiungiLista(name);
                  controller.clear();
                }
              },
              child: const Text('Aggiungi Lista'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredListe.isEmpty
                  ? const Center(child: Text("Nessuna lista trovata"))
                  : ListView.builder(
                      itemCount: filteredListe.length,
                      itemBuilder: (context, index) {
                        final lista = filteredListe[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            title: Text(lista.nome),
                            trailing: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.black, size: 20),
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  await data.rimuoviLista(lista.nome);
                                },
                                tooltip: 'Elimina',
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OggettiPage(lista: lista),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
