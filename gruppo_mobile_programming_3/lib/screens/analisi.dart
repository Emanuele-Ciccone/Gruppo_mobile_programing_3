import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/appData_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final int y;
}

class SettimanaSpesa {
  SettimanaSpesa(this.x, this.y);
  final String x;
  final double y;
}

class OggettiFrequenti {
  OggettiFrequenti(this.x, this.y);
  final String x;
  final int y;
}

class AnalisiPage extends StatefulWidget {
  const AnalisiPage({super.key});

  @override
  AnalisiStatePage createState() => AnalisiStatePage();
}

class AnalisiStatePage extends State<AnalisiPage> with WidgetsBindingObserver {
  late AppDataProvider _dataProvider;
  bool _isLoading = true;
  double _spesaTotale = 0.0;
  double _mediaSettimanale = 0.0;
  List<ChartData> _chartDataCategorie = [];
  List<SettimanaSpesa> _settimanaleSpesa = [];
  List<OggettiFrequenti> _oggettiFrequenti = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _dataProvider = Provider.of<AppDataProvider>(context, listen: false);
      await _caricaDatiAnalisi();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _caricaDatiAnalisi();
    }
  }

  Future<void> _caricaDatiAnalisi() async {
    if (!mounted) return; 
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _aggiornaSpesaTotale(),
        _aggiornaMediaSettimanale(),
        _aggiornaCategorie(),
        _aggiornaSpesaSettimanale(),
        _aggiornaOggettiFrequenti(),
      ]);
    } catch (e) {
      debugPrint('Errore nel caricamento dati: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _aggiornaSpesaTotale() async {
    if (!mounted) return;
    final spesa = await _dataProvider.getSpesaTotale();
    if (mounted) setState(() => _spesaTotale = spesa);
  }

  Future<void> _aggiornaMediaSettimanale() async {
    if (!mounted) return;
    final media = await _dataProvider.getMediaSettimanale();
    if (mounted) setState(() => _mediaSettimanale = media);
  }

  Future<void> _aggiornaCategorie() async {
    if (!mounted) return;
    final categorie = await _dataProvider.getCategorie();
    if (mounted) {
      setState(() {
        _chartDataCategorie = categorie
            .map((cat) => ChartData(
                  cat['Nome'] as String,
                  cat['Frequenza'] as int,
                ))
            .toList();
      });
    }
  }

  Future<void> _aggiornaSpesaSettimanale() async {
    if (!mounted) return;
    final settimane = await _dataProvider.getSpesa();
    if (mounted) {
      setState(() {
        _settimanaleSpesa = settimane
            .map((sett) => SettimanaSpesa(
                  sett['Settimana'] as String,
                  sett['SpesaSettimanale'] as double,
                ))
            .toList();
      });
    }
  }

  Future<void> _aggiornaOggettiFrequenti() async {
    if (!mounted) return;
    final oggetti = await _dataProvider.getOggFreq();
    if (mounted) {
      setState(() {
        _oggettiFrequenti = oggetti
            .map((ogg) => OggettiFrequenti(
                  ogg['Nome'] as String,        
                  (ogg['QuantitaTotale'] as int?) ?? 0,
                ))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Analisi delle Spese',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _caricaDatiAnalisi,
        child: _isLoading ? _buildLoadingWidget() : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Caricamento analisi...'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(), 
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRiepilogoSpese(),
          const SizedBox(height: 24),
          _buildGraficoCategorie(),
          const SizedBox(height: 24),
          _buildGraficoSpesaSettimanale(),
          const SizedBox(height: 24),
          _buildGraficoOggettiFrequenti(),
          const SizedBox(height: 16), 
        ],
      ),
    );
  }

  Widget _buildRiepilogoSpese() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riepilogo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard(
              'Spesa Totale\nMensile',
              '€${_spesaTotale.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              Colors.blue,
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(
              'Media\nSettimanale',
              '€${_mediaSettimanale.toStringAsFixed(2)}',
              Icons.trending_up,
              Colors.green,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoCategorie() {
    return _buildChartContainer(
      title: 'Top 5 Categorie Più Usate',
      child: SfCircularChart(
        legend: const Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        series: <CircularSeries>[
          PieSeries<ChartData, String>(
            dataSource: _chartDataCategorie,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            explode: true,
            explodeGesture: ActivationMode.singleTap,
            radius: '90%',
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoSpesaSettimanale() {
    return _buildChartContainer(
      title: 'Andamento Spese Settimanali',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 1.5,
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(
              title: AxisTitle(text: 'Settimane'),
              labelRotation: 45,
            ),
            primaryYAxis: const NumericAxis(
              title: AxisTitle(text: 'Spesa (€)'),
            ),
            series: <CartesianSeries>[
              LineSeries<SettimanaSpesa, String>(
                dataSource: _settimanaleSpesa,
                xValueMapper: (SettimanaSpesa val, _) => val.x,
                yValueMapper: (SettimanaSpesa val, _) => val.y,
                color: Colors.blue,
                width: 3,
                markerSettings: const MarkerSettings(
                  isVisible: true,
                  height: 6,
                  width: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraficoOggettiFrequenti() {
        final top3Oggetti = _oggettiFrequenti
        .where((item) => item.y > 0) 
        .toList()
      ..sort((a, b) => b.y.compareTo(a.y)) 
      ..take(3).toList(); 
    if (top3Oggetti.isEmpty) {
      return _buildChartContainer(
        title: '3 Oggetti Più Comprati',
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Text(
              'Nessun dato disponibile',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

return _buildChartContainer(
  title: '3 Oggetti Più Comprati',
  child: SizedBox(
    height: 350,
    child: SfPyramidChart(
      title: ChartTitle(
        text: 'Quantità acquistate',
        textStyle: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(fontSize: 12),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${top3Oggetti[pointIndex].x}: ${top3Oggetti[pointIndex].y} volte',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        },
      ),
      series: PyramidSeries<OggettiFrequenti, String>(
        dataSource: top3Oggetti.asMap().entries.map((entry) => OggettiFrequenti(
          entry.value.x,
         100, 
        )).toList(),
        xValueMapper: (OggettiFrequenti data, _) => data.x,
        yValueMapper: (OggettiFrequenti data, _) => data.y, 
        textFieldMapper: (OggettiFrequenti data, int index) => 
          '${top3Oggetti[index].x}\n${top3Oggetti[index].y}x',
        pointColorMapper: (OggettiFrequenti data, int index) {         
          const colors = [
            Color(0xFF4CAF50), 
            Color(0xFF2196F3), 
            Color(0xFFFF9800),
          ];
          return colors[index % colors.length];
        },
        gapRatio: 0.05, 
        explode: false,
        pyramidMode: PyramidMode.surface,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.inside,
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13, 
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0,
                color: Colors.black45,
              ),
            ],
          ),
          
        ),
        borderColor: Colors.white,
        borderWidth: 2,
      ),
    ),
  ),
);
  }

  Widget _buildChartContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}