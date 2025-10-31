import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ListarPacientesPage extends StatefulWidget {
  const ListarPacientesPage({super.key});

  @override
  State<ListarPacientesPage> createState() => _ListarPacientesPageState();
}

class _ListarPacientesPageState extends State<ListarPacientesPage> {
  List<dynamic> pacientes = [];
  bool carregando = true;
  String? mensagem;

  @override
  void initState() {
    super.initState();
    carregarPacientes();
  }

  Future<void> carregarPacientes() async {
    setState(() {
      carregando = true;
      mensagem = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('http://107.21.234.209:8080/api/Pacientes');

    try {
      final resposta = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resposta.statusCode == 200) {
        setState(() {
          pacientes = jsonDecode(resposta.body);
        });
      } else {
        setState(() {
          mensagem = "Erro ao carregar pacientes (${resposta.statusCode}).";
        });
      }
    } catch (e) {
      setState(() {
        mensagem = "Erro de conexão com o servidor.";
      });
    }

    setState(() => carregando = false);
  }

  void _abrirCadastro() {
    Navigator.pushNamed(context, '/cadastro_paciente')
        .then((_) => carregarPacientes());
  }

  void _abrirRelatorio(dynamic paciente) {
    Navigator.pushNamed(context, '/gerar_relatorio_pdf',
        arguments: {'pacienteId': paciente['id'], 'nome': paciente['nome']});
  }

  void _abrirMedicao(dynamic paciente) {
    Navigator.pushNamed(context, '/registrar_medicao',
        arguments: {'pacienteId': paciente['id'], 'nome': paciente['nome']});
  }

  Future<void> _excluirPaciente(dynamic paciente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Paciente"),
        content:
            Text("Deseja realmente excluir o paciente ${paciente['nome']}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Excluir", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final url = Uri.parse(
          'http://107.21.234.209:8080/api/Pacientes/${paciente['id']}');

      final resposta = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resposta.statusCode == 204) {
        setState(() {
          pacientes.removeWhere((p) => p['id'] == paciente['id']);
          mensagem = "✅ Paciente excluído com sucesso!";
        });
      } else {
        setState(() {
          mensagem = "Erro ao excluir paciente (${resposta.statusCode}).";
        });
      }
    } catch (e) {
      setState(() {
        mensagem = "Erro de conexão com o servidor.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Pacientes"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarPacientes,
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : mensagem != null
              ? Center(child: Text(mensagem!))
              : ListView.builder(
                  itemCount: pacientes.length,
                  itemBuilder: (context, index) {
                    final p = pacientes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.teal),
                        title: Text(p['nome']),
                        subtitle: Text("CPF: ${p['cpf']}"),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'relatorio') _abrirRelatorio(p);
                            if (value == 'medicao') _abrirMedicao(p);
                            if (value == 'excluir') _excluirPaciente(p);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'medicao',
                              child: Text('Registrar Medição'),
                            ),
                            const PopupMenuItem(
                              value: 'relatorio',
                              child: Text('Gerar Relatório PDF'),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'excluir',
                              child: Text(
                                'Excluir Paciente',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
