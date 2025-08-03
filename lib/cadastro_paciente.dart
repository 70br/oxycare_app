import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroPacientePage extends StatefulWidget {
  const CadastroPacientePage({super.key});

  @override
  State<CadastroPacientePage> createState() => _CadastroPacientePageState();
}

class _CadastroPacientePageState extends State<CadastroPacientePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/cadastrar_paciente.php');

      try {
        // 🔍 Debug: imprimindo os dados que serão enviados
        print('Enviando dados:');
        print({
          'nome': _nomeController.text,
          'cpf': _cpfController.text,
          'telefone': _telefoneController.text,
          'email': _emailController.text,
          'senha': _senhaController.text,
        });

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'nome': _nomeController.text,
            'cpf': _cpfController.text,
            'telefone': _telefoneController.text,
            'email': _emailController.text,
            'senha': _senhaController.text,
          }),
        );

        // 🔍 Debug: imprimindo a resposta do servidor
        print('Resposta: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final mensagem = data['mensagem'] ?? 'Resposta do servidor desconhecida';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensagem)),
          );

          if (data['status'] == 'sucesso') {
            // Limpa os campos se cadastro foi sucesso
            _nomeController.clear();
            _cpfController.clear();
            _telefoneController.clear();
            _emailController.clear();
            _senhaController.clear();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro na conexão: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Paciente')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/logo_oxycare.png', height: 60),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildCampo('Nome completo', _nomeController),
                    _buildCampo('CPF', _cpfController),
                    _buildCampo('Telefone', _telefoneController),
                    _buildCampo('Email', _emailController),
                    _buildCampo('Senha', _senhaController, isSenha: true),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _cadastrar,
                      child: Text('Cadastrar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampo(String label, TextEditingController controller,
      {bool isSenha = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isSenha,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }
}
