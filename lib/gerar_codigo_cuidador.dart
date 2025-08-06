import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GerarCodigoCuidadorPage extends StatefulWidget {
  const GerarCodigoCuidadorPage({super.key});

  @override
  State<GerarCodigoCuidadorPage> createState() => _GerarCodigoCuidadorPageState();
}

class _GerarCodigoCuidadorPageState extends State<GerarCodigoCuidadorPage> {
  int? pacienteSelecionadoId;
  String? codigoGerado;
  List<Map<String, dynamic>> pacientes = [];
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    buscarPacientes();
  }

  Future<void> buscarPacientes() async {
    final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/listar_pacientes.php');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pacientes = List<Map<String, dynamic>>.from(
            data['pacientes'].map((p) => {
              "id": int.parse(p["id"].toString()),
              "nome": p["nome"],
            }),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao buscar pacientes")),
        );
      }
    } catch (e) {
      print("Erro ao buscar pacientes: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro inesperado: $e")),
      );
    }
  }

  Future<void> gerarCodigo() async {
    if (pacienteSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecione um paciente")),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/gerar_codigo_cuidador.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'paciente_id': pacienteSelecionadoId}),
      );

      setState(() => carregando = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Resposta: $data");

        if (data['status'] == 'sucesso') {
          setState(() {
            codigoGerado = data['codigo'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['mensagem'] ?? "Erro ao gerar código")),
          );
        }
      } else {
        print("❌ Erro no servidor: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao gerar código")),
        );
      }
    } catch (e) {
      setState(() => carregando = false);
      print("❌ Erro: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro inesperado: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gerar Código para Cuidador")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Image.asset('assets/logo_oxycare.png', height: 50)),
            const SizedBox(height: 24),
            const Text("Selecione o paciente:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: pacienteSelecionadoId,
              items: pacientes
                  .map((paciente) => DropdownMenuItem<int>(
                        value: paciente['id'],
                        child: Text(paciente['nome']),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  pacienteSelecionadoId = value;
                  codigoGerado = null;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Paciente",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: carregando ? null : gerarCodigo,
              child: carregando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Gerar Código"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),
            if (codigoGerado != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Código gerado:", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    codigoGerado!,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
