import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConexaoPage extends StatefulWidget {
  @override
  _ConexaoPageState createState() => _ConexaoPageState();
}

class _ConexaoPageState extends State<ConexaoPage> {
  List<ScanResult> dispositivos = [];
  bool escaneando = false;
  bool conectado = false;

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        setState(() {
          conectado = false;
        });
      }
    });
  }

  void escanearDispositivos() async {
    setState(() {
      escaneando = true;
      dispositivos.clear();
    });

    await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        dispositivos = results;
      });
    });

    await Future.delayed(Duration(seconds: 4));
    FlutterBluePlus.stopScan();

    setState(() {
      escaneando = false;
    });
  }

  void conectarDispositivo(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        conectado = true;
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
                Icon(Icons.circle, size: 12, color: conectado ? Colors.green : Colors.red),
                SizedBox(width: 6),
                Text(
                  conectado ? 'Conectado com sucesso' : 'Não conectado… Clique para conectar',
                  style: TextStyle(fontSize: 14),
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
       onTap: (index) {
         if (index == 0) Navigator.pushNamed(context, '/envio');
         if (index == 1) Navigator.pushNamed(context, '/listar_perfis');
         if (index == 2) return;
         if (index == 3) Navigator.pushNamed(context, '/historico');
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Tempo Real'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfis'),
          BottomNavigationBarItem(icon: Icon(Icons.bluetooth), label: 'Conexão'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
        ],
      ),
    );
  }
}
