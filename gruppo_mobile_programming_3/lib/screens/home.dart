import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<AppDataProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Homepage')),
      body: ListView.builder(
        itemCount: data.liste.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data.liste[index].nome),
          );
        },
      ),
    );
  }
}
