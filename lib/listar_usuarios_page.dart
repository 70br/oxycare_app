import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListarUsuariosPage extends StatefulWidget {
  const ListarUsuariosPage({super.key});

  @override
  State<ListarUsuariosPage> createState() => _ListarUsuariosPageState();
}

class _ListarUsuariosPageState extends State<ListarUsuariosPage> {
  List<dynamic> usuarios = [];
  bool carregando = true;
  String? erroMensagem;

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        setState(() {
          erroMensagem = 'Token de autenticação não encontrado. Faça login novamente.';
          carregando = false;
        });
        return;
      }

      final url = Uri.parse('http://silvaelias.ddns.net:5000/api/Usuarios');
      final resposta = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        setState(() {
          usuarios = dados;
          carregando = false;
        });
      } else if (resposta.statusCode == 401) {
        setState(() {
          erroMensagem = 'Token expirado ou inválido. Faça login novamente.';
          carregando = false;
        });
      } else {
        setState(() {
          erroMensagem = 'Erro ao buscar usuários (${resposta.statusCode})';
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        erroMensagem = 'Erro de conexão com o servidor.';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários Cadastrados'),
        backgroundColor: Colors.blueAccent,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erroMensagem != null
              ? Center(
                  child: Text(
                    erroMensagem!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: carregarUsuarios,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: usuarios.length,
                    itemBuilder: (context, index) {
                      final usuario = usuarios[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.blueAccent),
                          title: Text(usuario['nome'] ?? 'Sem nome'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(usuario['email'] ?? ''),
                              const SizedBox(height: 4),
                              Text(
                                'Criado em: ${usuario['criadoEm'] ?? ''}',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
