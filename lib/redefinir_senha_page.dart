import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class RedefinirSenhaPage extends StatefulWidget {
  final String email;
  final String codigo;
  const RedefinirSenhaPage({super.key, required this.email, required this.codigo});

  @override
  State<RedefinirSenhaPage> createState() => _RedefinirSenhaPageState();
}

class _RedefinirSenhaPageState extends State<RedefinirSenhaPage> {
  final senhaController = TextEditingController();
  bool carregando = false;
  String? mensagem;

  Future<void> redefinirSenha() async {
    setState(() {
      carregando = true;
      mensagem = null;
    });

    final url = Uri.parse('http://107.21.234.209:8080/api/Auth/reset-password');

    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'codigo': widget.codigo,
          'novaSenha': senhaController.text.trim(),
        }),
      );

      if (resposta.statusCode == 200) {
        setState(() {
          mensagem = 'Senha redefinida com sucesso!';
        });

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
          );
        });
      } else {
        setState(() {
          mensagem = 'Falha ao redefinir senha.';
        });
      }
    } catch (e) {
      setState(() {
        mensagem = 'Erro de conexão com o servidor.';
      });
    }

    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 12),
              const Text(
                'Cuidar+',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 32),
              const Text('Digite sua nova senha abaixo:'),
              const SizedBox(height: 20),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nova senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (mensagem != null)
                Text(mensagem!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: carregando ? null : redefinirSenha,
                  child: carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Redefinir senha', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
