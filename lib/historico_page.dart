import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oxycare_app/utils.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  Future<void> carregarHistorico() async {
    if (pacienteSelecionadoId == null) {
      setState(() => mensagem = "Selecione um paciente primeiro.");
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
      final url = Uri.parse(
          '$urlGlobal/api/Historicos/paciente/$pacienteSelecionadoId');

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
                'Consultar Histórico de Mediçõess',
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
                          Text("❤️ Frequência: ${m['frequenciaCardiaca']} bpm"),
                          Text("🫁 Saturação: ${m['saturacao']}%"),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
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
