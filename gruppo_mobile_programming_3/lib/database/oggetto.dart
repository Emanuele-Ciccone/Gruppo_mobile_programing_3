import 'lista.dart';

class Oggetto{
  final String nome;
  final Lista lista;
  final int quantita;
  final double prezzo;
  final DateTime data;

  const Oggetto(
      {required this.lista,
      required this.nome,
      required this.quantita,
      required this.prezzo,
      required this.data});

  // Converte un Oggetto in una Map; le chiavi sono le colonne
  // della tabella `oggetti` nel database
  Map<String, Object?> toMap() {
    return {
      'lista': lista,
      'nome': nome,
      'quantita': quantita,
      'prezzo': prezzo,
      'data': data
    };
  }

  @override
  String toString() {
    return 'Oggetto{lista: $lista, nome: $nome, quantita: $quantita, prezzo: $prezzo, data: $data}';
  }
}