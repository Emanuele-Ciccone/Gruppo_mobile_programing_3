import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';
import '../model/oggetto_model.dart';
import '../model/categoria_model.dart';
import '../model/oggettoCategoria_model.dart';

class Lista_Oggetti extends StatelessWidget {
  const Lista_Oggetti({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutti gli Oggetti'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AggiungiOggettoPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Aggiungi nuovo oggetto',
      ),
      body: data.oggetti.isEmpty
          ? const Center(child: Text('Nessun oggetto trovato.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.oggetti.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final oggetto = data.oggetti[index];
                // Trova le categorie collegate a questo oggetto
                final categorieOggetto = data.oggettoCategorie
                    .where((oc) => oc.oggettoId == oggetto.id)
                    .map((oc) => data.categorie.firstWhere(
                          (cat) => cat.id == oc.categoriaId,
                          orElse: () => Categoria(id: -1, nome: 'Sconosciuta'),
                        ))
                    .where((cat) => cat.id != -1)
                    .toList();

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(oggetto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prezzo: €${oggetto.prezzo?.toStringAsFixed(2) ?? '0.00'}'),
                        if (categorieOggetto.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            children: categorieOggetto
                                .map((cat) => Chip(
                                      label: Text(cat.nome),
                                      backgroundColor: Colors.transparent, // Sfondo trasparente
                                      labelStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      side: const BorderSide(color: Colors.green, width: 2), // Bordo verde
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.edit, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AggiungiOggettoPage(oggettoDaModificare: oggetto),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class AggiungiOggettoPage extends StatefulWidget {
  final Oggetto? oggettoDaModificare;
  const AggiungiOggettoPage({super.key, this.oggettoDaModificare});

  @override
  State<AggiungiOggettoPage> createState() => _AggiungiOggettoPageState();
}

class _AggiungiOggettoPageState extends State<AggiungiOggettoPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController prezzoController = TextEditingController();
  final Set<int> selectedCategorie = {};

  @override
  void initState() {
    super.initState();
    if (widget.oggettoDaModificare != null) {
      nomeController.text = widget.oggettoDaModificare!.nome;
      prezzoController.text = widget.oggettoDaModificare!.prezzo?.toString() ?? '';
      final data = Provider.of<AppDataProvider>(context, listen: false);
      selectedCategorie.addAll(
        data.oggettoCategorie
            .where((oc) => oc.oggettoId == widget.oggettoDaModificare!.id)
            .map((oc) => oc.categoriaId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);
    final isModifica = widget.oggettoDaModificare != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isModifica ? 'Modifica Oggetto' : 'Nuovo Oggetto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome oggetto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: prezzoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Prezzo',
                border: OutlineInputBorder(),
                prefixText: '€ ',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: data.categorie.map((categoria) {
                final isSelected = selectedCategorie.contains(categoria.id);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedCategorie.remove(categoria.id);
                      } else {
                        selectedCategorie.add(categoria.id!);
                      }
                    });
                  },
                  child: Chip(
                    label: Text(categoria.nome),
                    backgroundColor: Colors.transparent, // Sfondo trasparente
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    side: BorderSide(
                      color: isSelected ? Colors.green : Colors.grey, // Cambia il colore del bordo
                      width: 2,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final nome = nomeController.text.trim();
                  final prezzo = double.tryParse(prezzoController.text.trim()) ?? 0;

                  if (nome.isNotEmpty && prezzo > 0) {
                    if (isModifica) {
                      await data.updateOggetto(widget.oggettoDaModificare!, nome, prezzo);
                      // Rimuovi tutte le categorie attuali
                      for (final oc in data.oggettoCategorie.where((oc) => oc.oggettoId == widget.oggettoDaModificare!.id)) {
                        await data.rimuoviCategoriaDaOggetto(oc);
                      }
                      // Assegna le nuove categorie
                      for (final catId in selectedCategorie) {
                        await data.assegnaCategoriaAOggetto(OggettoCategoria(
                          oggettoId: widget.oggettoDaModificare!.id,
                          categoriaId: catId,
                        ));
                      }
                    } else {
                      final nuovoOggetto = Oggetto(nome: nome, prezzo: prezzo);
                      await data.aggiungiOggetto(nuovoOggetto);
                      // Recupera l'id appena creato
                      final ogg = data.oggetti.firstWhere((o) => o.nome == nome);
                      for (final catId in selectedCategorie) {
                        await data.assegnaCategoriaAOggetto(OggettoCategoria(
                          oggettoId: ogg.id,
                          categoriaId: catId,
                        ));
                      }
                    }
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Inserisci un nome valido e un prezzo maggiore di 0'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isModifica ? 'Salva Modifiche' : 'Aggiungi Oggetto',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}