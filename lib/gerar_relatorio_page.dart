import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:oxycare_app/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class GerarRelatorioPage extends StatefulWidget {
  final String? pacienteId; // ✅ agora opcional (para gerar geral)
  const GerarRelatorioPage({super.key, this.pacienteId});

  @override
  State<GerarRelatorioPage> createState() => _GerarRelatorioPageState();
}

class _GerarRelatorioPageState extends State<GerarRelatorioPage> {
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
    if (widget.pacienteId != null) return; // ✅ não precisa listar se for individual
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) return;

      final url = Uri.parse('$urlGlobal/api/Pacientes');
      final resposta = await http.get(url, headers: {'Authorization': 'Bearer $token'});

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

  Future<void> gerarRelatorio() async {
    setState(() {
      carregando = true;
      mensagem = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final pacienteId = widget.pacienteId ?? pacienteSelecionado?['id'];

    if (pacienteId == null) {
      setState(() {
        mensagem = "Selecione um paciente para gerar o relatório.";
        carregando = false;
      });
      return;
    }

    // ✅ Define intervalo padrão caso o usuário não escolha datas
    final inicio = dataInicio ?? DateTime(2024, 1, 1);
    final fim = dataFim ?? DateTime.now();

    final body = jsonEncode({
      "pacienteId": pacienteId,
      "dataInicio": DateFormat("yyyy-MM-dd").format(inicio),
      "dataFim": DateFormat("yyyy-MM-dd").format(fim),
    });

    final url = Uri.parse('$urlGlobal/api/Relatorios/gerar-pdf');

    try {
      final resposta = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
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
        setState(() =>
            mensagem = "Erro ao gerar relatório (Código ${resposta.statusCode}).");
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

              if (widget.pacienteId == null)
                (pacientes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
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
                      )),
              const SizedBox(height: 24),

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
              const SizedBox(height: 20),

              if (mensagem != null)
                Text(
                  mensagem!,
                  style: TextStyle(
                    color: mensagem!.startsWith("✅") ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
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
    );
  }
}
