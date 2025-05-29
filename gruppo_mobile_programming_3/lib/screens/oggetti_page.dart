import 'package:flutter/material.dart';

class OggettoSessione {
  String nome;
  double prezzo;
  int quantita;

  OggettoSessione({required this.nome, required this.prezzo, this.quantita = 1});
}

class OggettiPage extends StatefulWidget {
  final dynamic lista;

  const OggettiPage({super.key, required this.lista});

  @override
  State<OggettiPage> createState() => _OggettiPageState();
}

class _OggettiPageState extends State<OggettiPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController prezzoController = TextEditingController();
  List<OggettoSessione> oggetti = [];

  @override
  Widget build(BuildContext context) {
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
          children: [
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
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Prezzo'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final nome = nomeController.text.trim();
                    final prezzo = double.tryParse(prezzoController.text.trim()) ?? 0.0;
                    if (nome.isNotEmpty && prezzo > 0) {
                      setState(() {
                        oggetti.add(OggettoSessione(nome: nome, prezzo: prezzo));
                        nomeController.clear();
                        prezzoController.clear();
                      });
                    }
                  },
                  child: const Text('Aggiungi'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: oggetti.length,
                itemBuilder: (context, index) {
                  final oggetto = oggetti[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(oggetto.nome),
                      subtitle: Text('Prezzo: €${(oggetto.prezzo * oggetto.quantita).toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (oggetto.quantita > 1) {
                                  oggetto.quantita--;
                                } else {
                                  oggetti.removeAt(index);
                                }
                              });
                            },
                          ),
                          Text('${oggetto.quantita}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                oggetto.quantita++;
                              });
                            },
                          ),
                        ],
                      ),
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
