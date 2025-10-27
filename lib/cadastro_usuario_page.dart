import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool carregando = false;
  bool _mostrarSenha = false;
  bool _mostrarConfirmarSenha = false;
  String? mensagemErro;
  String? mensagemSucesso;

  Future<void> cadastrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      carregando = true;
      mensagemErro = null;
      mensagemSucesso = null;
    });

    final url = Uri.parse('http://107.21.234.209:8080/api/Usuarios');

    final body = jsonEncode({
      'nome': nomeController.text.trim(),
      'email': emailController.text.trim(),
      'senha': senhaController.text.trim(),
    });

    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (resposta.statusCode == 201) {
        setState(() {
          mensagemSucesso = 'Usuário cadastrado com sucesso!';
        });

        // Espera um momento e volta para a tela de login
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        final erro = jsonDecode(resposta.body);
        setState(() {
          mensagemErro = erro['message'] ?? 'Falha ao cadastrar usuário';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cadastrar Usuário'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset('assets/logo_cuidar.png', height: 120),
              const SizedBox(height: 10),
              const Text(
                'Crie sua conta no Cuidar+',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 24),

              // Nome
              TextFormField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o email';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Senha
              TextFormField(
                controller: senhaController,
                obscureText: !_mostrarSenha,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarSenha
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _mostrarSenha = !_mostrarSenha;
                      });
                    },
                  ),
                ),
                validator: (v) =>
                    v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
              ),
              const SizedBox(height: 12),

              // Confirmar senha
              TextFormField(
                controller: confirmarSenhaController,
                obscureText: !_mostrarConfirmarSenha,
                decoration: InputDecoration(
                  labelText: 'Confirmar senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarConfirmarSenha
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _mostrarConfirmarSenha = !_mostrarConfirmarSenha;
                      });
                    },
                  ),
                ),
                validator: (v) =>
                    v == senhaController.text ? null : 'Senhas não conferem',
              ),
              const SizedBox(height: 20),

              // Mensagens de erro/sucesso
              if (mensagemErro != null)
                Text(
                  mensagemErro!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (mensagemSucesso != null)
                Text(
                  mensagemSucesso!,
                  style: const TextStyle(color: Colors.green),
                ),
              const SizedBox(height: 20),

              // Botão cadastrar
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
                  onPressed: carregando ? null : cadastrarUsuario,
                  child: carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Já tem uma conta? Entrar',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
