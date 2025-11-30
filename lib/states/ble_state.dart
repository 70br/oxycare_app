import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:oxycare_app/main.dart';
import 'package:oxycare_app/utils.dart';

class BleState extends ChangeNotifier {

  GlobalKey<NavigatorState> _navigatorKey;
  BleState(this._navigatorKey);

  bool connected = false;
  DateTime lastDisconnectionRequestDate = DateTime(1990);
  BluetoothDevice? device;
  List<ScanResult> lastResults = [];

  StreamSubscription<BluetoothConnectionState>? _subscriptionListener = null;
  StreamSubscription<List<int>>? _subscriptionCardio;
  StreamSubscription<List<int>>? _subscriptionTemperatura;
  StreamSubscription<List<int>>? _subscriptionRespiratoria;

  double freqRespiratoria = 0;
  int freqCardiaca = 0;
  double temperatura = 0;
  DateTime? lastUpdateTimestamp = null;
  Future<void> Function(double freqRespiratoria, double temperatura, int freqCardiaca)? _callback = null;

  final Guid uuidServico = Guid(HardwareCharacteristics.service);
  final Guid uuidFreqCardiaca = Guid(HardwareCharacteristics.heartRate);
  final Guid uuidFreqRespiratoria = Guid(HardwareCharacteristics.respiratoryRate);
  final Guid uuidTemperatura = Guid(HardwareCharacteristics.temperature);

  void setCallBack(Future<void> Function(double freqRespiratoria, double temperatura, int freqCardiaca)? callback) {
    _callback = callback;
  }


  Future setDisconnected() async {
    if(device != null) {
      await _subscriptionCardio?.cancel();
      await _subscriptionTemperatura?.cancel();
      await _subscriptionRespiratoria?.cancel();

      await Future.delayed(const Duration(milliseconds: 400));
      lastDisconnectionRequestDate = DateTime.now();
      await device?.disconnect();
      connected = false;
      device = null;
      _callback = null;
      notifyListeners();
    }
  }

  Future setConnected(BluetoothDevice connectedDevice) async {
    connected = true;
    device = connectedDevice;
    
    _subscriptionListener ??= connectedDevice.connectionState.listen((state) async {
        if(
            state == BluetoothConnectionState.disconnected &&
            // Verifica se a conexão foi perdida ou solicitada
            DateTime.now().difference(lastDisconnectionRequestDate).inSeconds > 5
          ) {
          print("Executando...");
          await _subscriptionCardio?.cancel();
          await _subscriptionTemperatura?.cancel();
          await _subscriptionRespiratoria?.cancel();
          await _subscriptionListener?.cancel();
          connected = false;
          device = null;
          _callback = null;
          lastDisconnectionRequestDate = DateTime.now();
          _subscriptionListener = null;
          notifyListeners();
          _showAlert();
        }
      });
  

    await _watchServicos(connectedDevice);
    notifyListeners();
  }

  void updateScanResults(List<ScanResult> results) {
    lastResults = results;
    notifyListeners();
  }


  String _decode(List<int> value) {
    return utf8.decode(value);
  }

  Future _watchServicos(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService s in services) {
      if (s.uuid == uuidServico) {
        for (BluetoothCharacteristic c in s.characteristics) {
          if (c.uuid == uuidFreqCardiaca) {
              await c.setNotifyValue(true);
              _subscriptionCardio = c.onValueReceived.listen((value) {
                freqCardiaca = int.parse(_decode(value));
                notifyListeners();
              });
          }
          if (c.uuid == uuidFreqRespiratoria) {
              await c.setNotifyValue(true);
              _subscriptionRespiratoria = c.onValueReceived.listen((value) {
                freqRespiratoria = double.parse(_decode(value));
                notifyListeners();
            });
          }
          if (c.uuid == uuidTemperatura) {
              await c.setNotifyValue(true);
              _subscriptionRespiratoria = c.onValueReceived.listen((value) {
                temperatura = double.parse(_decode(value));
                lastUpdateTimestamp = DateTime.now();
                if(_callback != null) _callback!(freqRespiratoria, temperatura, freqCardiaca);
                notifyListeners();
              });
          }
        }
      }
    }
  }

void _showAlert() {
  showDialog(
    context: navigatorKey.currentContext!, // Assuming you have a navigatorKey
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Conexão perdida"),
        content: Text("Algo aconteceu e a conexão com o aparelho Cuidar+ foi perdida"),
        actions: <Widget>[
          TextButton(
            child: Text('Entendi'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
}