import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';

class ListaPage extends StatelessWidget {
  const ListaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Liste della Spesa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Nome nuova lista'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Provider.of<AppDataProvider>(context, listen: false).aggiungiLista(name);
                  controller.clear();
                }
              },
              child: const Text('Aggiungi Lista'),
            ),
          ],
        ),
      ),
    );
  }
}
