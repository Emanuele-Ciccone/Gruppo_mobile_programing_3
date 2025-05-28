import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/categoria_model.dart';

class CategoriaPage extends StatelessWidget {
  const CategoriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<SharedData>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorie')),
      body: Center(
        child: Text(
          'Totale liste create: ${data.shoppingLists.length}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
