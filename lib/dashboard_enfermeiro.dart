import 'package:flutter/material.dart';

class DashboardEnfermeiro extends StatelessWidget {
  const DashboardEnfermeiro({super.key});

  void _verPacientes(BuildContext context) {
    // Aqui você pode navegar para a tela de pacientes (crie depois)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Função ainda não implementada.")),
    );
  }

  void _sair(BuildContext context) {
    // Volta para a tela de login ou tipo de seleção
    Navigator.pushNamedAndRemoveUntil(context, '/tela_selecao_tipo', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bem-vindo(a), Enfermeiro(a)!")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo_oxycare.png', height: 60),
            const SizedBox(height: 40),
            const Text(
              "Cadastro realizado com sucesso!",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              onPressed: () => _verPacientes(context),
              child: const Text(
                "Ver Pacientes",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _sair(context),
              child: const Text("Sair"),
            ),
          ],
        ),
      ),
    );
  }
}
