class OggettoCategoria {
  final int oggettoId;
  final int categoriaId;

  OggettoCategoria({
    required this.oggettoId,
    required this.categoriaId,
  });

  factory OggettoCategoria.fromMap(Map<String, dynamic> map) => OggettoCategoria(
    oggettoId: map['OggettoId'],
    categoriaId: map['CategoriaId'],
  );

  Map<String, dynamic> toMap() => {
    'OggettoId': oggettoId,
    'CategoriaId': categoriaId,
  };
}
