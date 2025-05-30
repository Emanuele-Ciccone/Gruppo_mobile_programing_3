import 'package:flutter/material.dart';
import '../model/categoria_model.dart';
import '../database/database_helper.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';

class CategoriaPage extends StatefulWidget {
  const CategoriaPage({super.key});

  @override
  State<CategoriaPage> createState() => _CategoriaPageState();
}

class _CategoriaPageState extends State<CategoriaPage> {
  bool _showChips = false;
  Set<String> selectedChips = {};
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<AppDataProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorie')),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: _showChips ? 200 : 0,
            child: Column(
              children: [
                Expanded(
                  child: _showChips
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Add new category row
                              Row(
                                children: [
                                  // Text field
                                  Expanded(
                                    child: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        labelText: 'Nome nuova Categoria',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Add button
                                  GestureDetector(
                                    onTap: () {
                                      final name = controller.text.trim();
                                      if (name.isNotEmpty) {
                                        Provider.of<AppDataProvider>(context, listen: false)
                                            .aggiungiCategoria(Categoria(nome: name));
                                        controller.clear();
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.add, size: 16, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text('Aggiungi', style: TextStyle(color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Existing chips with selection
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: data.categorie.map((categoria) {
                                  bool isSelected = selectedChips.contains(categoria.nome);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (!isSelected) {
                                          selectedChips.add(categoria.nome);
                                        }else if(isSelected){
                                          selectedChips.remove(categoria.nome);
                                        }
                                      });
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Chip(
                                          label: Text(categoria.nome),
                                          side: isSelected
                                              ? const BorderSide(color: Colors.green, width: 2)
                                              : null,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                // Animated divider
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showChips ? 1.0 : 0.0,
                  child: const Divider(
                    color: Colors.black54,
                    thickness: 2,
                    height: 0,
                  ),
                ),
              ],
            ),
          ),
          // Main content that moves down when chips appear
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Contenuto della pagina',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Questo contenuto si sposta verso il basso quando appaiono le categorie. '
                    'La linea con le categorie scende animata e influenza il layout del resto della pagina.',
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Contenuto aggiuntivo per testare lo scroll...',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 400),
                  Text(
                    'Fine del contenuto',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showChips = !_showChips;
          });
        },
        child: Icon(_showChips ? Icons.close : Icons.menu),
      ),
    );
  }
}
