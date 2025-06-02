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
  List<ListaOggetto> oggettiInLista = [];

  @override
  void initState() {
    super.initState();
    _caricaOggettiInLista();
  }

  Future<void> _caricaOggettiInLista() async {
    final data = Provider.of<AppDataProvider>(context, listen: false);
    oggettiInLista = await data.getOggettiDiLista(widget.lista.nome);
    setState(() {});
  }

  bool _oggettoGiaInLista(String oggettoId) {
    return oggettiInLista.any((item) => item.oggettoId == oggettoId);
  }

  void _mostraMessaggio(String messaggio, {bool isError = false}) {
    // Nasconde il SnackBar precedente prima di mostrarne uno nuovo
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messaggio),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2), // Durata più breve
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.lista.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card per aggiungere oggetto esistente
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.add_shopping_cart, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Aggiungi oggetto esistente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Oggetto>(
                                value: oggettoEsistenteSelezionato,
                                hint: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text("Scegli oggetto esistente"),
                                ),
                                isExpanded: true,
                                items: data.oggetti
                                    .where((oggetto) => !_oggettoGiaInLista(oggetto.nome))
                                    .map((oggetto) {
                                  return DropdownMenuItem(
                                    value: oggetto,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(oggetto.nome),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    oggettoEsistenteSelezionato = val;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: oggettoEsistenteSelezionato == null
                              ? null
                              : () async {
                                  final oggetto = oggettoEsistenteSelezionato!;
                                  
                                  if (_oggettoGiaInLista(oggetto.nome)) {
                                    _mostraMessaggio(
                                      'Oggetto già presente nella lista!',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  final relazione = ListaOggetto(
                                    listaId: widget.lista.nome,
                                    oggettoId: oggetto.id,
                                    quantita: 1,
                                    data: DateTime.now(),
                                    IsCheck: 0,
                                  );

                                  await data.assegnaOggettoALista(relazione);
                                  await _caricaOggettiInLista();
                                  
                                  if (mounted) {
                                    setState(() {
                                      oggettoEsistenteSelezionato = null;
                                    });
                                    _mostraMessaggio('Oggetto aggiunto con successo!');
                                  }
                                },
                          icon: const Icon(Icons.add),
                          label: const Text('Aggiungi'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card per aggiungere nuovo oggetto
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.create, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Crea nuovo oggetto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: nomeController,
                            decoration: InputDecoration(
                              labelText: 'Nome oggetto',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: prezzoController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Prezzo €',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final nome = nomeController.text.trim();
                            final prezzo = double.tryParse(prezzoController.text.trim()) ?? 0.0;

                            if (nome.isEmpty) {
                              _mostraMessaggio('Inserisci il nome dell\'oggetto!', isError: true);
                              return;
                            }

                            if (prezzo <= 0) {
                              _mostraMessaggio('Inserisci un prezzo valido!', isError: true);
                              return;
                            }

                            // Controlla se esiste già un oggetto con lo stesso nome
                            final oggettoEsistente = data.oggetti.any((obj) => 
                              obj.nome.toLowerCase() == nome.toLowerCase());
                            
                            if (oggettoEsistente) {
                              _mostraMessaggio(
                                'Esiste già un oggetto con questo nome!',
                                isError: true,
                              );
                              return;
                            }

                            final nuovoOggetto = Oggetto(nome: nome, prezzo: prezzo);
                            await data.aggiungiOggetto(nuovoOggetto);

                            final relazione = ListaOggetto(
                              listaId: widget.lista.nome,
                              oggettoId: nuovoOggetto.id,
                              quantita: 1,
                              data: DateTime.now(),
                              IsCheck: 0,
                            );

                            await data.assegnaOggettoALista(relazione);
                            await _caricaOggettiInLista();

                            nomeController.clear();
                            prezzoController.clear();
                            
                            _mostraMessaggio('Nuovo oggetto creato e aggiunto!');
                            setState(() {});
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Crea'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Header della lista
            Row(
              children: [
                Icon(Icons.list, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Oggetti nella lista',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            // Lista oggetti
            Expanded(
              child: FutureBuilder<List<ListaOggetto>>(
                future: data.getOggettiDiLista(widget.lista.nome),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 64, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            "Errore nel caricamento",
                            style: TextStyle(fontSize: 16, color: Colors.red[700]),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_basket_outlined, 
                               size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "Nessun oggetto nella lista",
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Aggiungi il primo oggetto!",
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
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
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: CircularProgressIndicator(strokeWidth: 2),
                                title: Text('Caricamento...'),
                              ),
                            );
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: Icon(Icons.error, color: Colors.red),
                                title: Text('Errore nel caricamento'),
                              ),
                            );
                          }

                          final oggetto = snapshot.data!;
                          final nome = oggetto.nome;
                          final prezzo = oggetto.prezzo;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Icon(
                                  Icons.shopping_bag,
                                  color: theme.primaryColor,
                                ),
                              ),
                              title: Text(
                                nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'Prezzo unitario: €${prezzo!.toStringAsFixed(2)}\n'
                                'Totale: €${(prezzo * quantita).toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        quantita > 1 ? Icons.remove : Icons.delete,
                                        color: quantita > 1 ? theme.primaryColor : Colors.red,
                                      ),
                                      onPressed: () async {
                                        if (quantita > 1) {
                                          await data.aggiornaQuantitaOggetto(entry, quantita - 1);
                                        } else {
                                          await data.rimuoviOggettoDaLista(entry);
                                          _mostraMessaggio('Oggetto rimosso dalla lista');
                                        }
                                        await _caricaOggettiInLista();
                                        setState(() {});
                                      },
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$quantita',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, color: theme.primaryColor),
                                      onPressed: () async {
                                        await data.aggiornaQuantitaOggetto(entry, quantita + 1);
                                        await _caricaOggettiInLista();
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
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

  @override
  void dispose() {
    nomeController.dispose();
    prezzoController.dispose();
    super.dispose();
  }
}