import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroEnfermeiro extends StatefulWidget {
  const CadastroEnfermeiro({super.key});

  @override
  State<CadastroEnfermeiro> createState() => _CadastroEnfermeiroState();
}

class _CadastroEnfermeiroState extends State<CadastroEnfermeiro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _registroController = TextEditingController(); // CRM ou Coren

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _registroController.dispose();
    super.dispose();
  }

  void _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/cadastrar_enfermeiro.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': _nomeController.text,
          'email': _emailController.text,
          'senha': _senhaController.text,
          'registro': _registroController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'sucesso') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mensagem'])),
        );
        Navigator.pushNamed(context, '/dashboard_enfermeiro');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mensagem'] ?? 'Erro desconhecido')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro Enfermeiro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset(
              'assets/logo_oxycare.png',
              height: 40,
            ),
            const SizedBox(height: 40),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: "Nome completo",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Informe o e-mail' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Senha",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmarSenhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Confirmar Senha",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value != _senhaController.text
                        ? 'Senhas não coincidem'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _registroController,
                    decoration: const InputDecoration(
                      labelText: "CRM ou Coren",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Informe o número do registro' : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 16),
                    ),
                    onPressed: _cadastrar,
                    child: const Text(
                      "Cadastrar",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
