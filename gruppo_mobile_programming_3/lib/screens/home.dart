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
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeData();
    }
  }

  
  Future<void> _initializeData() async {
    final data = Provider.of<AppDataProvider>(context, listen: false);
    
    setState(() {
      isLoading = true;
    });

    
    visualList = List.from(data.liste.reversed.take(3));
    
    
    await _loadOggettiLista();
    setState(() {
      isLoading = false;
    });
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
    final theme = Theme.of(context);

    if (visualList.isEmpty && !isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          centerTitle: true,
          title: const Text(
            'Le Mie Liste',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _initializeData,
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
                const SizedBox(height: 8),
                Text(
                  "Inizia creando la tua prima lista della spesa",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Ricarica',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          centerTitle: true,
          title: const Text(
            'Le Mie Liste',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
      );
    }

    final mainLista = visualList[0];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          'Le Mie Liste',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _initializeData,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.list_alt,
                                color: theme.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                mainLista.nome,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white),
                                tooltip: 'Modifica Lista',
                                onPressed: () => modificaLista(mainLista),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        
                        oggettiListaCorrente.isEmpty
                            ? Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 80,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Nessun oggetto nella lista",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Tocca il pulsante modifica per aggiungere oggetti",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  itemCount: oggettiListaCorrente.length,
                                  itemBuilder: (context, i) {
                                    var lo = oggettiListaCorrente[i];
                                    final oggetto = data.oggetti.firstWhere(
                                      (o) => o.id == lo.oggettoId,
                                      orElse: () => Oggetto(id: -1, nome: '', prezzo: 0),
                                    );

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: lo.IsCheck == 1 ? theme.primaryColor.withOpacity(0.1) : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: lo.IsCheck == 1 ? theme.primaryColor.withOpacity(0.3) : Colors.grey[200]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        title: Text(
                                          oggetto.nome,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            decoration: lo.IsCheck == 1 ? TextDecoration.lineThrough : null,
                                            decorationColor: Colors.grey[500],
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: theme.primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Qtà: ${lo.quantita}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.primaryColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '€${(oggetto.prezzo ?? 0).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: GestureDetector(
                                          onTap: () async {
                                            final nuovoStato = lo.IsCheck == 1 ? 0 : 1;
                                            await data.aggiornaStatoOggetto(lo, nuovoStato);
                                            await _loadOggettiLista();
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
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: lo.IsCheck == 1 ? theme.primaryColor : Colors.transparent,
                                              border: Border.all(
                                                color: lo.IsCheck == 1 ? theme.primaryColor : Colors.grey[400]!,
                                                width: 2,
                                              ),
                                            ),
                                            child: lo.IsCheck == 1
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 20,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                        

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Totale Spesa:",
                                style: TextStyle(
                                  fontSize: 16,
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
                                      fontSize: 18,
                                      color: Colors.white,
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

              const SizedBox(height: 16),

              if (visualList.length > 1)
                SizedBox(
                  height: 124,
                  child: Row(
                    children: List.generate(2, (i) {
                      if (visualList.length <= i + 1) return const SizedBox();
                      final lista = visualList[i + 1];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => swapWithMain(i + 1),
                          child: Container(
                            margin: EdgeInsets.only(
                              left: i == 0 ? 0 : 8,
                              right: i == 1 ? 0 : 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.list_alt,
                                      color: theme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    lista.nome,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  FutureBuilder<int>(
                                    future: data.getListaOggettiCountAggiornato(lista.nome),
                                    builder: (context, snapshot) {
                                      final count = snapshot.data ?? 0;
                                      return Text(
                                        '$count elementi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
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