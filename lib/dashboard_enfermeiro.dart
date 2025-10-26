import 'package:flutter/material.dart';
import 'tempo_real_page.dart';
import 'historico_page.dart';

class DashboardEnfermeiro extends StatelessWidget {
  const DashboardEnfermeiro({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String nome = 'Enfermeiro';
    String registro = '';

    if (args is Map<String, dynamic>) {
      nome = args['nome'] ?? 'Enfermeiro';
      registro = args['registro'] ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Área do Enfermeiro"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/logo_oxycare.png', height: 60),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    "Bem-vindo, $nome",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (registro.isNotEmpty)
                    Text(
                      "Registro: $registro",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/cadastrar_paciente_enfermeiro');
              },
              icon: const Icon(Icons.person_add),
              label: const Text("Cadastrar Novo Paciente + Gerar Código"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/gerar_codigo_cuidador');
              },
              icon: const Icon(Icons.qr_code),
              label: const Text("Gerar Código para Cuidador"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/visualizar_pacientes_cuidadores');
              },
              icon: const Icon(Icons.people),
              label: const Text("Visualizar Pacientes e Cuidadores"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, // Novo índice para dashboard
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TempoRealPage(
                  idPerfilSelecionado: 1,
                  nomePerfil: nome,
                  voltarParaDashboard: true, // parâmetro de retorno
                ),
              ),
            );
          } else if (index == 1) {
            Navigator.pushNamed(context, '/listar_perfis');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/conexao');
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoricoPage(
                  idPerfilSelecionado: 1,
                  nomePerfil: nome,
                ),
              ),
            );
          } else if (index == 4) {
            Navigator.pushReplacementNamed(
              context,
              '/dashboard_enfermeiro',
              arguments: {'nome': nome, 'registro': registro},
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Tempo Real'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfis'),
          BottomNavigationBarItem(icon: Icon(Icons.bluetooth), label: 'Conexão'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      ),
    );
  }
}
