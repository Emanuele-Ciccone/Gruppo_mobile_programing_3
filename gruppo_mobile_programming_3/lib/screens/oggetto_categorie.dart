import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';
import '../model/oggetto_model.dart';
import '../model/oggettoCategoria_model.dart';

class OggettoCategoriePage extends StatefulWidget {
  final Oggetto oggetto;

  const OggettoCategoriePage({super.key, required this.oggetto});

  @override
  State<OggettoCategoriePage> createState() => _OggettoCategoriePageState();
}

class _OggettoCategoriePageState extends State<OggettoCategoriePage>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _listController;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  String? _lastChangedCategory;

  @override
  void initState() {
    super.initState();
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _listController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start the list animation
    _listController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _handleCategoryToggle({
    required bool isAssigned,
    required int categoriaId,
    required String categoriaNome,
  }) async {
    setState(() {
      _isLoading = true;
      _lastChangedCategory = categoriaNome;
    });

    _fabController.forward().then((_) => _fabController.reverse());

    final data = Provider.of<AppDataProvider>(context, listen: false);
    final oggettoCategoria = OggettoCategoria(
      oggettoId: widget.oggetto.id,
      categoriaId: categoriaId,
    );

    try {
      if (isAssigned) {
        await data.rimuoviCategoriaDaOggetto(oggettoCategoria);
      } else {
        await data.assegnaCategoriaAOggetto(oggettoCategoria);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'operazione: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _lastChangedCategory = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);
    final tutteCategorie = data.categorie;
    final oggettoCategorie = data.oggettoCategorie
        .where((oc) => oc.oggettoId == widget.oggetto.id)
        .map((oc) => oc.categoriaId)
        .toSet();

    final categorieAssegnate = tutteCategorie
        .where((cat) => oggettoCategorie.contains(cat.id))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categorie di ${widget.oggetto.nome}'),
          ],
        ),
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: Column(
        children: [
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tutteCategorie.length,
                itemBuilder: (context, index) {
                  final categoria = tutteCategorie[index];
                  final isAssigned = oggettoCategorie.contains(categoria.id);
                  final isCurrentlyChanging = _isLoading && _lastChangedCategory == categoria.nome;
                  
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200 + (index * 50)),
                    curve: Curves.easeOutBack,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      elevation: isAssigned ? 4 : 1,
                      shadowColor: isAssigned ? Colors.green.withOpacity(0.3) : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isAssigned ? Colors.green.shade300 : Colors.transparent,
                          width: isAssigned ? 2 : 0,
                        ),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isAssigned 
                              ? Colors.green.shade50 
                              : Theme.of(context).cardColor,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            categoria.nome,
                            style: TextStyle(
                              fontWeight: isAssigned ? FontWeight.bold : FontWeight.normal,
                              color: isAssigned ? Colors.green.shade800 : null,
                            ),
                          ),
                          subtitle: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isAssigned ? 1.0 : 0.6,
                            child: Text(
                              isAssigned ? 'Categoria assegnata' : 'Tocca per assegnare',
                              style: TextStyle(
                                color: isAssigned ? Colors.green.shade600 : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: isCurrentlyChanging
                            ? null
                            : () => _handleCategoryToggle(
                                isAssigned: isAssigned,
                                categoriaId: categoria.id!,
                                categoriaNome: categoria.nome,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: tutteCategorie.isEmpty
          ? null
          : ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                onPressed: () {
                  final assigned = oggettoCategorie.length;
                  final total = tutteCategorie.length;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Oggetto assegnato a $assigned/$total categorie',
                      ),
                      backgroundColor: assigned > 0 ? Colors.green : Colors.grey,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: Text('$categorieAssegnate/${tutteCategorie.length}'),
                backgroundColor: categorieAssegnate > 0 ? Colors.green : Colors.grey,
              ),
            ),
    );
  }
}