import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class GerarRelatorioPage extends StatefulWidget {
  const GerarRelatorioPage({super.key});

  @override
  State<GerarRelatorioPage> createState() => _GerarRelatorioPageState();
}

class _GerarRelatorioPageState extends State<GerarRelatorioPage> {
  final _formKey = GlobalKey<FormState>();
  List<dynamic> pacientes = [];
  dynamic pacienteSelecionado;
  DateTime? dataInicio;
  DateTime? dataFim;
  bool carregando = false;
  String? mensagem;

  @override
  void initState() {
    super.initState();
    carregarPacientes();
  }

  Future<void> carregarPacientes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) return;

      final url = Uri.parse('http://107.21.234.209:8080/api/Pacientes');
      final resposta = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (resposta.statusCode == 200) {
        final lista = jsonDecode(resposta.body);
        setState(() => pacientes = lista);
      } else {
        setState(() => mensagem = "Erro ao carregar pacientes.");
      }
    } catch (e) {
      setState(() => mensagem = "Erro de conexão com o servidor.");
    }
  }

  Future<void> selecionarData({required bool inicio}) async {
    final hoje = DateTime.now();
    final primeiraData = DateTime(2020);

    final selecionada = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: primeiraData,
      lastDate: hoje,
      locale: const Locale('pt', 'BR'),
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

  Future<void> gerarRelatorio() async {
    if (pacienteSelecionado == null ||
        dataInicio == null ||
        dataFim == null) {
      setState(() => mensagem = "Preencha todos os campos corretamente.");
      return;
    }

    setState(() {
      carregando = true;
      mensagem = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final pacienteId = pacienteSelecionado['id'];
    final dataInicioStr = DateFormat("yyyy-MM-ddTHH:mm:ss").format(dataInicio!);
    final dataFimStr = DateFormat("yyyy-MM-ddTHH:mm:ss").format(dataFim!);

    final url = Uri.parse(
        'http://107.21.234.209:8080/api/Relatorios/paciente/$pacienteId/gerar-pdf?dataInicio=$dataInicioStr&dataFim=$dataFimStr');

    try {
      final resposta = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resposta.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/Relatorio_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(resposta.bodyBytes);

        await OpenFile.open(filePath);
        setState(() => mensagem = "✅ Relatório gerado com sucesso!");
      } else {
        setState(() => mensagem =
            "Erro ao gerar relatório (Código ${resposta.statusCode}).");
      }
    } catch (e) {
      setState(() => mensagem = "Erro de conexão com o servidor.");
    }

    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerar Relatório PDF"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/logo_cuidar.png', height: 120),
                const SizedBox(height: 12),
                const Text(
                  "Cuidar+",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Gerar Relatório de Paciente",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 28),

                // Dropdown de pacientes
                pacientes.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : DropdownButtonFormField<dynamic>(
                        value: pacienteSelecionado,
                        items: pacientes.map((paciente) {
                          return DropdownMenuItem(
                            value: paciente,
                            child: Text(paciente['nome'] ?? 'Sem nome'),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => pacienteSelecionado = value),
                        decoration: InputDecoration(
                          labelText: "Selecione o Paciente",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (_) => pacienteSelecionado == null
                            ? "Selecione um paciente"
                            : null,
                      ),
                const SizedBox(height: 16),

                // Data Início
                InkWell(
                  onTap: () => selecionarData(inicio: true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Data Inicial",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      dataInicio == null
                          ? "Selecionar data"
                          : DateFormat("dd/MM/yyyy").format(dataInicio!),
                      style: TextStyle(
                        color:
                            dataInicio == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Data Fim
                InkWell(
                  onTap: () => selecionarData(inicio: false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Data Final",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      dataFim == null
                          ? "Selecionar data"
                          : DateFormat("dd/MM/yyyy").format(dataFim!),
                      style: TextStyle(
                        color: dataFim == null ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (mensagem != null)
                  Text(
                    mensagem!,
                    style: TextStyle(
                      color: mensagem!.startsWith("✅")
                          ? Colors.green
                          : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: carregando ? null : gerarRelatorio,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: carregando
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text("Gerar Relatório PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                const Divider(thickness: 1),
                const Text(
                  "Conectado à API Cuidar+",
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
