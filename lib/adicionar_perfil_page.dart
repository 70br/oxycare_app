import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdicionarPerfilPage extends StatefulWidget {
  @override
  _AdicionarPerfilPageState createState() => _AdicionarPerfilPageState();
}

class _AdicionarPerfilPageState extends State<AdicionarPerfilPage> {
  final nomeController = TextEditingController();
  final comorbidadeController = TextEditingController();
  String? sexoSelecionado;
  String? faixaEtariaSelecionada;
  bool carregando = false;
  String? mensagemErro;

  final List<String> sexos = ['Masculino', 'Feminino'];
  final List<String> faixasEtarias = ['Criança', 'Adulto', 'Idoso'];

  Future<void> salvarPerfil() async {
    final nome = nomeController.text.trim();
    final sexo = sexoSelecionado;
    final faixa = faixaEtariaSelecionada;
    final comorbidades = comorbidadeController.text.trim();

    if (nome.isEmpty || sexo == null || faixa == null) {
      setState(() {
        mensagemErro = 'Preencha todos os campos obrigatórios.';
      });
      return;
    }

    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/cadastrar_perfil.php');

    try {
      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'sexo': sexo,
          'faixa': faixa,
          'comorbidades': comorbidades,
        }),
      );

      final dados = jsonDecode(resposta.body);

      if (dados['status'] == 'ok') {
        Navigator.pushReplacementNamed(context, '/listar_perfis');
      } else {
        setState(() {
          mensagemErro = dados['mensagem'] ?? 'Erro ao salvar o perfil.';
        });
      }
    } catch (e) {
      setState(() {
        mensagemErro = 'Erro de conexão com o servidor.';
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
      appBar: AppBar(title: Text('Adicionar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset('assets/logo_oxycare.png', height: 100),
            SizedBox(height: 20),
            Text(
              'Adicionar Perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            // Campo nome
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),

            // Dropdown sexo
            DropdownButtonFormField<String>(
              value: sexoSelecionado,
              items: sexos
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) => setState(() => sexoSelecionado = value),
              decoration: InputDecoration(
                labelText: 'Sexo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),

            // Dropdown faixa etária
            DropdownButtonFormField<String>(
              value: faixaEtariaSelecionada,
              items: faixasEtarias
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (value) => setState(() => faixaEtariaSelecionada = value),
              decoration: InputDecoration(
                labelText: 'Faixa Etária',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),

            // Comorbidades
            TextField(
              controller: comorbidadeController,
              decoration: InputDecoration(
                labelText: 'Comorbidades (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),

            if (mensagemErro != null)
              Text(
                mensagemErro!,
                style: TextStyle(color: Colors.red),
              ),

            SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: carregando ? null : salvarPerfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: carregando
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Salvar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
