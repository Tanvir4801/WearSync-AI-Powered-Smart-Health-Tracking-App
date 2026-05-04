import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../models/ble_device_item.dart';

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
    required this.device,
    required this.status,
    required this.onConnect,
  });

  final BleDeviceItem device;
  final BleConnectionStatus status;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final String buttonLabel = switch (status) {
      BleConnectionStatus.connecting => 'Connecting...',
      BleConnectionStatus.connected => 'Connected',
      BleConnectionStatus.disconnected => 'Connect',
    };
    final bool disableConnect = status != BleConnectionStatus.disconnected;
    final int signal = device.rssi ?? -120;

    return GlassmorphismCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryAccent.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.bluetooth, color: AppTheme.primaryAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  device.displayName,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  device.id,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                _SignalBars(rssi: signal),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: disableConnect ? null : onConnect,
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.rssi});

  final int rssi;

  @override
  Widget build(BuildContext context) {
    final int level = _levelFromRssi(rssi);

    return Row(
      children: List<Widget>.generate(4, (int index) {
        final bool active = index < level;
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 6,
          height: 8 + (index * 3),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.secondaryAccent
                : AppTheme.textSecondary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  int _levelFromRssi(int value) {
    if (value >= -60) return 4;
    if (value >= -72) return 3;
    if (value >= -84) return 2;
    if (value >= -96) return 1;
    return 0;
  }
}
