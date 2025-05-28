import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';
class AnalisiPage extends StatelessWidget {
  const AnalisiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);;

    return Scaffold(
      appBar: AppBar(title: const Text('Analisi')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Numero di liste'),
            trailing: Text('${data.liste.length}'),
          ),
          ListTile(
            title: const Text('Liste'),
            subtitle: Text(data.liste.isEmpty ? 'Nessuna lista' : data.liste.join(', ')),
          ),
        ],
      ),
    );
  }
}
