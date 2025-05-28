import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/categoria_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<SharedData>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Homepage')),
      body: ListView.builder(
        itemCount: data.shoppingLists.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data.shoppingLists[index]),
          );
        },
      ),
    );
  }
}
