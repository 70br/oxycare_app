import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ Adicionado
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'recuperar_senha_page.dart';
import 'tela_selecao_tipo.dart';
import 'tempo_real_page.dart';
import 'historico_page.dart';
import 'listar_perfis_page.dart';
import 'adicionar_perfil_page.dart';
import 'cadastro_page.dart';
import 'sucesso_page.dart';
import 'conexao_page.dart';
import 'cadastro_enfermeiro.dart';
import 'cadastro_cuidador.dart';
import 'dashboard_enfermeiro.dart';
import 'cadastrar_paciente_enfermeiro.dart';
import 'gerar_codigo_cuidador.dart';
import 'visualizar_pacientes_cuidadores.dart';
import 'tela_codigo_acesso.dart';
import 'cadastro_usuario_page.dart';
import 'listar_usuarios_page.dart';
import 'home_page.dart';
import 'cadastro_paciente_page.dart';

void main() => runApp(const CuidarApp());

class CuidarApp extends StatelessWidget {
  const CuidarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuidar+',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      // ✅ Adicionando suporte a localização (corrige o bug da tela branca)
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/cadastro': (context) => CadastroPage(),
        '/cadastro_usuario': (context) => const CadastroUsuarioPage(),
        '/sucesso': (context) => SucessoPage(),
        '/recuperar_senha': (context) => RecuperarSenhaPage(),
        '/selecao_tipo': (context) => const TelaSelecaoTipo(),
        '/codigo_acesso': (context) => const TelaCodigoAcesso(),
        '/listar_perfis': (context) => ListarPerfisPage(),
        '/adicionar_perfil': (context) => AdicionarPerfilPage(),
        '/conexao': (context) => ConexaoPage(),
        '/cadastro_paciente': (context) => const CadastroPacientePage(),
        '/cadastro_enfermeiro': (context) => const CadastroEnfermeiro(),
        '/dashboard_enfermeiro': (context) => const DashboardEnfermeiro(),
        '/cadastrar_paciente_enfermeiro': (context) =>
            CadastrarPacienteEnfermeiroPage(),
        '/gerar_codigo_cuidador': (context) => GerarCodigoCuidadorPage(),
        '/visualizar_pacientes_cuidadores': (context) =>
            VisualizarPacientesCuidadoresPage(),
        '/listar_usuarios': (context) => const ListarUsuariosPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/tempoReal') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null &&
              args.containsKey('idPerfilSelecionado') &&
              args.containsKey('nomePerfil')) {
            return MaterialPageRoute(
              builder: (context) => TempoRealPage(
                idPerfilSelecionado: args['idPerfilSelecionado'],
                nomePerfil: args['nomePerfil'],
              ),
            );
          } else {
            return MaterialPageRoute(builder: (context) => ListarPerfisPage());
          }
        }

        if (settings.name == '/historico') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => HistoricoPage(
              idPerfilSelecionado: args['idPerfilSelecionado'],
              nomePerfil: args['nomePerfil'],
            ),
          );
        }

        if (settings.name == '/cadastro_cuidador') {
          final pacienteId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => CadastroCuidadorPage(pacienteId: pacienteId),
          );
        }

        return null;
      },
    );
  }
}

// ------------------------ TELA INICIAL ------------------------

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('refreshToken');

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    final url = Uri.parse('http://107.21.234.209:8080/api/Auth/logout');

    try {
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': token}),
      );
    } catch (_) {}

    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuidar+ - Início'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/tempoReal'),
            child: const Text('Monitoramento em Tempo Real'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/listar_perfis'),
            child: const Text('Listar Perfis'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/historico'),
            child: const Text('Histórico de Sinais'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/adicionar_perfil'),
            child: const Text('Adicionar Perfil'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(
                context, '/visualizar_pacientes_cuidadores'),
            child: const Text('Pacientes e Cuidadores'),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const Text(
            'Sistema de Monitoramento de Saúde - Cuidar+',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
