import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';
import '../model/oggetto_model.dart';

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
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(oggetto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Prezzo: €${oggetto.prezzo?.toStringAsFixed(2) ?? '0.00'}'),
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

  @override
  void initState() {
    super.initState();
    if (widget.oggettoDaModificare != null) {
      nomeController.text = widget.oggettoDaModificare!.nome;
      prezzoController.text = widget.oggettoDaModificare!.prezzo?.toString() ?? '';
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
                    } else {
                      await data.aggiungiOggetto(Oggetto(nome: nome, prezzo: prezzo));
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
            if (isModifica) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final conferma = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Conferma eliminazione'),
                        content: Text('Vuoi eliminare "${widget.oggettoDaModificare!.nome}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annulla'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Elimina'),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                          ),
                        ],
                      ),
                    );
                    
                    if (conferma == true) {
                      await data.rimuoviOggetto(widget.oggettoDaModificare!.nome);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Elimina Oggetto'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}