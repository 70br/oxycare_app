import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListarPerfisPage extends StatefulWidget {
  @override
  _ListarPerfisPageState createState() => _ListarPerfisPageState();
}

class _ListarPerfisPageState extends State<ListarPerfisPage> {
  List<dynamic> perfis = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarPerfis();
  }

  Future<void> carregarPerfis() async {
    final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/listar_perfis.php');
    try {
      final resposta = await http.get(url);
      final dados = jsonDecode(resposta.body);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Perfis Cadastrados")),
      body: carregando
          ? Center(child: CircularProgressIndicator())
          : perfis.isEmpty
              ? Center(child: Text("Nenhum perfil encontrado"))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: perfis.length,
                  itemBuilder: (context, index) {
                    final perfil = perfis[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              perfil['nome'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6),
                            Text("Sexo: ${perfil['sexo']}"),
                            Text("Faixa etária: ${perfil['faixa_etaria']}"),
                            if ((perfil['comorbidades'] ?? '').isNotEmpty)
                              Text("Comorbidades: ${perfil['comorbidades']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
