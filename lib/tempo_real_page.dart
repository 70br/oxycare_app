import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'historico_page.dart';

class TempoRealPage extends StatefulWidget {
  final int idPerfilSelecionado;
  final String nomePerfil;

  const TempoRealPage({
    required this.idPerfilSelecionado,
    required this.nomePerfil,
    Key? key,
  }) : super(key: key);

  @override
  _TempoRealPageState createState() => _TempoRealPageState();
}

class _TempoRealPageState extends State<TempoRealPage> {
  int frequenciaCardiaca = 0;
  double temperatura = 0.0;
  int frequenciaRespiratoria = 0;
  String ultimaAtualizacao = "--/--/---- às --:--:--";
  late String nomePerfil;
  late int idPerfilSelecionado;
  bool conectado = false;
  BluetoothDevice? dispositivoConectado;
  StreamSubscription<List<int>>? _subscription;

  final String urlServidor = "http://silvaelias.ddns.net/oxycare/api/receber_dados.php";

  final Guid uuidServico = Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  final Guid uuidCaracteristica = Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");

  @override
  void initState() {
    super.initState();
    idPerfilSelecionado = widget.idPerfilSelecionado;
    nomePerfil = widget.nomePerfil;
    salvarPerfilLocal(idPerfilSelecionado, nomePerfil); // novo
    iniciarBluetooth();
  }

  void salvarPerfilLocal(int id, String nome) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('idPerfilSelecionado', id);
    await prefs.setString('nomePerfil', nome);
  }

  void iniciarBluetooth() async {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((r) async {
      for (ScanResult r in r) {
        if (r.device.name.contains("PROTOTIPO") || r.device.name.contains("OXYSENSOR")) {
          FlutterBluePlus.stopScan();
          await r.device.connect();
          setState(() {
            conectado = true;
            dispositivoConectado = r.device;
          });
          descobrirServicos(r.device);
          break;
        }
      }
    });
  }

  void descobrirServicos(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService s in services) {
      if (s.uuid == uuidServico) {
        for (BluetoothCharacteristic c in s.characteristics) {
          if (c.uuid == uuidCaracteristica) {
            await c.setNotifyValue(true);
            _subscription = c.onValueReceived.listen((value) {
              String dados = utf8.decode(value);
              atualizarDados(dados);
            });
          }
        }
      }
    }
  }

  void atualizarDados(String dados) {
    try {
      List<String> partes = dados.trim().split(';');
      int bpm = int.parse(partes[0]);
      double temp = double.parse(partes[1]);
      int spo2 = int.parse(partes[2]);

      setState(() {
        frequenciaCardiaca = bpm;
        temperatura = temp;
        frequenciaRespiratoria = spo2;
        ultimaAtualizacao = DateTime.now().toString().substring(0, 19).replaceFirst('T', ' às ');
      });

      enviarParaServidor(bpm, spo2, temp);
    } catch (e) {
      print("Erro ao processar dados recebidos: $e");
    }
  }

  Future<void> enviarParaServidor(int bpm, int spo2, double temp) async {
    final dados = {
      "paciente_id": idPerfilSelecionado,
      "batimentos": bpm,
      "spo2": spo2,
      "temperatura": temp
    };

    try {
      await http.post(
        Uri.parse(urlServidor),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dados),
      );
    } catch (e) {
      print("Erro ao enviar para servidor: $e");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    dispositivoConectado?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 40),
          Center(child: Image.asset('assets/logo_oxycare.png', height: 40)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 12, color: conectado ? Colors.green : Colors.red),
              SizedBox(width: 6),
              Text(
                conectado ? 'Conectado ao PROTOTIPO' : 'Não conectado... Aguarde conexão',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildCard("Freq. Cardíaca", frequenciaCardiaca.toString(), "bpm", Icons.favorite, Colors.pink),
          _buildCard("Temperatura", temperatura.toStringAsFixed(1), "ºC", Icons.thermostat, Colors.orange),
          _buildCard("Freq. Respiratória", frequenciaRespiratoria.toString(), "%", Icons.air, Colors.purple),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 16, color: Colors.blue),
              SizedBox(width: 4),
              Text("Última atualização: $ultimaAtualizacao")
            ],
          ),
          SizedBox(height: 8),
          Text("Perfil Selecionado:", style: TextStyle(fontSize: 14)),
          Text(nomePerfil, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              final resultado = await Navigator.pushNamed(context, '/listar_perfis');
              if (resultado != null && resultado is Map<String, dynamic>) {
                setState(() {
                  idPerfilSelecionado = resultado['id'];
                  nomePerfil = resultado['nome'];
                });

                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('idPerfilSelecionado', idPerfilSelecionado);
                await prefs.setString('nomePerfil', nomePerfil);
              }
            },
            child: Text("Alterar Perfil"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: Size(200, 45),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/listar_perfis');
          if (index == 2) Navigator.pushNamed(context, '/conexao');
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HistoricoPage(
                  idPerfilSelecionado: idPerfilSelecionado,
                  nomePerfil: nomePerfil,
                ),
              ),
            );
          }
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

  Widget _buildCard(String titulo, String valor, String unidade, IconData icon, Color color) {
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
                    Text(valor, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
