import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'cadastro_page.dart';
import 'sucesso_page.dart';
import 'recuperar_senha_page.dart';
import 'listar_perfis_page.dart';
import 'adicionar_perfil_page.dart';
import 'historico_page.dart';
import 'conexao_page.dart';
import 'tempo_real_page.dart';
import 'tela_selecao_tipo.dart';
import 'tela_codigo_acesso.dart';
void main() => runApp(OxyCareApp());

class OxyCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OxyCare',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => TelaInicial(),
        '/envio': (context) => EnvioDadosPage(),
        '/cadastro': (context) => CadastroPage(),
        '/sucesso': (context) => SucessoPage(),
        '/monitoramento': (context) => MonitoramentoPage(),
        '/historico': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return HistoricoPage(
            idPerfilSelecionado: args['idPerfilSelecionado'],
            nomePerfil: args['nomePerfil'],
          );
        },
        '/listar_perfis': (context) => ListarPerfisPage(),
        '/adicionar_perfil': (context) => AdicionarPerfilPage(),
        '/visualizar_pacientes': (context) => VisualizarPacientesPage(),
        '/adicionar_paciente': (context) => AdicionarPacientePage(),
        '/recuperar_senha': (context) => RecuperarSenhaPage(),
        '/conexao': (context) => ConexaoPage(),
  //      '/tempoReal': (context) => TempoRealPage(),
        '/selecao_tipo': (context) => const TelaSelecaoTipo(),
        '/codigo_acesso': (context) => const TelaCodigoAcesso(),
      },
    );
  }
}

// ------------------------ TELA INICIAL ------------------------

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tela Inicial')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/envio'),
            child: Text('Monitoramento'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final id = prefs.getInt('idPerfilSelecionado');
              final nome = prefs.getString('nomePerfil');

              if (id != null && nome != null) {
                Navigator.pushNamed(
                  context,
                  '/historico',
                  arguments: {
                    'idPerfilSelecionado': id,
                    'nomePerfil': nome,
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selecione um perfil primeiro.')),
                );
              }
            },
            child: Text('Histórico de Sinais'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/listar_perfis'),
            child: Text('Listar Perfis'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/adicionar_perfil'),
            child: Text('Adicionar Perfil'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/visualizar_pacientes'),
            child: Text('Visualizar Pacientes'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/adicionar_paciente'),
            child: Text('Adicionar Paciente'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/conexao'),
            child: Text('Conexão'),
          ),
        ],
      ),
    );
  }
}

// ------------------------ ENVIO DE DADOS ------------------------

class EnvioDadosPage extends StatefulWidget {
  @override
  _EnvioDadosPageState createState() => _EnvioDadosPageState();
}

class _EnvioDadosPageState extends State<EnvioDadosPage> {
  final TextEditingController batimentosController = TextEditingController();
  final TextEditingController spo2Controller = TextEditingController();
  final TextEditingController temperaturaController = TextEditingController();

  Future<void> enviarDados() async {
    final uri = Uri.parse('http://silvaelias.ddns.net/oxycare/api/receber_dados.php');
    final dados = {
      "paciente_id": 1,
      "batimentos": int.tryParse(batimentosController.text) ?? 0,
      "spo2": int.tryParse(spo2Controller.text) ?? 0,
      "temperatura": double.tryParse(temperaturaController.text) ?? 0.0,
    };

    try {
      final resposta = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dados),
      );

      if (resposta.statusCode == 200) {
        final respostaJson = jsonDecode(resposta.body);
        if (respostaJson['status'] == 'ok') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dados enviados com sucesso!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao enviar: ${respostaJson['mensagem']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão (${resposta.statusCode})')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar com o servidor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Envio de Sinais Vitais")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: batimentosController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Batimentos (bpm)'),
            ),
            TextField(
              controller: spo2Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'SpO₂ (%)'),
            ),
            TextField(
              controller: temperaturaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Temperatura (°C)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: enviarDados,
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------ TELAS TEMPORÁRIAS ------------------------

class MonitoramentoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monitoramento')),
      body: Center(child: Text('Tela Monitoramento em construção')),
    );
  }
}

class VisualizarPacientesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visualizar Pacientes')),
      body: Center(child: Text('Tela Visualizar Pacientes em construção')),
    );
  }
}

class AdicionarPacientePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Paciente')),
      body: Center(child: Text('Tela Adicionar Paciente em construção')),
    );
  }
}
