import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';
import '../model/lista_model.dart';
import '../model/oggetto_model.dart';
import '../model/listaOggetto_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Lista> visualList = [];

  @override
  void initState() {
    super.initState();
    final data = Provider.of<AppDataProvider>(context, listen: false);
    visualList = List.from(data.liste.reversed.take(3));
  }

  void swapWithMain(int index) {
    if (index == 0) return;
    setState(() {
      final temp = visualList[0];
      visualList[0] = visualList[index];
      visualList[index] = temp;
    });
  }

  Future<double> getTotalPrezzo(AppDataProvider data, String nomeLista) async {
    final listaOggetti = await data.getOggettiDiLista(nomeLista);
    final oggetti = data.oggetti;

    double totale = 0;
    for (var lo in listaOggetti) {
      final o = oggetti.firstWhere(
        (e) => e.id == lo.oggettoId,
        orElse: () => Oggetto(id: -1, nome: '', prezzo: 0),
      );
      totale += (o.prezzo ?? 0) * lo.quantita;
    }

    return totale;
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);

    if (visualList.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Nessuna lista presente")),
      );
    }

    final mainLista = visualList[0];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('Homepage'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // MAIN LISTA che prende tutto lo spazio disponibile sopra
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: SizedBox(
                  key: ValueKey(mainLista.nome),
                  width: double.infinity,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mainLista.nome,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<List<ListaOggetto>>(
                            future: data.getOggettiDiLista(mainLista.nome),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final oggettiLista = snapshot.data!;
                              if (oggettiLista.isEmpty) return const Text("Nessun oggetto");

                              return Expanded(
                                child: ListView.builder(
                                  itemCount: oggettiLista.length,
                                  itemBuilder: (context, i) {
                                    final lo = oggettiLista[i];
                                    final oggetto = data.oggetti.firstWhere(
                                      (o) => o.id == lo.oggettoId,
                                      orElse: () => Oggetto(id: -1, nome: '', prezzo: 0),
                                    );

                                    // gestisci localmente lo stato del checkbox
                                    bool isChecked = false;

                                    return StatefulBuilder(
                                      builder: (context, setLocalState) {
                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        oggetto.nome,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'x${lo.quantita} - €${(oggetto.prezzo ?? 0).toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setLocalState(() {
                                                      isChecked = !isChecked;
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: isChecked ? Colors.green : Colors.grey, width: 2),
                                                      color: isChecked ? Colors.green : Colors.transparent,
                                                    ),
                                                    padding: const EdgeInsets.all(4),
                                                    child: Icon(
                                                      Icons.check,
                                                      size: 18,
                                                      color: isChecked ? Colors.white : Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              );


                            },
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<double>(
                            future: getTotalPrezzo(data, mainLista.nome),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const Text("Totale: ...");
                              return Text(
                                "Totale: €${snapshot.data!.toStringAsFixed(2)}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ALTRE 2 LISTE con altezza fissa in basso
            SizedBox(
              height: 120, // altezza fissa
              child: Row(
                children: List.generate(2, (i) {
                  if (visualList.length <= i + 1) return const SizedBox();
                  final lista = visualList[i + 1];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => swapWithMain(i + 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                lista.nome,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              FutureBuilder<int>(
                                future: data.getListaOggettiCountAggiornato(lista.nome),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return const Text("...");
                                  return Text('${snapshot.data} oggetti');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
