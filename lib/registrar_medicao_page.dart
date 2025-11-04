import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oxycare_app/states/ble_state.dart';
import 'package:oxycare_app/utils.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class RegistrarMedicaoPage extends StatefulWidget {
  const RegistrarMedicaoPage({super.key});

  @override
  State<RegistrarMedicaoPage> createState() => _RegistrarMedicaoPageState();
}

class _RegistrarMedicaoPageState extends State<RegistrarMedicaoPage> {
  final _formKey = GlobalKey<FormState>();


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
      final url = Uri.parse('$urlGlobal/api/Pacientes');

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

  @override
  void dispose() {
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
    final bleState = Provider.of<BleState>(context);
    String textString = bleState.connected ? "Já Conectado!" : "Conectar a um Aparelho";

  Future<void> registrarMedicao(double freqRespiratoria, double temperatura, int freqCardiaca) async {
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

      final url = Uri.parse('$urlGlobal/api/Medicoes');

      final body = jsonEncode({
        'pacienteId': pacienteSelecionadoId,
        'dataHora': DateTime.now().toIso8601String(),
        'temperatura': temperatura,
        'frequenciaCardiaca':freqCardiaca,
        'saturacao': freqRespiratoria,
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

    bleState.setCallBack(registrarMedicao);
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle,
                        size: 12, color: bleState.connected ? Colors.green : Colors.red),
                    SizedBox(width: 6),
                    Text(
                      bleState.connected
                          ? 'Conectado ao PROTOTIPO'
                          : 'Não conectado... Aguarde conexão',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
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
                _buildCard("Freq. Cardíaca", bleState.freqCardiaca.toString(), "bpm", Icons.favorite, Colors.pink),
                _buildCard("Temperatura", bleState.temperatura.toStringAsFixed(1), "ºC", Icons.thermostat, Colors.orange),
                _buildCard("Freq. Respiratória", bleState.freqRespiratoria.toString(), "%", Icons.air, Colors.purple),
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
                  onPressed: () => ({}),
                  icon: const Icon(Icons.bluetooth),
                  label: Text(textString),
                  style: estiloBotao(Colors.teal),
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

  Widget _buildCard(
    String titulo,
    String valor,
    String unidade,
    IconData icon,
    Color color
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: color),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(valor,
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Text(unidade, style: TextStyle(fontSize: 16))
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
