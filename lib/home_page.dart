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

  // 🔥 Navbar ajustada
  void _navegarPara(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/listar_pacientes');
        break;
      case 2:
        Navigator.pushNamed(context, '/historico_medicoes');
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

      // 🔥 Navbar reduzida
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: _navegarPara,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Pacientes'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: 'Histórico'),
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
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
