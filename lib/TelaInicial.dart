import 'package:flutter/material.dart';

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map argumentos = ModalRoute.of(context)!.settings.arguments as Map;
    final String tipo = argumentos['tipo'] ?? 'paciente';
    final String nome = argumentos['nome'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, $nome'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text(
              'Escolha uma funcionalidade:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/monitoramento'),
              child: Text('Monitoramento'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/historico'),
              child: Text('Histórico de Sinais Vitais'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/listar_perfis'),
              child: Text('Listar Perfis'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/adicionar_perfil'),
              child: Text('Adicionar Perfil'),
            ),
            if (tipo == 'admin' || tipo == 'enfermeiro') ...[
              Divider(),
              Text(
                'Funcionalidades para enfermagem:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/visualizar_pacientes'),
                child: Text('Visualizar Pacientes'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/adicionar_paciente'),
                child: Text('Adicionar Paciente'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// ---------------- MONITORAMENTO TEMPORÁRIO ----------------
class MonitoramentoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monitoramento')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_heart, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text('Página de monitoramento em construção.',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- HISTÓRICO TEMPORÁRIO ----------------
class HistoricoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Histórico de Sinais Vitais')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text('Página de histórico em construção.',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- LISTAR PERFIS TEMPORÁRIO ----------------
class ListarPerfisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Listar Perfis')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text('Página de listagem de perfis em construção.',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- ADICIONAR PERFIL TEMPORÁRIO ----------------
class AdicionarPerfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text('Página de adição de perfil em construção.',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- VISUALIZAR PACIENTES TEMPORÁRIO ----------------
class VisualizarPacientesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Visualizar Pacientes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text('Página de visualização de pacientes em construção.',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- ADICIONAR PACIENTE TEMPORÁRIO ----------------
class AdicionarPacientePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Paciente')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_alt, size: 80, color: Colors.teal),
            SizedBox(height: 20),
            Text('Página de adição de paciente em construção.',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
