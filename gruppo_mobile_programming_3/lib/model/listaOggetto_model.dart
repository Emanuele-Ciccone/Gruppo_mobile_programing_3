class ListaOggetto {
  final String listaId;
  final int oggettoId;
  final int quantita;
  final DateTime data;

  ListaOggetto({
    required this.listaId,
    required this.oggettoId,
    required this.quantita,
    required this.data,
  });

  factory ListaOggetto.fromMap(Map<String, dynamic> map) => ListaOggetto(
    listaId: map['ListaId'],
    oggettoId: map['OggettoId'],
    quantita: map['Quantita'],
    data: DateTime.parse(map['Data']),
  );

  Map<String, dynamic> toMap() => {
    'ListaId': listaId,
    'OggettoId': oggettoId,
    'Quantita': quantita,
    'Data': data.toIso8601String(),
  };
}
