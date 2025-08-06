import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelaCodigoAcesso extends StatefulWidget {
  const TelaCodigoAcesso({super.key});

  @override
  State<TelaCodigoAcesso> createState() => _TelaCodigoAcessoState();
}

class _TelaCodigoAcessoState extends State<TelaCodigoAcesso> {
  final _codigoController = TextEditingController();
  bool _carregando = false;

  Future<void> _validarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o código.')),
      );
      return;
    }

    setState(() => _carregando = true);

    final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/validar_codigo.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'codigo': codigo}),
    );

    setState(() => _carregando = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final tipo = data['tipo'];
        final pacienteId = data['paciente_id'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Código válido. Tipo: $tipo')),
        );

        if (tipo == 'cuidador') {
          Navigator.pushNamed(context, '/cadastro_cuidador', arguments: pacienteId);
        } else if (tipo == 'paciente') {
          Navigator.pushNamed(context, '/cadastro_paciente'); // <- aqui sem argumento
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tipo desconhecido.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${data['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro na conexão com o servidor.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Código de Acesso')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/logo_oxycare.png', height: 60),
            const SizedBox(height: 30),
            TextField(
              controller: _codigoController,
              decoration: const InputDecoration(
                labelText: 'Digite o código de acesso',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _carregando ? null : _validarCodigo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _carregando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Validar Código'),
            ),
          ],
        ),
      ),
    );
  }
}
