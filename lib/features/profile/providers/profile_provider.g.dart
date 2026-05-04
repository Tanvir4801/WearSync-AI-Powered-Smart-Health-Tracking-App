// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'ed0872794ec8e4cb3f50cb37b9c0b9467eb51ddb';

/// See also [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$healthRepositoryHash() => r'9ace42d60e8dfed08c18677025cb8de1262d369f';

/// See also [healthRepository].
@ProviderFor(healthRepository)
final healthRepositoryProvider = AutoDisposeProvider<HealthRepository>.internal(
  healthRepository,
  name: r'healthRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$healthRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HealthRepositoryRef = AutoDisposeProviderRef<HealthRepository>;
String _$weekHealthDataHash() => r'03e19ef0f7d0c0fafc7ec3f70e3ad156ef2baa2d';

/// See also [weekHealthData].
@ProviderFor(weekHealthData)
final weekHealthDataProvider =
    AutoDisposeFutureProvider<List<HealthData>>.internal(
  weekHealthData,
  name: r'weekHealthDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weekHealthDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeekHealthDataRef = AutoDisposeFutureProviderRef<List<HealthData>>;
String _$profileControllerHash() => r'db9650cf82c1767b28b6353444a4064e8097716e';

/// See also [ProfileController].
@ProviderFor(ProfileController)
final profileControllerProvider =
    AutoDisposeNotifierProvider<ProfileController, ProfileState>.internal(
  ProfileController.new,
  name: r'profileControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileController = AutoDisposeNotifier<ProfileState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
