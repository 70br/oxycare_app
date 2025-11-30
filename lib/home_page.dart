import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String nomeUsuario = '';
  bool _gerando = false;
  String? _mensagem;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nomeUsuario = prefs.getString('nomeUsuario') ?? 'Usuário';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _gerarRelatorioGeral() async {
    setState(() {
      _gerando = true;
      _mensagem = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        setState(() => _mensagem = "Token de autenticação não encontrado.");
        return;
      }

      // 👉 endpoint de geração de relatório geral
      final url = Uri.parse('http://107.21.234.209:8080/api/Relatorios/gerar-pdf');

      final resposta = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: '{"pacienteId": null, "dataInicio": "2020-01-01", "dataFim": "${DateTime.now().toIso8601String()}"}',
      );

      if (resposta.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/Relatorio_Geral_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(resposta.bodyBytes);
        await OpenFile.open(filePath);
        setState(() => _mensagem = "✅ Relatório geral gerado com sucesso!");
      } else {
        setState(() => _mensagem =
            "Erro ao gerar relatório geral (Código ${resposta.statusCode}).");
      }
    } catch (e) {
      setState(() => _mensagem = "Erro de conexão com o servidor.");
    }

    setState(() => _gerando = false);
  }

  void _navegarPara(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/listar_usuarios');
        break;
      case 2:
        Navigator.pushNamed(context, '/listar_pacientes');
        break;
      case 3:
        Navigator.pushNamed(context, '/historico_medicoes');
        break;
      case 4:
        Navigator.pushNamed(context, '/configuracoes');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuidar+ - Painel do Usuário'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/logo_cuidar.png', height: 80),
                    const SizedBox(height: 12),
                    Text(
                      'Bem-vindo, $nomeUsuario',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/listar_pacientes'),
                icon: const Icon(Icons.local_hospital),
                label: const Text('Gerenciar Pacientes'),
                style: _estiloBotao(Colors.teal),
              ),
              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/cadastro_paciente'),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Cadastrar Paciente'),
                style: _estiloBotao(Colors.green),
              ),
              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/registrar_medicao'),
                icon: const Icon(Icons.monitor_heart),
                label: const Text('Acompanhar Medição'),
                style: _estiloBotao(Colors.redAccent),
              ),
              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/historico_medicoes'),
                icon: const Icon(Icons.timeline),
                label: const Text('Histórico de Medições'),
                style: _estiloBotao(Colors.deepPurple),
              ),
              const SizedBox(height: 18),

              // 🔥 Botão ajustado — gera relatório geral direto
              ElevatedButton.icon(
                onPressed: _gerando ? null : _gerarRelatorioGeral,
                icon: const Icon(Icons.picture_as_pdf),
                label: _gerando
                    ? const Text("Gerando Relatório...")
                    : const Text('Gerar Relatório PDF'),
                style: _estiloBotao(Colors.orange),
              ),
              const SizedBox(height: 10),

              if (_mensagem != null)
                Center(
                  child: Text(
                    _mensagem!,
                    style: TextStyle(
                      color: _mensagem!.startsWith("✅")
                          ? Colors.green
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 30),
              const Divider(thickness: 1),
              const SizedBox(height: 8),
              const Text(
                'Cuidar+ API v1',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _navegarPara,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Usuários'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Pacientes'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Histórico'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
        ],
      ),
    );
  }

  ButtonStyle _estiloBotao(Color cor) {
    return ElevatedButton.styleFrom(
      backgroundColor: cor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
