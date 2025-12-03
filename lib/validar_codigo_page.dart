import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'redefinir_senha_page.dart';

class ValidarCodigoPage extends StatefulWidget {
  final String email;
  const ValidarCodigoPage({super.key, required this.email});

  @override
  State<ValidarCodigoPage> createState() => _ValidarCodigoPageState();
}

class _ValidarCodigoPageState extends State<ValidarCodigoPage> {
  final codigoController = TextEditingController();
  bool carregando = false;
  String? mensagem;

  Future<void> validarCodigo() async {
    setState(() {
      carregando = true;
      mensagem = null;
    });

    final url = Uri.parse('http://107.21.234.209:8080/api/Auth/validate-code');

    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'codigo': codigoController.text.trim(),
        }),
      );

      if (resposta.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RedefinirSenhaPage(
              email: widget.email,
              codigo: codigoController.text.trim(),
            ),
          ),
        );
      } else {
        setState(() {
          mensagem = 'Código inválido ou expirado.';
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
              Text(
                'Digite o código enviado para ${widget.email}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: codigoController,
                decoration: InputDecoration(
                  labelText: 'Código',
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
                  onPressed: carregando ? null : validarCodigo,
                  child: carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Validar código', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
