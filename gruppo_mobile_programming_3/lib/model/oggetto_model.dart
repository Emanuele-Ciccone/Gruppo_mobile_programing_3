class Oggetto {
  final int? id;
  final String nome;
  final double? prezzo;

  Oggetto({this.id, required this.nome, this.prezzo});

  factory Oggetto.fromMap(Map<String, dynamic> map) => Oggetto(
    id: map['Id'],
    nome: map['Nome'],
    prezzo: map['Prezzo']?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'Id': id,
    'Nome': nome,
    'Prezzo': prezzo,
  };
}
