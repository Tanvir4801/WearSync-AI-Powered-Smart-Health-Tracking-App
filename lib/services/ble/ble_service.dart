import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleService {
  BluetoothDevice? _connectedDevice;

  BluetoothDevice? get connectedDevice => _connectedDevice;

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  Future<bool> ensurePermissions() async {
    final List<Permission> permissions = <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    final Map<Permission, PermissionStatus> statuses =
        await permissions.request();
    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 20), mtu: null);
    _connectedDevice = device;
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    await device.disconnect();
    if (_connectedDevice?.remoteId == device.remoteId) {
      _connectedDevice = null;
    }
  }

  Stream<BluetoothConnectionState> deviceState(BluetoothDevice device) {
    return device.connectionState;
  }

  Future<bool> ensureBluetoothIsOn() async {
    final BluetoothAdapterState current = await _currentAdapterState();
    if (current == BluetoothAdapterState.on) {
      return true;
    }

    try {
      await FlutterBluePlus.turnOn();
    } catch (_) {
      // Some platforms cannot trigger turn-on directly.
    }

    final BluetoothAdapterState afterRequest = await _currentAdapterState();
    return afterRequest == BluetoothAdapterState.on;
  }

  Future<BluetoothAdapterState> _currentAdapterState() async {
    return adapterState
        .where((BluetoothAdapterState state) =>
            state != BluetoothAdapterState.unknown)
        .first
        .timeout(
          const Duration(seconds: 3),
          onTimeout: () => BluetoothAdapterState.unknown,
        );
  }
}
