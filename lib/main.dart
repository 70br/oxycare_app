import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Suas telas já existentes:
import 'login_page.dart';
import 'home_page.dart';
import 'cadastro_usuario_page.dart';
import 'cadastro_paciente_page.dart';
import 'listar_pacientes_page.dart';
import 'listar_usuarios_page.dart';
import 'registrar_medicao_page.dart';
import 'gerar_relatorio_page.dart';

// Nova tela de histórico
import 'historico_page.dart';

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
        '/cadastro_usuario': (context) => const CadastroUsuarioPage(),
        '/cadastro_paciente': (context) => const CadastroPacientePage(),
        '/listar_pacientes': (context) => const ListarPacientesPage(),
        '/listar_usuarios': (context) => const ListarUsuariosPage(),
        '/registrar_medicao': (context) => const RegistrarMedicaoPage(),

        // Sem argumentos aqui, porque agora usaremos onGenerateRoute para pegar os parâmetros
        '/gerar_relatorio': (context) => const GerarRelatorioPage(),
      },

      /// Rotas que precisam receber argumentos via pushNamed()
      onGenerateRoute: (settings) {
        if (settings.name == '/historico' || settings.name == '/historico_medicoes') {
          // ❌ Removido args que causava erro
          return MaterialPageRoute(
            builder: (_) => const HistoricoPage(), // ✅ chamada sem parâmetros
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
            onPressed: () => Navigator.pushNamed(context, '/listar_pacientes'),
            child: const Text('Listar Pacientes'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/listar_usuarios'),
            child: const Text('Listar Usuários'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/registrar_medicao'),
            child: const Text('Registrar Medição'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/gerar_relatorio'),
            child: const Text('Gerar Relatório'),
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
