import 'dart:async';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:oxycare_app/utils.dart';

class BleState extends ChangeNotifier {
  bool connected = false;
  BluetoothDevice? device;
  List<ScanResult> lastResults = [];

  StreamSubscription<List<int>>? _subscriptionCardio;
  StreamSubscription<List<int>>? _subscriptionTemperatura;
  StreamSubscription<List<int>>? _subscriptionRespiratoria;

  double freqRespiratoria = 0;
  int freqCardiaca = 0;
  double temperatura = 0;
  DateTime? lastUpdateTimestamp = null;
  Future<void> Function(double freqRespiratoria, double temperatura, int freqCardiaca)? callback = null;

  final Guid uuidServico = Guid(HardwareCharacteristics.service);
  final Guid uuidFreqCardiaca = Guid(HardwareCharacteristics.heartRate);
  final Guid uuidFreqRespiratoria = Guid(HardwareCharacteristics.respiratoryRate);
  final Guid uuidTemperatura = Guid(HardwareCharacteristics.temperature);

  void setCallBack(Future<void> Function(double freqRespiratoria, double temperatura, int freqCardiaca)? callback) {
    callback = callback;
  }


  Future setDisconnected() async {
    if(device != null) {
      await _subscriptionCardio?.cancel();
      await _subscriptionTemperatura?.cancel();
      await _subscriptionRespiratoria?.cancel();

      await Future.delayed(const Duration(milliseconds: 400));
      await device?.disconnect();
      connected = false;
      device = null;
      callback = null;
      notifyListeners();
    }
  }

  Future setConnected(BluetoothDevice connectedDevice) async {
    connected = true;
    device = connectedDevice;
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
                if(callback != null) callback!(freqRespiratoria, temperatura, freqCardiaca);
                notifyListeners();
              });
          }
        }
      }
    }
  }

}