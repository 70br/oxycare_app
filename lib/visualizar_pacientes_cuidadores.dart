import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VisualizarPacientesCuidadoresPage extends StatefulWidget {
  const VisualizarPacientesCuidadoresPage({super.key});

  @override
  State<VisualizarPacientesCuidadoresPage> createState() => _VisualizarPacientesCuidadoresPageState();
}

class _VisualizarPacientesCuidadoresPageState extends State<VisualizarPacientesCuidadoresPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> pacientes = [];
  List<dynamic> cuidadores = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    carregarDados();
  }

  Future<void> carregarDados() async {
    final url = Uri.parse('http://silvaelias.ddns.net/oxycare/api/listar_pacientes_cuidadores.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        pacientes = data['pacientes'];
        cuidadores = data['cuidadores'];
        carregando = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados.')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildListaPacientes() {
    return ListView.builder(
      itemCount: pacientes.length,
      itemBuilder: (context, index) {
        final paciente = pacientes[index];
        return ListTile(
          leading: const Icon(Icons.person, color: Colors.teal),
          title: Text(paciente['nome']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email: ${paciente['email']}"),
              Text("Telefone: ${paciente['telefone']}"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListaCuidadores() {
    return ListView.builder(
      itemCount: cuidadores.length,
      itemBuilder: (context, index) {
        final cuidador = cuidadores[index];
        return ListTile(
          leading: const Icon(Icons.group, color: Colors.indigo),
          title: Text(cuidador['nome']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email: ${cuidador['email']}"),
              Text("Telefone: ${cuidador['telefone']}"),
              Text("Paciente vinculado: ${cuidador['paciente_nome'] ?? 'Não vinculado'}"),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes & Cuidadores'),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pacientes'),
            Tab(text: 'Cuidadores'),
          ],
        ),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                Center(child: Image.asset('assets/logo_oxycare.png', height: 50)),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListaPacientes(),
                      _buildListaCuidadores(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
