import 'package:flutter/material.dart';

class TelaSelecaoTipo extends StatelessWidget {
  const TelaSelecaoTipo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F0F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'assets/logo_oxycare.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Quem é você?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.people, color: Colors.white),
                label: const Text(
                  "Sou Paciente ou Cuidador",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/codigo_acesso');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // ✅ azul aqui
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.medical_services, color: Colors.white),
                label: const Text(
                  "Sou Enfermeiro",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/cadastro_enfermeiro');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // ✅ azul aqui também
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
