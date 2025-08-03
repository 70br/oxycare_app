


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tempo_real_page.dart'; // Import necessÃ¡rio!

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool carregando = false;
  String? mensagemErro;
  bool _mostrarSenha = false;

  Future<void> realizarLogin() async {
    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/login.php');

    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'senha': senhaController.text.trim(),
        }),
      );

      final dados = jsonDecode(resposta.body);

      if (dados['status'] == 'ok') {
        // TODO: use os dados reais retornados do login futuramente
        // Aqui estamos colocando valores fixos para entrar no tempo real
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TempoRealPage(
              idPerfilSelecionado: 1, // substitua se necessÃ¡rio
              nomePerfil: 'Paciente Teste', // substitua se necessÃ¡rio
            ),
          ),
        );
      } else {
        setState(() {
          mensagemErro = dados['mensagem'] ?? 'Login invÃ¡lido';
        });
      }
    } catch (e) {
      setState(() {
        mensagemErro = 'Erro ao conectar com o servidor';
      });
    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/logo_oxycare.png', height: 140),
                const SizedBox(height: 12),
                const Text(
                  'OxyCare',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Entrar no Sistema',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: senhaController,
                  obscureText: !_mostrarSenha,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarSenha ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _mostrarSenha = !_mostrarSenha;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (mensagemErro != null)
                  Text(
                    mensagemErro!,
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/recuperar_senha');
                    },
                    child: const Text(
                      'Esqueceu a senha?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: carregando ? null : realizarLogin,
                    child: carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Não possui cadastro?', style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
//                    onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                      onPressed: () => Navigator.pushNamed(context, '/selecao_tipo'),
                    child: const Text(
                      'Criar Conta',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                const Text(
                  'Desenvolvido com muito orgulho, pela',
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Image.asset('assets/ufs_logo_nome_lado.png', height: 55),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
