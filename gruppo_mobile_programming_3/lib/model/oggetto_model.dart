class Oggetto {
  static int _counter = 0;

  final int id;
  final String nome;
  final double? prezzo;

  Oggetto({int? id, required this.nome, required this.prezzo})
      : id = id ?? _counter++;

  factory Oggetto.fromMap(Map<String, dynamic> map) => Oggetto(
        id: map['Id'],
        nome: map['Nome'],
        prezzo: map['Prezzo']?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'Id': id,
        'Nome': nome,
        'Prezzo': prezzo,
      };
}
