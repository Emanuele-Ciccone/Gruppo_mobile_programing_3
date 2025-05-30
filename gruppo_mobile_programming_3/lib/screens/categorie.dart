import 'package:flutter/material.dart';
import '../model/categoria_model.dart';
import '../model/oggetto_model.dart';
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
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.topLeft, // <--- This ensures top-left alignment
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedChips.isEmpty) ...[
              Text(
                'Nessuna categoria selezionata',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Seleziona una o più categorie per visualizzare il contenuto specifico. '
                'Usa il pulsante in basso a destra per aprire il menu delle categorie.',
              ),
            ] else ...[
              Text(
                'Categorie selezionate: ${selectedChips.length}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              ...selectedChips.map((categoriaNome) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          categoriaNome,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            selectedChips.remove(categoriaNome);
                            data.rimuoviCategoria(categoriaNome);
                          }
                        )
                        ]
                    ),
                    FutureBuilder<List<Oggetto>>(
                      future: data.getOggettiByCategoria(categoriaNome),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text(
                            'Nessun oggetto',
                            style: TextStyle(color: Colors.grey),
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: snapshot.data!.map((oggetto) {
                              final nome = oggetto.nome;
                              final prezzo = oggetto.prezzo;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(nome),
                                  subtitle: Text('Prezzo: €${(prezzo!).toStringAsFixed(2)}'),
                                ),
                              );
                            }).toList(), 
                          );
                        }
                      },
                    ),
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    ),
  ),
)

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