import 'package:flutter/foundation.dart';
import '../model/lista_model.dart';
import '../model/oggetto_model.dart';
import '../model/categoria_model.dart';
import '../model/oggettoCategoria_model.dart';
import '../model/listaOggetto_model.dart';
import '../database/database_helper.dart';

class AppDataProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Lista> _liste = [];
  List<Oggetto> _oggetti = [];
  List<Categoria> _categorie = [];
  List<OggettoCategoria> _oggettoCategorie = [];
  List<ListaOggetto> _oggettoListe = [];

  List<Lista> get liste => _liste;
  List<Oggetto> get oggetti => _oggetti;
  List<Categoria> get categorie => _categorie;
  List<OggettoCategoria> get oggettoCategorie => _oggettoCategorie;
  List<ListaOggetto> get oggettoListe => _oggettoListe;

  Future<void> loadAllData() async {
    _liste = await _db.getAllListe();
    _oggetti = await _db.getAllOggetti();
    _categorie = await _db.getAllCategorie();
    _oggettoCategorie = await _db.getAllOggettoCategorie();
    _oggettoListe = await _db.getAllOggettoListe();
    notifyListeners();
  }

  // LISTA
  Future<void> aggiungiLista(String nome) async {
    await _db.insertLista(nome);
    await loadAllData();
  }

  Future<void> rimuoviLista(String nome) async {
    await _db.deleteLista(nome);
    await loadAllData();
  }

  // OGGETTO
  Future<void> aggiungiOggetto(Oggetto oggetto) async {
    await _db.insertOggetto(oggetto);
    await loadAllData();
  }

  Future<void> rimuoviOggetto(String nome) async {
    await _db.deleteOggetto(nome);
    await loadAllData();
  }

  // CATEGORIA
  Future<void> aggiungiCategoria(Categoria categoria) async {
    await _db.insertCategoria(categoria);
    await loadAllData();
  }

  Future<void> rimuoviCategoria(String nome) async {
    await _db.deleteCategoria(nome);
    await loadAllData();
  }

  // OGGETTO-CATEGORIA
  Future<void> assegnaCategoriaAOggetto(OggettoCategoria oc) async {
    await _db.insertOggettoCategoria(oc);
    await loadAllData();
  }

  Future<void> rimuoviCategoriaDaOggetto(OggettoCategoria oc) async {
    await _db.deleteOggettoCategoria(oc);
    await loadAllData();
  }

  // OGGETTO-LISTA
  Future<void> assegnaOggettoALista(ListaOggetto ol) async {
    await _db.insertListaOggetto(ol);
    await loadAllData();
  }

  Future<void> rimuoviOggettoDaLista(ListaOggetto ol) async {
    await _db.deleteListaOggetto(ol);
    await loadAllData();
  }


  Future<int> getListaOggettiCountAggiornato(String nomeLista) async {
  return await _db.getListaOggettiCount(nomeLista);
  } 
  
  Future<List<ListaOggetto>> getOggettiDiLista(String nomeLista) async {
  return await _db.getListaOggettoByListaId(nomeLista);
  }



  Future<double> getSpesaTotale() async {
   return await _db.getSpesaTotale();
  }

  Future<double> getMediaSettimanale() async {
   return await _db.getMediaSettimanale();
  }

  Future<List<Map<String, dynamic>>> getCategorie() async {
    return await _db.getCategorie();
  }

  Future<Oggetto> getOggetto(int oggettoId) async{
    return await _db.getOggetto(oggettoId);
  }

  Future<void> aggiornaQuantitaOggetto(ListaOggetto lo, int i) {
  return _db.aggiornaQuantitaOggetto(lo, i);
  }
}
