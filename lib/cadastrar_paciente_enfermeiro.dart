import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastrarPacienteEnfermeiroPage extends StatefulWidget {
  const CadastrarPacienteEnfermeiroPage({super.key});

  @override
  State<CadastrarPacienteEnfermeiroPage> createState() => _CadastrarPacienteEnfermeiroPageState();
}

class _CadastrarPacienteEnfermeiroPageState extends State<CadastrarPacienteEnfermeiroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  String? _codigoGerado;

  Future<void> _cadastrarPaciente() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/cadastrar_paciente_enfermeiro.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': _nomeController.text,
          'cpf': _cpfController.text,
          'telefone': _telefoneController.text,
          'email': _emailController.text,
          'senha': _senhaController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'sucesso') {
        setState(() {
          _codigoGerado = data['codigo'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paciente cadastrado com sucesso! Código: $_codigoGerado')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['mensagem'] ?? 'Erro desconhecido')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Paciente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset('assets/logo_oxycare.png', height: 60),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildCampo('Nome completo', _nomeController),
                  _buildCampo('CPF', _cpfController),
                  _buildCampo('Telefone', _telefoneController),
                  _buildCampo('Email', _emailController),
                  _buildCampo('Senha', _senhaController, isSenha: true),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _cadastrarPaciente,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Cadastrar e Gerar Código'),
                  ),
                  const SizedBox(height: 20),
                  if (_codigoGerado != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        border: Border.all(color: Colors.teal),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text('Código de Acesso Gerado:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(_codigoGerado!, style: const TextStyle(fontSize: 20, color: Colors.black87)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampo(String label, TextEditingController controller, {bool isSenha = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isSenha,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }
}
