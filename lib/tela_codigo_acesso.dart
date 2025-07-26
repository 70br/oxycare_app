import 'package:flutter/material.dart';

class TelaCodigoAcesso extends StatefulWidget {
  const TelaCodigoAcesso({super.key});

  @override
  State<TelaCodigoAcesso> createState() => _TelaCodigoAcessoState();
}

class _TelaCodigoAcessoState extends State<TelaCodigoAcesso> {
  final TextEditingController _codigoController = TextEditingController();
  String? mensagemErro;

  void validarCodigo() {
    final codigo = _codigoController.text.trim();

    if (codigo == 'PAC123') {
      Navigator.pushNamed(context, '/cadastro_paciente');
    } else if (codigo == 'CUID456') {
      Navigator.pushNamed(context, '/cadastro_cuidador');
    } else {
      setState(() {
        mensagemErro = 'Código inválido. Verifique com o enfermeiro.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Código de Acesso")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Center(child: Image.asset('assets/logo_oxycare.png', height: 40)),
            const SizedBox(height: 40),
            const Text(
              "Digite o código fornecido pelo enfermeiro para continuar",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codigoController,
              decoration: InputDecoration(
                labelText: "Código de Acesso",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (mensagemErro != null)
              Text(
                mensagemErro!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: validarCodigo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text("Validar"),
            ),
          ],
        ),
      ),
    );
  }
}
