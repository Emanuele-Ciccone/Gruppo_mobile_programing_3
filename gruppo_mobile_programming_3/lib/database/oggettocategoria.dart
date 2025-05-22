import 'categoria.dart';
import 'oggetto.dart';

class OggettoCategoria {
  final Oggetto oggetto;
  final Categoria categoria;

  OggettoCategoria({
    required this.oggetto, required this.categoria
    });

  Map<String, Object?> toMap() {
    return {
      'oggetto': oggetto,
      'categoria': categoria,
    };
  }

  @override
  String toString() {
    return 'OggettoCategoria{oggetto: $oggetto, categoria: $categoria}';
  }
}