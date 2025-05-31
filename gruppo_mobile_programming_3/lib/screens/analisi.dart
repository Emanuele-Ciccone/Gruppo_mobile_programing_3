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
      print(categorie);
    });
  }


    return Scaffold(
      appBar: AppBar(title: const Text('Analisi')),
      body: Center(
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
            Container(
              child  :SfCircularChart(
                title: ChartTitle(text: 
                'Top 5 Categorie Usate',
                textStyle: TextStyle(
                color: Colors.black, // Colore del testo
                fontSize: 16, // Dimensione del font
                fontWeight: FontWeight.bold, // Testo in grassetto // Font personalizzato
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
