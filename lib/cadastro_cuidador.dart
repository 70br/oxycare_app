import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroCuidadorPage extends StatefulWidget {
  final int pacienteId;

  const CadastroCuidadorPage({super.key, required this.pacienteId});

  @override
  State<CadastroCuidadorPage> createState() => _CadastroCuidadorPageState();
}

class _CadastroCuidadorPageState extends State<CadastroCuidadorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _vinculoPacienteController = TextEditingController();
  DateTime? _dataNascimento;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _vinculoPacienteController.dispose();
    super.dispose();
  }

  void _cadastrar() async {
    if (_formKey.currentState!.validate() && _dataNascimento != null) {
      final uri = Uri.parse("http://silvaelias.ddns.net/oxycare/api/cadastrar_cuidador.php");

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "nome": _nomeController.text,
          "cpf": _cpfController.text,
          "telefone": _telefoneController.text,
          "email": _emailController.text,
          "senha": _senhaController.text,
          "vinculo_paciente": _vinculoPacienteController.text,
          "data_nascimento": DateFormat('yyyy-MM-dd').format(_dataNascimento!),
          "paciente_id": widget.pacienteId, // <- Enviando o ID aqui!
        }),
      );

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        if (jsonResp['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cadastro realizado com sucesso!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${jsonResp['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao conectar ao servidor.')),
        );
      }
    } else if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione a data de nascimento.')),
      );
    }
  }

  Future<void> _selecionarDataNascimento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dataNascimento = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Cuidador')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
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
                    _buildCampo('Vínculo com o Paciente', _vinculoPacienteController),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _selecionarDataNascimento,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data de Nascimento',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _dataNascimento != null
                              ? DateFormat('dd/MM/yyyy').format(_dataNascimento!)
                              : 'Toque para selecionar',
                          style: TextStyle(
                            color: _dataNascimento != null
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _cadastrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Cadastrar'),
                    ),
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
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }
}
