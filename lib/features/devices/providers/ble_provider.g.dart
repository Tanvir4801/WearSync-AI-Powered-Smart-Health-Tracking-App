// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bleServiceHash() => r'ce634598cb8f548f4edf7a7cd068ec14e230b179';

/// See also [bleService].
@ProviderFor(bleService)
final bleServiceProvider = AutoDisposeProvider<BleService>.internal(
  bleService,
  name: r'bleServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bleServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BleServiceRef = AutoDisposeProviderRef<BleService>;
String _$bleControllerHash() => r'64868228764a8fb79f640dc9078ccef220173c9e';

/// See also [BleController].
@ProviderFor(BleController)
final bleControllerProvider =
    AutoDisposeNotifierProvider<BleController, BleState>.internal(
  BleController.new,
  name: r'bleControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bleControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BleController = AutoDisposeNotifier<BleState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
