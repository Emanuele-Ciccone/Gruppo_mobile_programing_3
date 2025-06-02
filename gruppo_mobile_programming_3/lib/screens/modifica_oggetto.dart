import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';
import '../model/oggetto_model.dart';
import '../model/oggettoCategoria_model.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.oggettoDaModificare != null) {
        nomeController.text = widget.oggettoDaModificare!.nome;
        prezzoController.text = widget.oggettoDaModificare!.prezzo?.toString() ?? '';
        final data = Provider.of<AppDataProvider>(context, listen: false);
        setState(() {
          selectedCategorie.addAll(
            data.oggettoCategorie
                .where((oc) => oc.oggettoId == widget.oggettoDaModificare!.id)
                .map((oc) => oc.categoriaId),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    nomeController.dispose();
    prezzoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);
    final theme = Theme.of(context);
    final isModifica = widget.oggettoDaModificare != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: Text(
          isModifica ? 'Modifica Oggetto' : 'Nuovo Oggetto',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome oggetto',
                            hintText: 'Es. Mela, Pane, Latte...',
                            prefixIcon: Icon(Icons.inventory_2, color: theme.primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.primaryColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: prezzoController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Prezzo',
                            hintText: 'Es. 2.50',
                            prefixIcon: Icon(Icons.euro, color: theme.primaryColor),
                            prefixText: '€ ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: theme.primaryColor, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (data.categorie.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Categorie',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: data.categorie.map((categoria) {
                              final isSelected = selectedCategorie.contains(categoria.id);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedCategorie.remove(categoria.id);
                                    } else {
                                      if (categoria.id != null) {
                                        selectedCategorie.add(categoria.id!);
                                      }
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? theme.primaryColor.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected 
                                          ? theme.primaryColor 
                                          : Colors.grey.withOpacity(0.3),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    categoria.nome,
                                    style: TextStyle(
                                      color: isSelected 
                                          ? theme.primaryColor
                                          : Colors.grey[700],
                                      fontWeight: isSelected 
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Pulsante principale (Salva/Aggiungi)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _salvaOggetto(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            Icon(
                              isModifica ? Icons.save : Icons.add,
                              size: 20,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            isModifica ? 'Salva Modifiche' : 'Aggiungi Oggetto',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Pulsante di eliminazione (solo in modalità modifica)
                  if (isModifica) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => _mostraDialogEliminazione(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Elimina Oggetto',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Future<void> _salvaOggetto() async {
    final nome = nomeController.text.trim();
    final prezzoText = prezzoController.text.trim();
    final isModifica = widget.oggettoDaModificare != null;
    if (nome.isEmpty) {
      _mostraErrore('Il nome dell\'oggetto è obbligatorio');
      return;
    }
    if (prezzoText.isEmpty) {
      _mostraErrore('Il prezzo è obbligatorio');
      return;
    }
    final prezzo = double.tryParse(prezzoText);
    if (prezzo == null || prezzo <= 0) {
      _mostraErrore('Inserisci un prezzo valido maggiore di 0');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final data = Provider.of<AppDataProvider>(context, listen: false);
      if (isModifica) {
        await data.updateOggetto(widget.oggettoDaModificare!, nome, prezzo);
        final oggettoCategorieDaRimuovere = data.oggettoCategorie
            .where((oc) => oc.oggettoId == widget.oggettoDaModificare!.id)
            .toList();  
        for (final oc in oggettoCategorieDaRimuovere) {
          await data.rimuoviCategoriaDaOggetto(oc);
        }
        for (final catId in selectedCategorie) {
          await data.assegnaCategoriaAOggetto(OggettoCategoria(
            oggettoId: widget.oggettoDaModificare!.id,
            categoriaId: catId,
          ));
        }
      } else {
        final nuovoOggetto = Oggetto(nome: nome, prezzo: prezzo);
        await data.aggiungiOggetto(nuovoOggetto);        
        final oggetto = data.oggetti.firstWhere((o) => o.nome == nome && o.prezzo == prezzo);
        for (final catId in selectedCategorie) {
          await data.assegnaCategoriaAOggetto(OggettoCategoria(
            oggettoId: oggetto.id,
            categoriaId: catId,
          ));
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _mostraErrore('Errore durante il salvataggio: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostraDialogEliminazione() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              SizedBox(width: 12),
              Text('Conferma eliminazione'),
            ],
          ),
          content: Text(
            'Sei sicuro di voler eliminare "${widget.oggettoDaModificare?.nome}"?\n\nQuesta azione non può essere annullata.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annulla',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _eliminaOggetto();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Elimina',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminaOggetto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = Provider.of<AppDataProvider>(context, listen: false);
      
      // Prima rimuovi tutte le associazioni categoria-oggetto
      final oggettoCategorieDaRimuovere = data.oggettoCategorie
          .where((oc) => oc.oggettoId == widget.oggettoDaModificare!.id)
          .toList();
          
      for (final oc in oggettoCategorieDaRimuovere) {
        await data.rimuoviCategoriaDaOggetto(oc);
      }
      
      // Poi elimina l'oggetto
      await data.rimuoviOggetto(widget.oggettoDaModificare!.nome);
      
      if (mounted) {
        // Mostra un messaggio di successo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oggetto "${widget.oggettoDaModificare!.nome}" eliminato con successo'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // Torna alla schermata precedente
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _mostraErrore('Errore durante l\'eliminazione: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostraErrore(String messaggio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messaggio),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}