class Lista {
  final int? id;
  final String nome;

  Lista({this.id, required this.nome});

  factory Lista.fromMap(Map<String, dynamic> map) => Lista(
    id: map['Id'],
    nome: map['Nome'],
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'Id': id,
    'Nome': nome,
  };
}
