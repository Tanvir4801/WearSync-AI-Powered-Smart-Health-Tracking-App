import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum BleConnectionStatus {
  disconnected,
  connecting,
  connected,
}

class BleDeviceItem {
  const BleDeviceItem({
    required this.id,
    required this.name,
    this.device,
    this.rssi,
    this.isDemo = false,
  });

  final String id;
  final String name;
  final BluetoothDevice? device;
  final int? rssi;
  final bool isDemo;

  String get displayName =>
      name.trim().isEmpty ? 'Unknown Device' : name.trim();
}
