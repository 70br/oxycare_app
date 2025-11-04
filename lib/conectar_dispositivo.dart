import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:oxycare_app/states/ble_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'utils.dart' as Utils;

class ConectarDispositivoPage extends StatefulWidget {
  const ConectarDispositivoPage({super.key});
  @override
  State<ConectarDispositivoPage> createState() => _ConectarDispositivoPageState();
}

class _ConectarDispositivoPageState extends State<ConectarDispositivoPage> {
  bool escaneando = false;
  String dispositivoConnecting = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> pedirPermissoes() async {
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
  }

  
  void escanearDispositivos(BleState state) async {
    await pedirPermissoes();
    setState(() {
      escaneando = true;
      state.lastResults.clear();
    });

    var subscription = FlutterBluePlus.onScanResults.listen((results) async {
      if (results.isNotEmpty) {
        state.updateScanResults(results);
      } else {
        List<BluetoothDevice> connectedDevices = FlutterBluePlus.connectedDevices;
        List<ScanResult> scanResults = [];

        for (BluetoothDevice device in connectedDevices) {
          
          if(device.servicesList.any((dev) => dev.uuid == Guid(Utils.HardwareCharacteristics.service))) {
            scanResults.add(
              ScanResult(
                device: device,
                advertisementData: AdvertisementData(
                  advName: device.advName,
                  connectable: true,
                  txPowerLevel: 1,
                  appearance: 1,
                  manufacturerData: {},
                  serviceData: {},
                  serviceUuids: [],
                ),
                rssi: 0,
                timeStamp: DateTime.now()
              )
            );
          }
          if(state.device == null) {
            state.setConnected(device);
          }
        }
        if(scanResults.length > 0) {
          state.updateScanResults(scanResults);
        }
      }
      
    });
    FlutterBluePlus.cancelWhenScanComplete(subscription);

    await FlutterBluePlus.startScan(
      timeout: Duration(seconds: 8),
      withServices: [Guid(Utils.HardwareCharacteristics.service)],
    );

    await Future.delayed(Duration(seconds: 8));
    setState(() {
      escaneando = false;
    });
  }

  void alterarConexao(BluetoothDevice device, BleState state) async {
    try {
      if(state.device == device) {
        await state.setDisconnected();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Desconectado com sucesso"),
        ));
      } else {
        setState(() {
          dispositivoConnecting = device.platformName;
        });
        await device.connect(autoConnect: false);
        state.setConnected(device);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Conectado com sucesso"),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Erro ao conectar"),
          backgroundColor: Colors.redAccent,
      ));
      print('Erro ao conectar: $e');
    } finally {
      setState(() {
        dispositivoConnecting = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bleState = Provider.of<BleState>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Column(
        children: [
          SizedBox(height: 50),
          Center(child: Image.asset('assets/logo_cuidar.png', height: 40)),
          SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle,
                    size: 12, color: bleState.connected ? Colors.green : Colors.red),
                SizedBox(width: 6),
                Text(
                  bleState.connected
                      ? 'Conectado com sucesso'
                      : 'Não conectado… Clique para conectar',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: escaneando ? null : () => escanearDispositivos(bleState),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
              itemCount: bleState.lastResults.length,
              itemBuilder: (context, index) {
                final dispositivo = bleState.lastResults[index];
                final nome = dispositivo.device.name.isNotEmpty
                    ? dispositivo.device.name
                    : 'Dispositivo desconhecido';
                final conectado = bleState.device?.platformName == nome;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                              Text(nome,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(index == 0
                                  ? 'Já conectado anteriormente'
                                  : 'Dispositivo novo'),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: dispositivoConnecting == nome ?
                          null : () => alterarConexao(dispositivo.device, bleState),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: conectado ? Colors.green : Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            dispositivoConnecting == nome ?
                            'Aguarde' :
                            conectado ?
                            'Desconectar' : 'Conectar',
                              style: TextStyle(color: Colors.white)),
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
    );
  }
}
