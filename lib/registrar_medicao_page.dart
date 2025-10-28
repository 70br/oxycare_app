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
  final pressaoController = TextEditingController();
  final temperaturaController = TextEditingController();
  final batimentosController = TextEditingController();

  bool carregando = false;
  String? mensagem;

  /// 🔹 Simula leitura do sensor Bluetooth ou Wi-Fi
  void simularLeituraSensor() {
    final random = Random();
    setState(() {
      pressaoController.text =
          "${110 + random.nextInt(20)}/${70 + random.nextInt(10)}";
      temperaturaController.text =
          (36.0 + random.nextDouble() * 1.5).toStringAsFixed(1);
      batimentosController.text = (60 + random.nextInt(40)).toString();
      mensagem = "✅ Leitura simulada com sucesso!";
    });
  }

  /// 🔹 Futuro: leitura real do sensor Bluetooth (hardware)
  Future<void> lerDoSensorBluetooth() async {
    setState(() => mensagem = "📡 Aguardando conexão Bluetooth...");
    // TODO: implementar leitura real com flutter_blue_plus
  }

  /// 🔹 Futuro: leitura via Wi-Fi (IoT / ESP32, etc)
  Future<void> lerDoSensorWiFi() async {
    setState(() => mensagem = "🌐 Lendo via Wi-Fi...");
    // TODO: implementar leitura via requisição HTTP ao IP do sensor Wi-Fi
  }

  /// 🔹 Envia dados à API .NET
  Future<void> registrarMedicao() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => mensagem = "Preencha todos os campos corretamente.");
      return;
    }

    setState(() {
      carregando = true;
      mensagem = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final pacienteId = prefs.getString('pacienteId'); // obtém o ID do paciente logado

    if (pacienteId == null) {
      setState(() {
        mensagem = "Paciente não identificado. Faça login novamente.";
        carregando = false;
      });
      return;
    }

    final url = Uri.parse('http://107.21.234.209:8080/api/Medicoes');

    try {
      final resposta = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pacienteId': pacienteId,
          'dataHora': DateTime.now().toIso8601String(),
          'temperatura': double.parse(temperaturaController.text.trim()),
          'frequenciaCardiaca': int.parse(batimentosController.text.trim()),
          'saturacao': (97 + Random().nextInt(3)).toDouble(), // valor simulado
        }),
      );

      if (resposta.statusCode == 201) {
        setState(() {
          mensagem = "✅ Medição registrada com sucesso!";
        });
        pressaoController.clear();
        temperaturaController.clear();
        batimentosController.clear();
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

    setState(() {
      carregando = false;
    });
  }

  @override
  void dispose() {
    pressaoController.dispose();
    temperaturaController.dispose();
    batimentosController.dispose();
    super.dispose();
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

                // 🔹 Campo de pressão arterial
                TextFormField(
                  controller: pressaoController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Pressão Arterial (ex: 120/80)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Informe a pressão" : null,
                ),
                const SizedBox(height: 16),

                // 🔹 Campo temperatura
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

                // 🔹 Campo batimentos
                TextFormField(
                  controller: batimentosController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Batimentos Cardíacos (bpm)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Informe os batimentos" : null,
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 20),

                // 🔹 Botão Registrar Manualmente
                ElevatedButton.icon(
                  onPressed: carregando ? null : registrarMedicao,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: carregando
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text(
                          "Registrar Manualmente",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Botão Simular Leitura
                ElevatedButton.icon(
                  onPressed: simularLeituraSensor,
                  icon: const Icon(Icons.sensors, color: Colors.white),
                  label: const Text(
                    "Simular Leitura de Sensor",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Botão Bluetooth
                ElevatedButton.icon(
                  onPressed: lerDoSensorBluetooth,
                  icon: const Icon(Icons.bluetooth, color: Colors.white),
                  label: const Text(
                    "Ler via Bluetooth (futuro)",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔹 Botão Wi-Fi
                ElevatedButton.icon(
                  onPressed: lerDoSensorWiFi,
                  icon: const Icon(Icons.wifi, color: Colors.white),
                  label: const Text(
                    "Ler via Wi-Fi (futuro)",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
