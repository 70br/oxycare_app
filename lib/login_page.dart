import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'cadastro_usuario_page.dart';

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

    // ✅ Mantido o endpoint que você disse que está funcionando
    final url = Uri.parse('http://107.21.234.209:8080/api/Auth/login');

    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text.trim(),
          'senha': senhaController.text.trim(),
        }),
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        final accessToken = dados['accessToken'];
        final refreshToken = dados['refreshToken'];
        final expiresAt = dados['expiresAt'];
        final refreshExpiresAt = dados['refreshTokenExpiresAt'];

        // Decodifica o payload do JWT para pegar nome e email
        final partes = accessToken.split('.');
        if (partes.length == 3) {
          final payload = utf8.decode(base64Url.decode(base64Url.normalize(partes[1])));
          final info = jsonDecode(payload);
          final nomeUsuario = info['name'] ?? 'Usuário';
          final emailUsuario = info['email'] ?? emailController.text.trim();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('nomeUsuario', nomeUsuario);
          await prefs.setString('emailUsuario', emailUsuario);
        }

        // Salva tokens no dispositivo
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);
        await prefs.setString('expiresAt', expiresAt);
        await prefs.setString('refreshTokenExpiresAt', refreshExpiresAt);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else {
        // ✅ Ajustado para tratar formato ProblemDetails do .NET
        final erro = jsonDecode(resposta.body);
        setState(() {
          mensagemErro = erro['detail'] ?? erro['mensagem'] ?? 'Falha ao fazer login';
        });
      }
    } catch (e) {
      setState(() {
        mensagemErro = 'Erro de conexão com o servidor';
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
                Image.asset('assets/logo_cuidar.png', height: 140),
                const SizedBox(height: 12),
                // ✅ Nome aumentado
                const Text(
                  'Cuidar+',
                  style: TextStyle(
                    fontSize: 28, // aumentado de 22 → 28
                    color: Colors.blueAccent,
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
                    labelText: 'Email',
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
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/recuperar_senha'),
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
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: carregando ? null : realizarLogin,
                    child: carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar',
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CadastroUsuarioPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Cadastrar-se',
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
