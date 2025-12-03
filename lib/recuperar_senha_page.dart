import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'validar_codigo_page.dart';

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final emailController = TextEditingController();
  bool carregando = false;
  String? mensagem;

  Future<void> enviarEmail() async {
    setState(() {
      carregando = true;
      mensagem = null;
    });

    final url = Uri.parse('http://107.21.234.209:8080/api/Auth/forgot-password');

    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailController.text.trim()}),
      );

      if (resposta.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ValidarCodigoPage(email: emailController.text.trim()),
          ),
        );
      } else {
        setState(() {
          mensagem = 'Falha ao enviar o código. Verifique o e-mail.';
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
            mainAxisAlignment: MainAxisAlignment.center,
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
              const Text(
                'Digite o e-mail cadastrado para recuperar sua senha:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (mensagem != null)
                Text(
                  mensagem!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
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
                  onPressed: carregando ? null : enviarEmail,
                  child: carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enviar código', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
