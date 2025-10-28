import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrarMedicaoPage extends StatefulWidget {
  const RegistrarMedicaoPage({super.key});

  @override
  State<RegistrarMedicaoPage> createState() => _RegistrarMedicaoPageState();
}

class _RegistrarMedicaoPageState extends State<RegistrarMedicaoPage> {
  final _formKey = GlobalKey<FormState>();
  final temperaturaController = TextEditingController();
  final frequenciaCardiacaController = TextEditingController();
  final saturacaoController = TextEditingController();

  String? pacienteSelecionadoId;
  List<Map<String, String>> pacientes = [];

  bool carregandoPacientes = true;
  bool carregando = false;
  String? mensagem;

  @override
  void initState() {
    super.initState();
    carregarPacientes();
  }

  Future<void> carregarPacientes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final url = Uri.parse('http://107.21.234.209:8080/api/Pacientes');

      final resposta = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (resposta.statusCode == 200) {
        final List lista = jsonDecode(resposta.body);
        setState(() {
          pacientes = lista
              .map((p) => {
                    'id': p['id'].toString(),
                    'nome': p['nome'].toString(),
                  })
              .toList();
          if (pacientes.isNotEmpty) pacienteSelecionadoId = pacientes.first['id'];
        });
      } else {
        setState(() => mensagem = "Erro ao carregar pacientes (${resposta.statusCode})");
      }
    } catch (e) {
      setState(() => mensagem = "Falha ao conectar ao servidor.");
    } finally {
      setState(() => carregandoPacientes = false);
    }
  }

  void simularLeituraSensor() {
    final random = Random();
    setState(() {
      temperaturaController.text =
          (36.0 + random.nextDouble() * 1.5).toStringAsFixed(1);
      frequenciaCardiacaController.text = (60 + random.nextInt(40)).toString();
      saturacaoController.text =
          (95 + random.nextInt(4) + random.nextDouble()).toStringAsFixed(1);
      mensagem = "Simulação concluída com sucesso!";
    });
  }

  Future<void> lerDoSensorBluetooth() async {
    setState(() => mensagem = "Aguardando conexão Bluetooth...");
  }

  Future<void> lerDoSensorWiFi() async {
    setState(() => mensagem = "Lendo via Wi-Fi...");
  }

  Future<void> registrarMedicao() async {
    if (!_formKey.currentState!.validate() || pacienteSelecionadoId == null) {
      setState(() => mensagem = "Preencha todos os campos corretamente.");
      return;
    }

    setState(() {
      carregando = true;
      mensagem = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final url = Uri.parse('http://107.21.234.209:8080/api/Medicoes');

      final body = jsonEncode({
        'pacienteId': pacienteSelecionadoId,
        'dataHora': DateTime.now().toIso8601String(),
        'temperatura': double.tryParse(temperaturaController.text.trim()) ?? 0.0,
        'frequenciaCardiaca':
            int.tryParse(frequenciaCardiacaController.text.trim()) ?? 0,
        'saturacao': double.tryParse(saturacaoController.text.trim()) ?? 0.0,
      });

      final resposta = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (resposta.statusCode == 201) {
        setState(() {
          mensagem = "✓ Medição registrada com sucesso!";
        });
        temperaturaController.clear();
        frequenciaCardiacaController.clear();
        saturacaoController.clear();
      } else {
        final erro = jsonDecode(resposta.body);
        setState(() {
          mensagem = erro['message'] ?? "Erro ao registrar medição.";
        });
      }
    } catch (e) {
      setState(() {
        mensagem = "Erro de conexão com o servidor.";
      });
    }

    setState(() => carregando = false);
  }

  @override
  void dispose() {
    temperaturaController.dispose();
    frequenciaCardiacaController.dispose();
    saturacaoController.dispose();
    super.dispose();
  }

  ButtonStyle estiloBotao(Color cor) {
    return ElevatedButton.styleFrom(
      backgroundColor: cor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Registrar Medição"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/logo_cuidar.png', height: 120),
                const SizedBox(height: 12),
                const Text(
                  'Cuidar+',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Registrar Medição do Paciente',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 28),
                carregandoPacientes
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.blueAccent))
                    : DropdownButtonFormField<String>(
                        value: pacienteSelecionadoId,
                        decoration: InputDecoration(
                          labelText: "Selecione o Paciente",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: pacientes
                            .map((p) => DropdownMenuItem(
                                  value: p['id'],
                                  child: Text(p['nome']!),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => pacienteSelecionadoId = value),
                        validator: (v) =>
                            v == null ? "Selecione um paciente" : null,
                      ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: temperaturaController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Temperatura (°C)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Informe a temperatura" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: frequenciaCardiacaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Frequência Cardíaca (bpm)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Informe os batimentos" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: saturacaoController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Saturação de O₂ (%)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Informe a saturação" : null,
                ),
                const SizedBox(height: 24),
                if (mensagem != null)
                  Text(
                    mensagem!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          mensagem!.startsWith("✓") ? Colors.green : Colors.red,
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: carregando ? null : registrarMedicao,
                  icon: const Icon(Icons.send),
                  label: carregando
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text("Registrar Manualmente"),
                  style: estiloBotao(Colors.blueAccent),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: simularLeituraSensor,
                  icon: const Icon(Icons.sensors),
                  label: const Text("Simular Leitura de Sensor"),
                  style: estiloBotao(Colors.orangeAccent),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: lerDoSensorBluetooth,
                  icon: const Icon(Icons.bluetooth),
                  label: const Text("Ler via Bluetooth (futuro)"),
                  style: estiloBotao(Colors.teal),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: lerDoSensorWiFi,
                  icon: const Icon(Icons.wifi),
                  label: const Text("Ler via Wi-Fi (futuro)"),
                  style: estiloBotao(Colors.indigo),
                ),
                const SizedBox(height: 30),
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                const Text(
                  'Conectado à API Cuidar+ (AWS)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
