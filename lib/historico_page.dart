import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oxycare_app/utils.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  String? pacienteSelecionadoId;
  List<Map<String, String>> pacientes = [];
  List<dynamic> medicoes = [];
  bool carregandoPacientes = true;
  bool carregando = false;
  String? mensagem;

  // ✅ ADICIONADO (sem impactar nada)
  DateTime? dataInicio;
  DateTime? dataFim;

  @override
  void initState() {
    super.initState();
    carregarPacientes();
  }

  Future<void> carregarPacientes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final url = Uri.parse('$urlGlobal/api/Pacientes');

      final resposta = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resposta.statusCode == 200) {
        final List lista = jsonDecode(resposta.body);
        setState(() {
          pacientes = lista
              .map((p) => {
                    'id': p['id'].toString(),
                    'nome': p['nome'].toString(),
                  })
              .toList();
        });
      } else {
        setState(() => mensagem = "Erro ao carregar pacientes.");
      }
    } catch (e) {
      setState(() => mensagem = "Falha ao conectar ao servidor.");
    } finally {
      setState(() => carregandoPacientes = false);
    }
  }

  // ✅ DatePicker simples e nativo
  Future<void> escolherData(bool inicio) async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selecionada != null) {
      setState(() {
        if (inicio) {
          dataInicio = selecionada;
        } else {
          dataFim = selecionada;
        }
      });
    }
  }

  Future<void> carregarHistorico() async {
    if (pacienteSelecionadoId == null) {
      setState(() => mensagem = "Selecione um paciente primeiro.");
      return;
    }

    if (dataInicio != null &&
        dataFim != null &&
        dataInicio!.isAfter(dataFim!)) {
      setState(() => mensagem = "A data inicial deve ser antes da data final.");
      return;
    }

    setState(() {
      carregando = true;
      mensagem = null;
      medicoes = [];
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      Uri url;

      // ✅ AQUI ESTÁ O FILTRO POR PERÍODO
      if (dataInicio != null && dataFim != null) {
        final inicioIso = dataInicio!.toUtc().toIso8601String();
        final fimIso = dataFim!.toUtc().toIso8601String();

        url = Uri.parse(
          '$urlGlobal/api/Historicos/paciente/$pacienteSelecionadoId/periodo'
          '?dataInicio=$inicioIso&dataFim=$fimIso',
        );
      } else {
        url = Uri.parse(
          '$urlGlobal/api/Historicos/paciente/$pacienteSelecionadoId',
        );
      }

      final resposta = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resposta.statusCode == 200) {
        final data = jsonDecode(resposta.body);
        setState(() {
          medicoes = data['medicoes'] ?? [];
          if (medicoes.isEmpty) mensagem = "Nenhuma medição encontrada.";
        });
      } else if (resposta.statusCode == 404) {
        setState(() => mensagem = "Nenhum histórico encontrado.");
      } else {
        setState(() =>
            mensagem = "Erro ao carregar histórico (${resposta.statusCode}).");
      }
    } catch (e) {
      setState(() => mensagem = "Erro de conexão com o servidor.");
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<void> deletarMedicao(String idMedicao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Medição"),
        content: const Text("Deseja realmente excluir esta medição?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text("Excluir", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final url = Uri.parse('$urlGlobal/api/Medicoes/$idMedicao');

      final resposta = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resposta.statusCode == 204) {
        setState(() {
          medicoes.removeWhere((m) => m['id'] == idMedicao);
          mensagem = "✅ Medição excluída com sucesso!";
        });
      } else {
        setState(() =>
            mensagem = "Erro ao excluir medição (${resposta.statusCode}).");
      }
    } catch (e) {
      setState(() => mensagem = "Erro ao conectar ao servidor.");
    }
  }

  String formatarData(String dataIso) {
    try {
      final data = DateTime.parse(dataIso);
      return DateFormat('dd/MM/yyyy HH:mm').format(data);
    } catch (_) {
      return dataIso;
    }
  }

  ButtonStyle estiloBotao(Color cor) {
    return ElevatedButton.styleFrom(
      backgroundColor: cor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<_MedicaoData> dadosGrafico = medicoes.map((m) {
      final data = DateTime.tryParse(m['dataHora'] ?? '') ?? DateTime.now();
      return _MedicaoData(
        data,
        (m['temperatura'] ?? 0).toDouble(),
        (m['frequenciaCardiaca'] ?? 0).toDouble(),
        (m['saturacao'] ?? 0).toDouble(),
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Histórico de Paciente"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/logo_cuidar.png', height: 100),
              const SizedBox(height: 8),
              const Text(
                'Cuidar+',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Consultar Histórico de Medições',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              carregandoPacientes
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Colors.blueAccent))
                  : DropdownButtonFormField<String>(
                      value: pacienteSelecionadoId,
                      decoration: InputDecoration(
                        labelText: "Selecione o Paciente",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: pacientes
                          .map((p) => DropdownMenuItem(
                                value: p['id'],
                                child: Text(p['nome']!),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => pacienteSelecionadoId = value),
                    ),

              const SizedBox(height: 12),

              // ✅ CAMPOS DE DATA (compactos e bonitos)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(dataInicio == null
                          ? "Data inicial"
                          : DateFormat('dd/MM/yyyy').format(dataInicio!)),
                      onPressed: () => escolherData(true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(dataFim == null
                          ? "Data final"
                          : DateFormat('dd/MM/yyyy').format(dataFim!)),
                      onPressed: () => escolherData(false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: carregando ? null : carregarHistorico,
                icon: const Icon(Icons.search),
                label: carregando
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : const Text("Buscar Histórico"),
                style: estiloBotao(Colors.blueAccent),
              ),

              const SizedBox(height: 20),

              if (mensagem != null)
                Text(
                  mensagem!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mensagem!.startsWith("✅")
                        ? Colors.green
                        : Colors.red,
                    fontSize: 16,
                  ),
                ),

              if (dadosGrafico.isNotEmpty)
                SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(),
                    legend: Legend(isVisible: true),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<_MedicaoData, DateTime>>[
                      LineSeries<_MedicaoData, DateTime>(
                        dataSource: dadosGrafico,
                        xValueMapper: (m, _) => m.data,
                        yValueMapper: (m, _) => m.temperatura,
                        name: 'Temperatura (°C)',
                        color: Colors.red,
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                      LineSeries<_MedicaoData, DateTime>(
                        dataSource: dadosGrafico,
                        xValueMapper: (m, _) => m.data,
                        yValueMapper: (m, _) => m.frequencia,
                        name: 'Frequência (bpm)',
                        color: Colors.blue,
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                      LineSeries<_MedicaoData, DateTime>(
                        dataSource: dadosGrafico,
                        xValueMapper: (m, _) => m.data,
                        yValueMapper: (m, _) => m.saturacao,
                        name: 'Saturação (%)',
                        color: Colors.green,
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              if (medicoes.isNotEmpty)
                ...medicoes.map((m) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "📅 ${formatarData(m['dataHora'] ?? '')}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          Text("🌡️ Temperatura: ${m['temperatura']} °C"),
                          Text(
                              "❤️ Frequência: ${m['frequenciaCardiaca']} bpm"),
                          Text("🫁 Saturação: ${m['saturacao']}%"),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              tooltip: "Excluir Medição",
                              onPressed: () => deletarMedicao(m['id']),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 30),
              const Divider(thickness: 1),
              const Text(
                'Conectado à API Cuidar+ (AWS)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicaoData {
  final DateTime data;
  final double temperatura;
  final double frequencia;
  final double saturacao;

  _MedicaoData(this.data, this.temperatura, this.frequencia, this.saturacao);
}
