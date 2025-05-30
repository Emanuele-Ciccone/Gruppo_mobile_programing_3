import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';



class AnalisiPage extends StatefulWidget{
  const AnalisiPage({super.key});

  @override
  AnalisiStatePage createState() => AnalisiStatePage(); 
}

class AnalisiStatePage extends State<AnalisiPage> {

  @override
  Widget build(BuildContext context) {
     final data = Provider.of<AppDataProvider>(context);

    double SpesaTotale = 0.0;
    double MediaSettimanale = 0.0;
    List<Map<String, dynamic>> categorie = [];
    final List<ChartData> chartData = categorie.map((cat) {
    return ChartData(cat['Nome'] as String, cat['Frequenza'] as int);
    }).toList();



    Future<void> AggiornaSpesaMensile() async {
      double spesa = await data.getSpesaTotale();
      setState(() {
        SpesaTotale = spesa;
      });
    }

    Future<void> AggiornaMediaSettimanale() async {
      double media = await data.getMediaSettimanale();
      setState(() {
        MediaSettimanale = media;
      });
    }

    Future<void> AggiornaCategorie() async {
    var result = await data.getCategorie();
    setState(() {
      categorie = result;
    });
  }


    return Scaffold(
      appBar: AppBar(title: const Text('Analisi')),
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children : [
                Container(
                  decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.lightBlueAccent, width: 4.0),
                  ),
                padding: EdgeInsets.all(20.0),
                //margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  child: Text( 'Spese totali \n  mensili\n €${SpesaTotale.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: Colors.white,
                  ),
                ),
                ),
                Container(
                  decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.lightBlueAccent, width: 4.0),
                  ),
                padding: EdgeInsets.all(20.0),
                //margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  child: Text( 'Media settimanale \n  €${MediaSettimanale.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: Colors.white,
                  ),
                ),
                )
              ]
            ),
            Container(
              child  :SfCircularChart(
                title: ChartTitle(text: 
                'Top 5 Categorie Usate',
                textStyle: TextStyle(
                color: Colors.blueAccent, // Colore del testo
                fontSize: 20, // Dimensione del font
                fontWeight: FontWeight.bold, // Testo in grassetto
                fontFamily: 'Roboto', // Font personalizzato
                  ),
                ),
                legend: Legend(isVisible: true),
                series: <CircularSeries>[
                  PieSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                    explode: true, // Attiva l'effetto "explode"
                    explodeGesture: ActivationMode.singleTap, // Esplode quando viene toccato
                  )
                ]
              )
            ),
          ],
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
