import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/categoria_model.dart';

class AnalisiPage extends StatelessWidget {
  const AnalisiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<SharedData>(context);
    final items = data.shoppingLists;

    return Scaffold(
      appBar: AppBar(title: const Text('Analisi')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Numero di liste'),
            trailing: Text('${items.length}'),
          ),
          ListTile(
            title: const Text('Liste'),
            subtitle: Text(items.isEmpty ? 'Nessuna lista' : items.join(', ')),
          ),
        ],
      ),
    );
  }
}
