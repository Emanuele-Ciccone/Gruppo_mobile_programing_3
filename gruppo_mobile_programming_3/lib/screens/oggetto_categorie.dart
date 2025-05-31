import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';
import '../model/oggetto_model.dart';
import '../model/categoria_model.dart';
import '../model/oggettoCategoria_model.dart';

class OggettoCategoriePage extends StatelessWidget {
  final Oggetto oggetto;

  const OggettoCategoriePage({super.key, required this.oggetto});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);

    final tutteCategorie = data.categorie;
    final oggettoCategorie = data.oggettoCategorie
        .where((oc) => oc.oggettoId == oggetto.id)
        .map((oc) => oc.categoriaId)
        .toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text('Categorie di ${oggetto.nome}'),
      ),
      body: ListView(
        children: tutteCategorie.map((categoria) {
          final isAssigned = oggettoCategorie.contains(categoria.id);
          return ListTile(
            title: Text(categoria.nome),
            trailing: isAssigned
                ? IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    tooltip: 'Rimuovi da questa categoria',
                    onPressed: () async {
                      await data.rimuoviCategoriaDaOggetto(
                        OggettoCategoria(oggettoId: oggetto.id!, categoriaId: categoria.id!),
                      );
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    tooltip: 'Aggiungi a questa categoria',
                    onPressed: () async {
                      await data.assegnaCategoriaAOggetto(
                        OggettoCategoria(oggettoId: oggetto.id!, categoriaId: categoria.id!),
                      );
                    },
                  ),
            leading: isAssigned
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.radio_button_unchecked),
          );
        }).toList(),
      ),
    );
  }
}