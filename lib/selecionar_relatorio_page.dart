import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:oxycare_app/utils.dart';

class SelecionarRelatorioPage extends StatefulWidget {
  const SelecionarRelatorioPage({super.key});

  @override
  State<SelecionarRelatorioPage> createState() => _SelecionarRelatorioPageState();
}

class _SelecionarRelatorioPageState extends State<SelecionarRelatorioPage> {
  String? pacienteSelecionado;
  DateTime? dataInicio;
  DateTime? dataFim;

  bool carregandoPacientes = true;
  bool carregandoPDF = false;

  List<dynamic> pacientes = [];

  Future<void> carregarPacientes() async {
    setState(() => carregandoPacientes = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    try {
      final url = Uri.parse("$urlGlobal/api/Pacientes");
      final resposta = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (resposta.statusCode == 200) {
        setState(() {
          pacientes = jsonDecode(resposta.body);
        });
      }
    } catch (e) {
      print("Erro ao carregar pacientes: $e");
    }

    setState(() => carregandoPacientes = false);
  }

  // 🔵 NOVO — Buscar medições ao selecionar paciente
  Future<void> carregarMedicoesDoPaciente(String pacienteId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    try {
      final url = Uri.parse("$urlGlobal/api/Medicoes/paciente/$pacienteId");
      final r = await http.get(url, headers: {"Authorization": "Bearer $token"});

      if (r.statusCode == 200) {
        final lista = jsonDecode(r.body) as List<dynamic>;

        if (lista.isNotEmpty) {
          lista.sort((a, b) => DateTime.parse(a["dataHora"])
              .compareTo(DateTime.parse(b["dataHora"])));

          setState(() {
            dataInicio = DateTime.parse(lista.first["dataHora"]);
            dataFim = DateTime.parse(lista.last["dataHora"]);
          });
        }
      }
    } catch (e) {
      print("Erro ao buscar medições: $e");
    }
  }

  Future<void> selecionarDataInicio() async {
    FocusScope.of(context).unfocus();

    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: DateTime(1900),
      lastDate: hoje,
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      setState(() => dataInicio = data);
    }
  }

  Future<void> selecionarDataFim() async {
    FocusScope.of(context).unfocus();

    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: DateTime(1900),
      lastDate: hoje,
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      setState(() => dataFim = data);
    }
  }

  // 🔵 NOVO — salvar e abrir PDF
  Future<void> salvarEAbrirPDF(List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/relatorio_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  Future<void> gerarRelatorio() async {
    if (pacienteSelecionado == null || dataInicio == null || dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos!")),
      );
      return;
    }

    setState(() => carregandoPDF = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    final url = Uri.parse("$urlGlobal/api/Relatorios/gerar-pdf");

    final body = {
      "pacienteId": pacienteSelecionado,
      "dataInicio": dataInicio!.toIso8601String().split("T").first,
      "dataFim": dataFim!.toIso8601String().split("T").first,
    };

    try {
      final resposta = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (resposta.statusCode == 200) {
        await salvarEAbrirPDF(resposta.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Relatório gerado com sucesso!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao gerar relatório.")),
        );
      }
    } catch (e) {
      print("Erro: $e");
    }

    setState(() => carregandoPDF = false);
  }

  @override
  void initState() {
    super.initState();
    carregarPacientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Gerar Relatório"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              Image.asset('assets/logo_cuidar.png', height: 120),
              const SizedBox(height: 12),
              const Text(
                'Cuidar+',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Seleção de Relatório',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 28),

              carregandoPacientes
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Selecione o Paciente",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: pacientes.map((p) {
                        return DropdownMenuItem(
                          value: p["id"].toString(),
                          child: Text(p["nome"]),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() => pacienteSelecionado = v.toString());
                        carregarMedicoesDoPaciente(v.toString()); // 🔵 NOVO
                      },
                    ),

              const SizedBox(height: 20),

              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Data Inicial",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: selecionarDataInicio,
                controller: TextEditingController(
                  text: dataInicio == null
                      ? ""
                      : "${dataInicio!.day}/${dataInicio!.month}/${dataInicio!.year}",
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Data Final",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: selecionarDataFim,
                controller: TextEditingController(
                  text: dataFim == null
                      ? ""
                      : "${dataFim!.day}/${dataFim!.month}/${dataFim!.year}",
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: carregandoPDF ? null : gerarRelatorio,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: carregandoPDF
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text(
                          "Gerar Relatório PDF",
                          style: TextStyle(fontSize: 16),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Divider(thickness: 1),
              const Text(
                "Conectado à API Cuidar+",
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
