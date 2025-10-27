import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroPacientePage extends StatefulWidget {
  const CadastroPacientePage({super.key});

  @override
  State<CadastroPacientePage> createState() => _CadastroPacientePageState();
}

class _CadastroPacientePageState extends State<CadastroPacientePage> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final cpfController = TextEditingController();
  final dataController = TextEditingController();

  bool carregando = false;
  String? mensagem;
  DateTime? dataNascimento;

  Future<void> cadastrarPaciente() async {
    if (!_formKey.currentState!.validate() || dataNascimento == null) {
      setState(() {
        mensagem = "Preencha todos os campos corretamente.";
      });
      return;
    }

    setState(() {
      carregando = true;
      mensagem = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final url = Uri.parse('http://107.21.234.209:8080/api/Pacientes');

    try {
      final resposta = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nome': nomeController.text.trim(),
          'cpf': cpfController.text.trim(),
          'dataNascimento': dataNascimento!.toIso8601String().split('T').first,
        }),
      );

      if (resposta.statusCode == 201) {
        setState(() {
          mensagem = "✅ Paciente cadastrado com sucesso!";
        });
        nomeController.clear();
        cpfController.clear();
        dataController.clear();
        dataNascimento = null;
      } else {
        final erro = jsonDecode(resposta.body);
        setState(() {
          mensagem = erro['message'] ?? "Erro ao cadastrar paciente.";
        });
      }
    } catch (e) {
      setState(() {
        mensagem = "Erro de conexão com o servidor.";
      });
    }

    setState(() {
      carregando = false;
    });
  }

  Future<void> selecionarData() async {
    FocusScope.of(context).requestFocus(FocusNode()); // evita abrir teclado
    final hoje = DateTime.now();
    final primeiraData = DateTime(1900);

    final selecionada = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: primeiraData,
      lastDate: hoje,
      locale: const Locale('pt', 'BR'),
    );

    if (selecionada != null) {
      setState(() {
        dataNascimento = selecionada;
        dataController.text =
            "${selecionada.day}/${selecionada.month}/${selecionada.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cadastrar Paciente"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Logo e título igual ao cadastro de usuário
                  Image.asset('assets/logo_cuidar.png', height: 120),
                  const SizedBox(height: 12),
                  const Text(
                    'Cuidar+',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cadastro de Paciente',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 28),

                  // Campo Nome
                  TextFormField(
                    controller: nomeController,
                    decoration: InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Informe o nome" : null,
                  ),
                  const SizedBox(height: 16),

                  // Campo CPF
                  TextFormField(
                    controller: cpfController,
                    decoration: InputDecoration(
                      labelText: "CPF",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Informe o CPF" : null,
                  ),
                  const SizedBox(height: 16),

                  // Campo Data de Nascimento
                  TextFormField(
                    controller: dataController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Data de Nascimento",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: selecionarData,
                    validator: (_) =>
                        dataNascimento == null ? "Selecione a data" : null,
                  ),
                  const SizedBox(height: 24),

                  if (mensagem != null)
                    Text(
                      mensagem!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: mensagem!.startsWith("✅")
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: carregando ? null : cadastrarPaciente,
                      icon: const Icon(Icons.person_add),
                      label: carregando
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : const Text(
                              "Cadastrar Paciente",
                              style: TextStyle(fontSize: 16),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Divider(thickness: 1),
                  const SizedBox(height: 8),
                  const Text(
                    'Conectado à API Cuidar+',
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
