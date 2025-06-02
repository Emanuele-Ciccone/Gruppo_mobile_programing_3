import 'package:flutter/material.dart';
import '../provider/appData_provider.dart';
import 'package:provider/provider.dart';
import '../model/oggetto_model.dart';
import '../model/listaOggetto_model.dart';
import '../model/lista_model.dart';
import 'oggetto_categorie.dart';

class OggettiPage extends StatefulWidget {
  final Lista lista;

  const OggettiPage({super.key, required this.lista});

  @override
  State<OggettiPage> createState() => _OggettiPageState();
}

class _OggettiPageState extends State<OggettiPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController prezzoController = TextEditingController();
  Oggetto? oggettoEsistenteSelezionato;


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);
    

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lista.nome),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prima riga: Dropdown + bottone per aggiungere oggetto esistente
            Row(
              children: [
                Expanded(
                  child: DropdownButton<Oggetto>(
                    value: oggettoEsistenteSelezionato,
                    hint: const Text("Scegli oggetto esistente"),
                    isExpanded: true,
                    items: data.oggetti.map((oggetto) {
                      return DropdownMenuItem(
                        value: oggetto,
                        child: Text(oggetto.nome),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        oggettoEsistenteSelezionato = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final oggetto = oggettoEsistenteSelezionato;
                    if (oggetto != null) {
                      final relazione = ListaOggetto(
                        listaId: widget.lista.nome,
                        oggettoId: oggetto.id,
                        quantita: 1,
                        data: DateTime.now(),
                      );

                      await data.assegnaOggettoALista(relazione);

                      if (mounted) {
                        setState(() {
                          oggettoEsistenteSelezionato = null;
                        });
                      }
                    }
                  },
                  child: const Text('Aggiungi'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Seconda riga: campi testo + bottone per aggiungere nuovo oggetto
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(labelText: 'Nome oggetto'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: prezzoController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Prezzo'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final nome = nomeController.text.trim();
                    final prezzo = double.tryParse(prezzoController.text.trim()) ?? 0.0;

                    if (nome.isNotEmpty && prezzo > 0) {
                      final nuovoOggetto = Oggetto(nome: nome, prezzo: prezzo);

                      await data.aggiungiOggetto(nuovoOggetto);

                      final relazione = ListaOggetto(
                        listaId: widget.lista.nome,
                        oggettoId: nuovoOggetto.id,
                        quantita: 1,
                        data: DateTime.now(),
                      );

                      await data.assegnaOggettoALista(relazione);

                      nomeController.clear();
                      prezzoController.clear();

                      setState(() {});
                    }
                  },
                  child: const Text('Aggiungi'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Lista oggetti in Expanded per occupare tutto lo spazio rimasto
            Expanded(
              child: FutureBuilder<List<ListaOggetto>>(
                future: data.getOggettiDiLista(widget.lista.nome),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Errore: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Nessun oggetto nella lista."));
                  }

                  final listaOggetti = snapshot.data!;

                  return ListView.builder(
                    itemCount: listaOggetti.length,
                    itemBuilder: (context, index) {
                      final entry = listaOggetti[index];
                      final quantita = entry.quantita;

                      return FutureBuilder<Oggetto>(
                        future: data.getOggetto(entry.oggettoId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const ListTile(title: Text('Caricamento oggetto...'));
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return const ListTile(title: Text('Errore nel caricamento'));
                          }

                          final oggetto = snapshot.data!;
                          final nome = oggetto.nome;
                          final prezzo = oggetto.prezzo;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(nome),
                              subtitle: Text('Prezzo: €${(prezzo! * quantita).toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () async {
                                      if (quantita > 1) {
                                        await data.aggiornaQuantitaOggetto(entry, quantita - 1);
                                        setState(() {});
                                      } else {
                                        await data.rimuoviOggettoDaLista(entry);
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  Text('$quantita'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () async {
                                      await data.aggiornaQuantitaOggetto(entry, quantita + 1);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OggettoCategoriePage(oggetto: oggetto),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
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
