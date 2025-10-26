import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Importação da tela TempoRealPage (ajuste o caminho conforme seu projeto)
import 'package:oxycare_app/tempo_real_page.dart';

class ListarPerfisPage extends StatefulWidget {
  @override
  _ListarPerfisPageState createState() => _ListarPerfisPageState();
}

class _ListarPerfisPageState extends State<ListarPerfisPage> {
  List<dynamic> perfis = [];
  bool carregando = true;
  String? tipoUsuario; // ADICIONADO

  @override
  void initState() {
    super.initState();
    carregarPerfis();
    carregarTipoUsuario(); // ADICIONADO
  }

  Future<void> carregarTipoUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tipoUsuario = prefs.getString('tipoUsuario') ?? '';
    });
  }

  Future<void> carregarPerfis() async {
    final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/listar_perfis.php');
    try {
      final resposta = await http.get(url);
      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));

      if (dados['status'] == 'ok') {
        setState(() {
          perfis = dados['perfis'];
          carregando = false;
        });
      } else {
        setState(() {
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        carregando = false;
      });
    }
  }

  Future<Map<String, dynamic>?> obterPerfilSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('idPerfilSelecionado');
    final nome = prefs.getString('nomePerfil');

    if (id != null && nome != null) {
      return {'id': id, 'nome': nome};
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF6FF),
      body: carregando
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 40),
                Center(child: Image.asset('assets/logo_oxycare.png', height: 40)),
                SizedBox(height: 8),
GestureDetector(
  onTap: () {
    Navigator.pushNamed(context, '/conexao');
  },
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.bluetooth_disabled, color: Colors.red, size: 16),
      SizedBox(width: 6),
      Text(
        "Não conectado... Clique para conectar",
        style: TextStyle(color: Colors.red, decoration: TextDecoration.underline),
      ),
    ],
  ),
),
                SizedBox(height: 12),
                Text("Perfis Cadastrados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: perfis.length,
                    itemBuilder: (context, index) {
                      final perfil = perfis[index];
                      return GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt('idPerfilSelecionado', perfil['id']);
                          await prefs.setString('nomePerfil', perfil['nome']);

                          Navigator.pop(context, {
                            'id': perfil['id'],
                            'nome': perfil['nome'],
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 6),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person, size: 40, color: Colors.blue),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(perfil['nome'] ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text("${perfil['sexo'] ?? ''}".toUpperCase()),
                                    Text("${perfil['faixa_etaria'] ?? 'SEM FAIXA ETÁRIA'}".toUpperCase()),
                                    Text("${perfil['comorbidades']?.toString().toUpperCase() ?? 'SEM COMORBIDADES'}"),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/adicionar_perfil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "Novo Perfil",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Em breve: função de compartilhamento
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "Compartilhar Perfis",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/visualizar_pacientes_cuidadores');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          "Visualizar Pacientes",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          final prefs = await SharedPreferences.getInstance();
          final idPerfil = prefs.getInt('idPerfilSelecionado');
          final nomePerfil = prefs.getString('nomePerfil');

          switch (index) {
            case 0: // Tempo Real
              if (idPerfil != null && nomePerfil != null) {
                Navigator.pushReplacementNamed(
                  context,
                  '/tempoReal',
                  arguments: {
                    'idPerfilSelecionado': idPerfil,
                    'nomePerfil': nomePerfil,
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selecione um perfil antes de acessar Tempo Real')),
                );
              }
              break;
            case 1: // Perfis
              // já está aqui, não faz nada
              break;
            case 2: // Conexão
              Navigator.pushReplacementNamed(context, '/conexao');
              break;
            case 3: // Histórico
              if (idPerfil != null && nomePerfil != null) {
                Navigator.pushReplacementNamed(
                  context,
                  '/historico',
                  arguments: {
                    'idPerfilSelecionado': idPerfil,
                    'nomePerfil': nomePerfil,
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selecione um perfil antes de acessar Histórico')),
                );
              }
              break;
            case 4: // Dashboard (enfermeiro)
              if (tipoUsuario == 'enfermeiro') {
                Navigator.pushReplacementNamed(context, '/dashboard_enfermeiro');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Acesso ao Dashboard restrito.')),
                );
              }
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.monitor_heart), label: 'Tempo Real'),
          const BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Perfis'),
          const BottomNavigationBarItem(icon: Icon(Icons.bluetooth), label: 'Conexão'),
          const BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Histórico'),
          if (tipoUsuario == 'enfermeiro')
            const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      ),
    );
  }
}
