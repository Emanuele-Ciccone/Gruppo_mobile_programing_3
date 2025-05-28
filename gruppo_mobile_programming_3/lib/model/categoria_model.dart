class Categoria {
  final int? id;
  final String nome;

  Categoria({this.id, required this.nome});

  factory Categoria.fromMap(Map<String, dynamic> map) => Categoria(
    id: map['Id'],
    nome: map['Nome'],
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'Id': id,
    'Nome': nome,
  };
}
