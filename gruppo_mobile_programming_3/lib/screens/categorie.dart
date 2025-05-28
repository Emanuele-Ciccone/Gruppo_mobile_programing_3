import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';

class CategoriaPage extends StatelessWidget {
  const CategoriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<AppDataProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorie')),
      body: Center(
        child: Text(
          'Totale liste create: ${data.liste.length}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
