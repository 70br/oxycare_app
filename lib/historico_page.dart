import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class HistoricoPage extends StatefulWidget {
  final int idPerfilSelecionado;
  final String nomePerfil;

  const HistoricoPage({
    required this.idPerfilSelecionado,
    required this.nomePerfil,
    Key? key,
  }) : super(key: key);

  @override
  _HistoricoPageState createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  List<FlSpot> pontosBatimento = [];
  List<String> datas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarHistorico();
  }

  Future<void> carregarHistorico() async {
    final url = Uri.parse(
        'http://silvaelias.ddns.net/oxycare/api/historico.php?paciente_id=${widget.idPerfilSelecionado}');

    try {
      final resposta = await http.get(url);
      final dados = jsonDecode(resposta.body);

      if (dados['status'] == 'ok') {
        final lista = dados['dados'];

        List<FlSpot> pontosTemp = [];
        List<String> datasTemp = [];

        for (int i = 0; i < lista.length; i++) {
          final item = lista[i];
          final batimentos = (item['batimentos'] as num).toDouble();
          final dataHora = DateTime.parse(item['data_hora']);
          final data =
              '${dataHora.day.toString().padLeft(2, '0')}/${dataHora.month.toString().padLeft(2, '0')}/${dataHora.year}';

          pontosTemp.add(FlSpot(i.toDouble(), batimentos));
          datasTemp.add(data);
        }

        setState(() {
          pontosBatimento = pontosTemp;
          datas = datasTemp;
          carregando = false;
        });
      } else {
        setState(() {
          carregando = false;
        });
      }
    } catch (e) {
      print('Erro: $e');
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> exportarCSV() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) return;

    final List<List<dynamic>> rows = [
      ['Data/Hora', 'Batimentos'],
      for (int i = 0; i < datas.length; i++)
        [datas[i], pontosBatimento[i].y.toStringAsFixed(2)],
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/historico_batimentos.csv';
    final file = File(path);

    await file.writeAsString(csvData);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('CSV exportado: $path')));
    await OpenFile.open(path);
  }

  Future<void> exportarPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Histórico de Batimentos',
                style: pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              data: [
                ['Data/Hora', 'Batimentos'],
                for (int i = 0; i < datas.length; i++)
                  [datas[i], pontosBatimento[i].y.toStringAsFixed(2)],
              ],
            ),
          ],
        ),
      ),
    );

    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/historico_batimentos.pdf';
    final file = File(path);

    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('PDF exportado: $path')));
    await OpenFile.open(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: carregando
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                Center(child: Image.asset('assets/logo_oxycare.png', height: 40)),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'Histórico de Batimentos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AspectRatio(
                    aspectRatio: 1.7,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            spots: pontosBatimento,
                            color: Colors.blue,
                            barWidth: 3,
                            belowBarData: BarAreaData(show: false),
                            dotData: FlDotData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                int idx = value.toInt();
                                if (idx < datas.length) {
                                  return Text(datas[idx],
                                      style: TextStyle(fontSize: 10));
                                }
                                return Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      botaoData('Início: ${datas.isNotEmpty ? datas.first : '-'}'),
                      SizedBox(height: 10),
                      botaoData('Fim: ${datas.isNotEmpty ? datas.last : '-'}'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: exportarCSV,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Exportar CSV',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: exportarPDF,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Exportar PDF',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text.rich(
                        TextSpan(
                          text: 'Perfil Selecionado: ',
                          children: [
                            TextSpan(
                              text: widget.nomePerfil,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/tempoReal');
          if (index == 1) Navigator.pushNamed(context, '/listar_perfis');
          if (index == 2) Navigator.pushNamed(context, '/conexao');
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.monitor_heart), label: 'Tempo Real'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Perfis'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bluetooth), label: 'Conexão'),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: 'Histórico'),
        ],
      ),
    );
  }

  Widget botaoData(String texto) {
    return Container(
      width: double.infinity,
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(texto),
    );
  }
}
