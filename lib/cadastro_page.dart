import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  bool mostrarSenha = false;
  bool mostrarConfirmarSenha = false;
  bool isEnfermeiro = false;
  bool carregando = false;
  String? mensagemErro;

  Future<void> cadastrarUsuario() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();
    final confirmarSenha = confirmarSenhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
      setState(() {
        mensagemErro = 'Preencha todos os campos.';
      });
      return;
    }

    if (senha != confirmarSenha) {
      setState(() {
        mensagemErro = 'As senhas não coincidem.';
      });
      return;
    }

    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/cadastrar.php');

    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'senha': senha,
          'tipo': isEnfermeiro ? 'enfermeiro' : 'paciente',
        }),
      );

      final dados = jsonDecode(resposta.body);

      if (dados['status'] == 'ok') {
        Navigator.pushReplacementNamed(context, '/sucesso');
      } else {
        setState(() {
          mensagemErro = dados['mensagem'] ?? 'Erro no cadastro';
        });
      }
    } catch (e) {
      setState(() {
        mensagemErro = 'Erro ao conectar com o servidor.';
      });
    }

    setState(() {
      carregando = false;
    });
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Criar Conta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Criar uma conta no OxyCare',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('Preencha os dados abaixo', style: TextStyle(color: Colors.black54)),
            SizedBox(height: 24),

            // NOME
            TextField(
              controller: nomeController,
              decoration: _inputDecoration('Nome'),
            ),
            SizedBox(height: 16),

            // EMAIL
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Usuário', hint: 'Digite o seu usuário aqui...'),
            ),
            SizedBox(height: 16),

            // SENHA
            TextField(
              controller: senhaController,
              obscureText: !mostrarSenha,
              decoration: _inputDecoration('Digite a senha').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(mostrarSenha ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      mostrarSenha = !mostrarSenha;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            // CONFIRMAR SENHA
            TextField(
              controller: confirmarSenhaController,
              obscureText: !mostrarConfirmarSenha,
              decoration: _inputDecoration('Digite a senha novamente').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(mostrarConfirmarSenha ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      mostrarConfirmarSenha = !mostrarConfirmarSenha;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            // CHECKBOX
            Row(
              children: [
                Checkbox(
                  value: isEnfermeiro,
                  onChanged: (value) {
                    setState(() {
                      isEnfermeiro = value ?? false;
                    });
                  },
                ),
                Text('Sou um(a) enfermeiro(a)'),
              ],
            ),
            SizedBox(height: 16),

            if (mensagemErro != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  mensagemErro!,
                  style: TextStyle(color: Colors.red),
                ),
              ),

            // BOTÃO
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: carregando ? null : cadastrarUsuario,
                child: carregando
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Criar Conta', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

