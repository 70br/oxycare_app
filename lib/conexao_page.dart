import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConexaoPage extends StatefulWidget {
  final bool voltarParaDashboard; // NOVO

  const ConexaoPage({Key? key, this.voltarParaDashboard = false}) : super(key: key);

  @override
  _ConexaoPageState createState() => _ConexaoPageState();
}

class _ConexaoPageState extends State<ConexaoPage> {
  List<ScanResult> dispositivos = [];
  bool escaneando = false;
  bool conectado = false;

  // NOVO: variáveis de status e cor
  String statusConexao = "Não conectado... Clique para conectar";
  Color corStatus = Colors.red;

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        setState(() {
          conectado = false;
          statusConexao = "Não conectado... Clique para conectar";
          corStatus = Colors.red;
        });
      }
    });
  }

  void escanearDispositivos() async {
    setState(() {
      escaneando = true;
      dispositivos.clear();
      // NOVO: muda status para laranja "Escaneando..."
      statusConexao = "Escaneando...";
      corStatus = Colors.orange;
    });

    await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        dispositivos = results;
      });
    });

    await Future.delayed(Duration(seconds: 4));
    FlutterBluePlus.stopScan();

    // NOVO: se não conectou e terminou scan
    if (!conectado) {
      setState(() {
        escaneando = false;
        statusConexao = "Não conectado... Clique para conectar";
        corStatus = Colors.red;
      });
    } else {
      setState(() {
        escaneando = false;
      });
    }
  }

  void conectarDispositivo(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        conectado = true;
        // NOVO: muda status para verde conectado
        statusConexao = "Conectado ao PROTOTIPO";
        corStatus = Colors.green;
      });
    } catch (e) {
      print('Erro ao conectar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Column(
        children: [
          SizedBox(height: 50),
          Center(child: Image.asset('assets/logo_oxycare.png', height: 40)),
          SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 12, color: corStatus),
                SizedBox(width: 6),
                Text(
                  statusConexao,
                  style: TextStyle(fontSize: 14, color: corStatus),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: escaneando ? null : escanearDispositivos,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                escaneando ? 'Escaneando...' : 'Escanear dispositivos',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: dispositivos.length,
              itemBuilder: (context, index) {
                final dispositivo = dispositivos[index];
                final nome = dispositivo.device.name.isNotEmpty
                    ? dispositivo.device.name
                    : 'Dispositivo desconhecido';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.settings, size: 24, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nome, style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(index == 0
                                  ? 'Já conectado anteriormente'
                                  : 'Dispositivo novo'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => conectarDispositivo(dispositivo.device),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('Conectar', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          final prefs = await SharedPreferences.getInstance();
          final idPerfil = prefs.getInt('idPerfilSelecionado');
          final nomePerfil = prefs.getString('nomePerfil');

          if (index == 0) {
            if (idPerfil != null && nomePerfil != null) {
              Navigator.pushReplacementNamed(
                context,
                '/tempoReal',
                arguments: {
                  'idPerfilSelecionado': idPerfil,
                  'nomePerfil': nomePerfil,
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selecione um perfil antes de acessar Tempo Real')),
              );
            }
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/listar_perfis');
          } else if (index == 2) {
            return;
          } else if (index == 3) {
            if (idPerfil != null && nomePerfil != null) {
              Navigator.pushReplacementNamed(
                context,
                '/historico',
                arguments: {
                  'idPerfilSelecionado': idPerfil,
                  'nomePerfil': nomePerfil,
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selecione um perfil antes de acessar Histórico')),
              );
            }
          } else if (widget.voltarParaDashboard && index == 4) {
            Navigator.pushReplacementNamed(context, '/dashboard_enfermeiro');
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Tempo Real'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfis'),
          BottomNavigationBarItem(icon: Icon(Icons.bluetooth), label: 'Conexão'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
          if (widget.voltarParaDashboard)
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        ],
      ),
    );
  }
}
