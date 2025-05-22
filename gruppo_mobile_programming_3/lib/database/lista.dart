class Lista{
  final String nome;

  const Lista(
      {required this.nome});
  
  Map<String, Object?> toMap() {
    return {'nome': nome};
  }

  @override
  String toString() {
    return 'Lista{nome: $nome}';
  }
}