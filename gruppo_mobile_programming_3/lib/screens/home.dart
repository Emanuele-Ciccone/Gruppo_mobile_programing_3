import 'package:flutter/material.dart';
import 'package:gruppo_mobile_programming_3/screens/oggetti_page.dart';
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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<Lista> visualList = [];
  List<ListaOggetto> oggettiListaCorrente = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Aggiungi l'observer per il ciclo di vita dell'app
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  @override
  void dispose() {
    // Rimuovi l'observer quando il widget viene distrutto
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Questo metodo viene chiamato quando l'app torna in foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Ricarica i dati quando l'app torna attiva
      _initializeData();
    }
  }

  // Metodo per inizializzare/ricaricare tutti i dati
  Future<void> _initializeData() async {
    final data = Provider.of<AppDataProvider>(context, listen: false);
    
    setState(() {
      isLoading = true;
    });

    try {
      // Aggiorna la visualList dalle liste già disponibili
      visualList = List.from(data.liste.reversed.take(3));
      
      // Ricarica gli oggetti della lista principale dal database
      await _loadOggettiLista();
    } catch (e) {
      print('Errore nel caricamento dati: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadOggettiLista() async {
    if (visualList.isEmpty) {
      setState(() {
        oggettiListaCorrente = [];
        isLoading = false;
      });
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final data = Provider.of<AppDataProvider>(context, listen: false);
      final oggetti = await data.getOggettiDiLista(visualList[0].nome);
      
      setState(() {
        oggettiListaCorrente = oggetti;
        isLoading = false;
      });
    } catch (e) {
      print('Errore nel caricamento oggetti: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void swapWithMain(int index) {
    if (index == 0) return;
    setState(() {
      final temp = visualList[0];
      visualList[0] = visualList[index];
      visualList[index] = temp;
    });
    // Ricarica gli oggetti della nuova lista principale
    _loadOggettiLista();
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

  void modificaLista(Lista lista) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OggettiPage(lista: lista),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);

    if (visualList.isEmpty && !isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: RefreshIndicator(
          onRefresh: _initializeData, // Aggiungi pull-to-refresh
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "Nessuna lista presente",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeData,
                  child: Text('Ricarica'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4299E1)),
          ),
        ),
      );
    }

    final mainLista = visualList[0];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Le Mie Liste',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _initializeData, // Pull-to-refresh
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // MAIN LISTA che prende tutto lo spazio disponibile sopra
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: Container(
                    key: ValueKey(mainLista.nome),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header con titolo e pulsante modifica
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  mainLista.nome,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ),
                              Material(
                                color: const Color(0xFF4299E1),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => modificaLista(mainLista),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Lista oggetti
                          oggettiListaCorrente.isEmpty
                              ? Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 60,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Nessun oggetto nella lista",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: ListView.separated(
                                    itemCount: oggettiListaCorrente.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                                    itemBuilder: (context, i) {
                                      var lo = oggettiListaCorrente[i];
                                      final oggetto = data.oggetti.firstWhere(
                                        (o) => o.id == lo.oggettoId,
                                        orElse: () => Oggetto(id: -1, nome: '', prezzo: 0),
                                      );

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: lo.IsCheck == 1 ? const Color(0xFFF0FFF4) : Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: lo.IsCheck == 1 ? const Color(0xFF68D391) : Colors.grey[200]!,
                                            width: lo.IsCheck == 1 ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              // Checkbox personalizzato - VERSIONE MIGLIORATA
                                              
                                              
                                              // Informazioni oggetto
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      oggetto.nome,
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFF2D3748),
                                                        decoration: (lo.IsCheck == 1) ? TextDecoration.lineThrough : null,
                                                        decorationColor: Colors.grey[500],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF4299E1).withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Text(
                                                            'x${lo.quantita}',
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                              color: Color(0xFF4299E1),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                        Text(
                                                          '€${(oggetto.prezzo ?? 0).toStringAsFixed(2)}',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.grey[700],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 16),

                                              GestureDetector(
                                                onTap: () async {
                                                  final nuovoStato = lo.IsCheck == 1 ? 0 : 1;                                                  
                                                  await data.aggiornaStatoOggetto(lo, nuovoStato);                                     
                                                  // Ricarica subito per verificare
                                                    // Ricarica gli oggetti della lista corrente
                                                  await _loadOggettiLista();
                                                    // Poi aggiorna immediatamente la UI
                                                    setState(() {
                                                      oggettiListaCorrente[i] = ListaOggetto(
                                                        listaId: lo.listaId,
                                                        data: lo.data,
                                                        oggettoId: lo.oggettoId,
                                                        quantita: lo.quantita,
                                                        IsCheck: nuovoStato,
                                                      );
                                                    });

                                                },

                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 200),
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: (lo.IsCheck == 1) ? const Color(0xFF48BB78) : Colors.transparent,
                                                    border: Border.all(
                                                      color: (lo.IsCheck == 1) ? const Color(0xFF48BB78) : Colors.grey[400]!,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: (lo.IsCheck == 1)
                                                      ? const Icon(
                                                          Icons.check,
                                                          size: 18,
                                                          color: Colors.white,
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          
                          const SizedBox(height: 20),
                          
                          // Totale
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D3748),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Totale Spesa:",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    double totale = 0;
                                    for (var lo in oggettiListaCorrente) {
                                      final oggetto = data.oggetti.firstWhere(
                                        (o) => o.id == lo.oggettoId,
                                        orElse: () => Oggetto(id: -1, nome: '', prezzo: 0),
                                      );
                                      totale += (oggetto.prezzo ?? 0) * lo.quantita;
                                    }
                                    
                                    return Text(
                                      "€${totale.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color(0xFF68D391),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ALTRE 2 LISTE
              SizedBox(
                height: 140,
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
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4299E1).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.list_alt,
                                    color: Color(0xFF4299E1),
                                    size: 24,
                                  ),
                                ),
                                Text(
                                  lista.nome,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                FutureBuilder<int>(
                                  future: data.getListaOggettiCountAggiornato(lista.nome),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Text(
                                        "...",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    }
                                    return Text(
                                      '${snapshot.data} ${snapshot.data == 1 ? 'oggetto' : 'oggetti'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
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
      ),
    );
  }
}