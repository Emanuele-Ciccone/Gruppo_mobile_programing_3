import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../model/oggetto_model.dart';
import '../model/lista_model.dart';
import '../model/categoria_model.dart';
import '../model/listaOggetto_model.dart';
import '../model/oggettoCategoria_model.dart';


class AnalisiPage extends StatefulWidget{
  const AnalisiPage({super.key});

  @override
  AnalisiStatePage createState() => AnalisiStatePage(); 
}

class AnalisiStatePage extends State<AnalisiPage> {
  late AppDataProvider data;

  double SpesaTotale = 0.0;
  double MediaSettimanale = 0.0;
    List<Map<String, dynamic>> categorie = [];
    List<ChartData> chartData =[];
    List<Map<String, dynamic>> settimane = [];
    List<SettimanaSpesa> setspesa = [];
    List<Map<String, dynamic>> ogg = [];
    List<OggettiFrequenti> oggfreq = [];

  Oggetto banana = new Oggetto(id: 2,nome : 'banana',prezzo: 3.0);
  Oggetto fragola = new Oggetto(id: 3,nome : 'fragola',prezzo: 4.0);
  Oggetto spazzolino = new Oggetto(id: 4,nome : 'spazzolino',prezzo: 5.0);
  Lista lista = new Lista(nome: 'Lista1', id: 1);
  Categoria cibo = new Categoria(id : 1,nome: 'cibo');
  Categoria igiene = new Categoria(id : 2, nome: 'igiene');
  ListaOggetto lo = new ListaOggetto(listaId:'1', oggettoId: 2, quantita: 2, data: DateTime.now());
  ListaOggetto log = new ListaOggetto(listaId:'1', oggettoId: 3, quantita: 1, data: DateTime.now());
  ListaOggetto loo = new ListaOggetto(listaId:'1', oggettoId: 4, quantita: 3, data: DateTime.now());
  OggettoCategoria oc = new OggettoCategoria(oggettoId: 2, categoriaId: 1);
  OggettoCategoria oc2 = new OggettoCategoria(oggettoId: 3, categoriaId: 1);
  OggettoCategoria oc3 = new OggettoCategoria(oggettoId: 4, categoriaId: 2);
  
  Future<void> aggiornaSpesaMensile() async {
      double spesa = await data.getSpesaTotale();
      setState(() {
        SpesaTotale = spesa;
      });
    }

    Future<void> aggiornaMediaSettimanale() async {
      double media = await data.getMediaSettimanale();
      setState(() {
        MediaSettimanale = media;
      });
    }

    Future<void> aggiornaCategorie() async {
    var result = await data.getCategorie();
    setState(() {
      categorie = result;
      chartData = categorie.map((cat) {
    return ChartData(cat['Nome'] as String, cat['Frequenza'] as int);
    }).toList();
    });
  }

  Future<void> aggiornaSettimane() async {
    var result = await data.getSpesa();
    setState(() {
      settimane = result;
      setspesa = settimane.map((cat) {
    return SettimanaSpesa(cat['Settimana'] as String, cat['SpesaPrezzo'] as double);
    }).toList();
    });
  }

  Future<void> aggiornaOggettiFrequenti() async {
    var result = await data.getOggFreq();
    setState(() {
      ogg = result;
      oggfreq = ogg.map((cat) {
    return OggettiFrequenti(cat['Nome'] as String, cat['Frequenza'] as int);
    }).toList();
    });
  }
  
  
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    data = Provider.of<AppDataProvider>(context, listen: false);
    
    // Inizializza i dati una sola volta
    data.aggiungiLista(lista.nome);
    data.aggiungiOggetto(banana);
    data.aggiungiOggetto(fragola);
    data.aggiungiOggetto(spazzolino);
    data.aggiungiCategoria(cibo);
    data.aggiungiCategoria(igiene);
    data.assegnaOggettoALista(lo);
    data.assegnaOggettoALista(log);
    data.assegnaOggettoALista(loo);
    data.assegnaCategoriaAOggetto(oc);
    data.assegnaCategoriaAOggetto(oc2);
    data.assegnaCategoriaAOggetto(oc3);

    aggiornaSpesaMensile();
    aggiornaMediaSettimanale();
    aggiornaCategorie();
    aggiornaSettimane();
    aggiornaOggettiFrequenti();
    });
  }

  @override
  Widget build(BuildContext context) {
     //final data = Provider.of<AppDataProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Analisi')),
      body: Center(
      child :SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IntrinsicHeight(
            child : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text( 'Spese totali \n  mensili\n €${SpesaTotale.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                  ),
                SizedBox(width: 4),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Media settimanale \n  €${MediaSettimanale.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ]
            ),
            ),
            SizedBox(height: 8),
            Container(
              child  :SfCircularChart(
                title: ChartTitle(text: 
                'Top 5 Categorie Usate',
                textStyle: TextStyle(
                color: Colors.black, 
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                  ),
                ),
                legend: Legend(isVisible: true),
                series: <CircularSeries>[
                  PieSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                    explode: true, 
                    explodeGesture: ActivationMode.singleTap,
                  )
                ]
              )
            ),
            SizedBox(height: 8),
            Text('Spese settimanali',
            style: TextStyle(color: Colors.black, 
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
            )),
            SizedBox(height: 8),
            SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child : Container(
              width: MediaQuery.of(context).size.width * 2,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: 'Settimane'),
                ),
                primaryYAxis: NumericAxis(
                  //interval:100,

                title: AxisTitle(text: 'Soldi spesi'),
                ),
        series: <CartesianSeries>[
          LineSeries<SettimanaSpesa, String>(
            dataSource: setspesa,
            xValueMapper: (SettimanaSpesa val, _) => val.x,
            yValueMapper: (SettimanaSpesa val, _) => val.y,
            )
          ],
          ),
          ),
          ),
          SizedBox(height: 8),
          Container(
              child: SfPyramidChart(
                title: ChartTitle(text: 
                '3 oggetti più comprati',
                textStyle: TextStyle(
                color: Colors.black, 
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                  ),
                ),
                series:PyramidSeries<OggettiFrequenti, String>(
                    dataSource: oggfreq,
                          xValueMapper: (OggettiFrequenti data, _) => data.x,
                          yValueMapper: (OggettiFrequenti data, _) => data.y,
                          explode: true,
                          explodeGesture: ActivationMode.singleTap,
                      )
                    )
                )
          ],
        ),
      ),
      )
    );
  }
}
class ChartData {
    ChartData(this.x,this.y);
      final String x;
      final int y;
  }

class SettimanaSpesa{
  SettimanaSpesa(this.x,this.y);
    final String x;
    final double y; 
}

class OggettiFrequenti{
  OggettiFrequenti(this.x,this.y);
    final String x;
    final int y; 
}