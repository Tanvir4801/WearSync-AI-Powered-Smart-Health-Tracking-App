import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../models/ble_device_item.dart';
import '../providers/ble_provider.dart';
import '../widgets/device_tile.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BleState state = ref.watch(bleControllerProvider);
    final BleController controller = ref.read(bleControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Devices',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const Spacer(),
                  Icon(Icons.bluetooth,
                      color: AppTheme.secondaryAccent.withValues(alpha: 0.95)),
                ],
              ),
              const SizedBox(height: 18),
              _ScanButton(
                isScanning: state.isScanning,
                onTap: () {
                  if (state.isScanning) {
                    controller.stopScan();
                  } else {
                    controller.startScan();
                  }
                },
              ),
              const SizedBox(height: 18),
              if (state.connectedDevice != null) ...<Widget>[
                _ConnectedCard(
                  device: state.connectedDevice!,
                  onDisconnect: () =>
                      controller.disconnect(state.connectedDevice!),
                ),
                const SizedBox(height: 14),
              ],
              if (state.permissionDenied) ...<Widget>[
                const _PermissionDeniedCard(),
                const SizedBox(height: 14),
              ],
              if (state.bluetoothOff) ...<Widget>[
                _BluetoothOffCard(
                  onTurnOn: controller.requestTurnOnBluetooth,
                ),
                const SizedBox(height: 14),
              ],
              Text('Nearby Devices',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (state.showingDemoDevice)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryAccent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.secondaryAccent.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    'No devices found -> showing demo device',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              const SizedBox(height: 10),
              Builder(
                builder: (BuildContext context) {
                  final AsyncValue<List<BleDeviceItem>> devicesValue =
                      state.devices;
                  final List<BleDeviceItem> devices =
                      devicesValue.valueOrNull ?? <BleDeviceItem>[];

                  if (state.isScanning &&
                      devicesValue.isLoading &&
                      devices.isEmpty) {
                    return const _ScanningSkeletonList();
                  }

                  if (devices.isEmpty) {
                    return const _EmptyState();
                  }

                  return ListView.separated(
                    itemCount: devices.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, int index) {
                      final BleDeviceItem device = devices[index];
                      final BleConnectionStatus status =
                          state.connectionStatuses[device.id] ??
                              BleConnectionStatus.disconnected;

                      return DeviceTile(
                        device: device,
                        status: status,
                        onConnect: () => controller.connect(device),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanButton extends StatefulWidget {
  const _ScanButton({required this.isScanning, required this.onTap});

  final bool isScanning;
  final VoidCallback onTap;

  @override
  State<_ScanButton> createState() => _ScanButtonState();
}

class _ScanButtonState extends State<_ScanButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.95,
      upperBound: 1.05,
    );
    if (widget.isScanning) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _ScanButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _pulseController.stop();
      _pulseController.value = 1;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseController,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: widget.onTap,
          child: Text(widget.isScanning ? 'Scanning...' : 'Scan for Devices'),
        ),
      ),
    );
  }
}

class _ConnectedCard extends StatelessWidget {
  const _ConnectedCard({required this.device, required this.onDisconnect});

  final BleDeviceItem device;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final String name = device.displayName;

    return GlassmorphismCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Connected',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onDisconnect,
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}

class _PermissionDeniedCard extends StatelessWidget {
  const _PermissionDeniedCard();

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Permission required',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Bluetooth scan/connect and location permissions are needed to discover nearby devices.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          const TextButton(
            onPressed: openAppSettings,
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class _BluetoothOffCard extends StatelessWidget {
  const _BluetoothOffCard({required this.onTurnOn});

  final Future<void> Function() onTurnOn;

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Bluetooth is off',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Turn on Bluetooth to connect your smartwatch.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onTurnOn,
            child: const Text('Turn On Bluetooth'),
          ),
        ],
      ),
    );
  }
}

class _ScanningSkeletonList extends StatefulWidget {
  const _ScanningSkeletonList();

  @override
  State<_ScanningSkeletonList> createState() => _ScanningSkeletonListState();
}

class _ScanningSkeletonListState extends State<_ScanningSkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.35,
      upperBound: 0.8,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Column(
          children: List<Widget>.generate(3, (int index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 82,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: _controller.value),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Icon(
              Icons.bluetooth_searching,
              size: 54,
              color: AppTheme.textSecondary.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 8),
            Text(
              'No devices found yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap scan to search nearby smartwatches.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
