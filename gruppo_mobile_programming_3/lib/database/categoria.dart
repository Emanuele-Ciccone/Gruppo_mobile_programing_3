class Categoria{
  final String nome;

  const Categoria(
      {required this.nome});
  
  Map<String, Object?> toMap() {
    return {'nome': nome};
  }

  @override
  String toString() {
    return 'Categoria{nome: $nome}';
  }
}