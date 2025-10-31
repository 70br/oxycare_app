import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  String? pacienteSelecionadoId;
  List<Map<String, String>> pacientes = [];
  Map<String, dynamic>? historico;
  bool carregandoPacientes = true;
  bool carregando = false;
  String? mensagem;

  @override
  void initState() {
    super.initState();
    carregarPacientes();
  }

  /// 🔹 Carrega lista de pacientes
  Future<void> carregarPacientes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final url = Uri.parse('http://107.21.234.209:8080/api/Pacientes');

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

  /// 🔹 Busca histórico do paciente selecionado
  Future<void> carregarHistorico() async {
    if (pacienteSelecionadoId == null) {
      setState(() => mensagem = "Selecione um paciente primeiro.");
      return;
    }

    setState(() {
      carregando = true;
      mensagem = null;
      historico = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final url = Uri.parse(
          'http://107.21.234.209:8080/api/Historicos/paciente/$pacienteSelecionadoId');

      final resposta = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resposta.statusCode == 200) {
        setState(() {
          historico = jsonDecode(resposta.body);
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

  /// 🔹 Deletar histórico do paciente
  Future<void> deletarHistorico() async {
    if (pacienteSelecionadoId == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Histórico"),
        content: const Text("Deseja realmente excluir este histórico?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Excluir",
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final url = Uri.parse(
          'http://107.21.234.209:8080/api/Historicos/paciente/$pacienteSelecionadoId');

      final resposta = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resposta.statusCode == 204) {
        setState(() {
          historico = null;
          mensagem = "✅ Histórico excluído com sucesso!";
        });
      } else {
        setState(() =>
            mensagem = "Erro ao excluir (${resposta.statusCode}).");
      }
    } catch (e) {
      setState(() => mensagem = "Erro ao conectar ao servidor.");
    }
  }

  /// 🔹 Criar histórico (teste manual)
  Future<void> criarHistoricoTeste() async {
    if (pacienteSelecionadoId == null) {
      setState(() => mensagem = "Selecione um paciente primeiro.");
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final url = Uri.parse('http://107.21.234.209:8080/api/Historicos');

      final body = jsonEncode({
        "pacienteId": pacienteSelecionadoId,
        "dataInicio": DateTime.now().toIso8601String(),
        "dataFim": DateTime.now().toIso8601String(),
      });

      final resposta = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (resposta.statusCode == 201) {
        setState(() {
          mensagem = "✅ Histórico criado com sucesso!";
        });
      } else {
        setState(() {
          mensagem =
              "Erro ao criar histórico (${resposta.statusCode}): ${resposta.body}";
        });
      }
    } catch (e) {
      setState(() {
        mensagem = "Erro de conexão com o servidor.";
      });
    }
  }

  ButtonStyle estiloBotao(Color cor) {
    return ElevatedButton.styleFrom(
      backgroundColor: cor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              Image.asset('assets/logo_cuidar.png', height: 120),
              const SizedBox(height: 12),
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
              const SizedBox(height: 24),

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
                      validator: (v) =>
                          v == null ? "Selecione um paciente" : null,
                    ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: carregando ? null : carregarHistorico,
                icon: const Icon(Icons.search),
                label: carregando
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : const Text("Buscar Histórico"),
                style: estiloBotao(Colors.blueAccent),
              ),

              const SizedBox(height: 24),

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

              if (historico != null) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("🩺 ID: ${historico!['id']}"),
                        Text("📅 Início: ${historico!['dataInicio']}"),
                        Text("📅 Fim: ${historico!['dataFim']}"),
                        Text("🕒 Criado em: ${historico!['criadoEm']}"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: deletarHistorico,
                  icon: const Icon(Icons.delete),
                  label: const Text("Excluir Histórico"),
                  style: estiloBotao(Colors.redAccent),
                ),
              ],

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: criarHistoricoTeste,
                icon: const Icon(Icons.add),
                label: const Text("Criar Histórico (teste)"),
                style: estiloBotao(Colors.green),
              ),

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
