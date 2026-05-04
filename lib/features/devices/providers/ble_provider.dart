import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/ble_device_item.dart';
import '../../../services/ble/ble_service.dart';

part 'ble_provider.g.dart';

class BleState {
  const BleState({
    required this.devices,
    required this.connectedDevice,
    required this.connectionStatuses,
    required this.isScanning,
    required this.permissionDenied,
    required this.bluetoothOff,
    required this.showingDemoDevice,
    this.errorMessage,
  });

  const BleState.initial()
      : devices = const AsyncValue<List<BleDeviceItem>>.data(<BleDeviceItem>[]),
        connectedDevice = null,
        connectionStatuses = const <String, BleConnectionStatus>{},
        isScanning = false,
        permissionDenied = false,
        bluetoothOff = false,
        showingDemoDevice = false,
        errorMessage = null;

  final AsyncValue<List<BleDeviceItem>> devices;
  final BleDeviceItem? connectedDevice;
  final Map<String, BleConnectionStatus> connectionStatuses;
  final bool isScanning;
  final bool permissionDenied;
  final bool bluetoothOff;
  final bool showingDemoDevice;
  final String? errorMessage;

  BleState copyWith({
    AsyncValue<List<BleDeviceItem>>? devices,
    BleDeviceItem? connectedDevice,
    bool clearConnected = false,
    Map<String, BleConnectionStatus>? connectionStatuses,
    bool? isScanning,
    bool? permissionDenied,
    bool? bluetoothOff,
    bool? showingDemoDevice,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BleState(
      devices: devices ?? this.devices,
      connectedDevice:
          clearConnected ? null : (connectedDevice ?? this.connectedDevice),
      connectionStatuses: connectionStatuses ?? this.connectionStatuses,
      isScanning: isScanning ?? this.isScanning,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      bluetoothOff: bluetoothOff ?? this.bluetoothOff,
      showingDemoDevice: showingDemoDevice ?? this.showingDemoDevice,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
BleService bleService(Ref ref) => BleService();

@riverpod
class BleController extends _$BleController {
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _isScanningSub;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSub;
  final Map<String, StreamSubscription<BluetoothConnectionState>>
      _connectionStateSubs =
      <String, StreamSubscription<BluetoothConnectionState>>{};

  BleService get _service => ref.read(bleServiceProvider);

  @override
  BleState build() {
    _listenToScanResults();
    _listenToScanning();
    _listenToAdapterState();
    ref.onDispose(() {
      _scanSub?.cancel();
      _isScanningSub?.cancel();
      _adapterStateSub?.cancel();
      for (final StreamSubscription<BluetoothConnectionState> sub
          in _connectionStateSubs.values) {
        sub.cancel();
      }
      _connectionStateSubs.clear();
    });
    return const BleState.initial();
  }

  void _listenToScanResults() {
    _scanSub?.cancel();
    _scanSub = _service.scanResults.listen(
      (List<ScanResult> results) {
        final List<BleDeviceItem> mapped = _deduplicateResults(results);
        state = state.copyWith(
          devices: AsyncValue<List<BleDeviceItem>>.data(mapped),
          showingDemoDevice: false,
          clearError: true,
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        state = state.copyWith(
          devices: AsyncValue<List<BleDeviceItem>>.error(error, stackTrace),
          errorMessage: error.toString(),
        );
      },
    );
  }

  void _listenToScanning() {
    _isScanningSub?.cancel();
    _isScanningSub = _service.isScanning.listen((bool scanning) {
      state = state.copyWith(isScanning: scanning);
    });
  }

  void _listenToAdapterState() {
    _adapterStateSub?.cancel();
    _adapterStateSub = _service.adapterState.listen(
      (BluetoothAdapterState adapterState) {
        final bool isOff = adapterState != BluetoothAdapterState.on;
        state = state.copyWith(
          bluetoothOff: isOff,
          isScanning: isOff ? false : state.isScanning,
          errorMessage: isOff
              ? 'Bluetooth is off. Turn it on to connect your smartwatch.'
              : null,
        );
      },
    );
  }

  Future<void> startScan() async {
    state = state.copyWith(
      devices: const AsyncValue<List<BleDeviceItem>>.loading(),
      showingDemoDevice: false,
      permissionDenied: false,
      clearError: true,
    );

    final bool granted = await _service.ensurePermissions();
    if (!granted) {
      state = state.copyWith(
        permissionDenied: true,
        isScanning: false,
        devices: const AsyncValue<List<BleDeviceItem>>.data(<BleDeviceItem>[]),
        errorMessage: 'Bluetooth permissions are required to scan devices.',
      );
      return;
    }

    final bool bluetoothOn = await _service.ensureBluetoothIsOn();
    if (!bluetoothOn) {
      state = state.copyWith(
        bluetoothOff: true,
        isScanning: false,
        devices: const AsyncValue<List<BleDeviceItem>>.data(<BleDeviceItem>[]),
        errorMessage: 'Please turn on Bluetooth to connect your smartwatch.',
      );
      return;
    }

    try {
      await _service.startScan();
      state = state.copyWith(permissionDenied: false, bluetoothOff: false);
      _addDemoDeviceIfNoResults();
    } catch (error, stackTrace) {
      state = state.copyWith(
        isScanning: false,
        devices: AsyncValue<List<BleDeviceItem>>.error(error, stackTrace),
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> stopScan() async {
    await _service.stopScan();
  }

  Future<void> connect(BleDeviceItem deviceItem) async {
    _setConnectionStatus(deviceItem.id, BleConnectionStatus.connecting);

    if (deviceItem.isDemo || deviceItem.device == null) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      _setConnectionStatus(deviceItem.id, BleConnectionStatus.connected);
      state = state.copyWith(connectedDevice: deviceItem, clearError: true);
      return;
    }

    try {
      _listenToConnectionState(deviceItem);
      await _service.connectToDevice(deviceItem.device!);
      state = state.copyWith(
        connectedDevice: deviceItem,
        clearError: true,
      );
    } catch (error) {
      _setConnectionStatus(deviceItem.id, BleConnectionStatus.disconnected);
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> disconnect(BleDeviceItem deviceItem) async {
    if (deviceItem.isDemo || deviceItem.device == null) {
      _setConnectionStatus(deviceItem.id, BleConnectionStatus.disconnected);
      state = state.copyWith(clearConnected: true);
      return;
    }

    try {
      await _service.disconnectDevice(deviceItem.device!);
      _setConnectionStatus(deviceItem.id, BleConnectionStatus.disconnected);
      state = state.copyWith(clearConnected: true);
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> requestTurnOnBluetooth() async {
    final bool turnedOn = await _service.ensureBluetoothIsOn();
    state = state.copyWith(
      bluetoothOff: !turnedOn,
      errorMessage: turnedOn
          ? null
          : 'Bluetooth is still off. Please enable it from system settings.',
    );
  }

  List<BleDeviceItem> _deduplicateResults(List<ScanResult> results) {
    final Map<String, BleDeviceItem> byId = <String, BleDeviceItem>{};

    for (final ScanResult result in results) {
      final BluetoothDevice device = result.device;
      final String id = device.remoteId.str;
      byId[id] = BleDeviceItem(
        id: id,
        name: device.platformName,
        device: device,
        rssi: result.rssi,
      );
    }

    return byId.values.toList(growable: false);
  }

  void _addDemoDeviceIfNoResults() {
    final List<BleDeviceItem> current =
        state.devices.valueOrNull ?? <BleDeviceItem>[];
    if (current.isNotEmpty) {
      return;
    }

    const BleDeviceItem demo = BleDeviceItem(
      id: '00:11:22:33:44',
      name: 'WearSync Watch',
      isDemo: true,
    );

    state = state.copyWith(
      devices:
          const AsyncValue<List<BleDeviceItem>>.data(<BleDeviceItem>[demo]),
      showingDemoDevice: true,
    );
  }

  void _listenToConnectionState(BleDeviceItem deviceItem) {
    final String id = deviceItem.id;
    _connectionStateSubs[id]?.cancel();

    _connectionStateSubs[id] = deviceItem.device!.connectionState.listen(
      (BluetoothConnectionState connectionState) {
        if (connectionState == BluetoothConnectionState.connected) {
          _setConnectionStatus(id, BleConnectionStatus.connected);
          state = state.copyWith(connectedDevice: deviceItem, clearError: true);
        } else {
          _setConnectionStatus(id, BleConnectionStatus.disconnected);
          if (state.connectedDevice?.id == id) {
            state = state.copyWith(clearConnected: true);
          }
        }
      },
      onError: (Object error) {
        _setConnectionStatus(id, BleConnectionStatus.disconnected);
        state = state.copyWith(errorMessage: error.toString());
      },
    );
  }

  void _setConnectionStatus(String deviceId, BleConnectionStatus status) {
    final Map<String, BleConnectionStatus> next =
        Map<String, BleConnectionStatus>.of(state.connectionStatuses);
    next[deviceId] = status;
    state = state.copyWith(connectionStatuses: next);
  }
}
