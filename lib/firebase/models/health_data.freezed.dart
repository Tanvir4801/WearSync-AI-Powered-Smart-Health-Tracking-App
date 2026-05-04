// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthData _$HealthDataFromJson(Map<String, dynamic> json) {
  return _HealthData.fromJson(json);
}

/// @nodoc
mixin _$HealthData {
  int get steps => throw _privateConstructorUsedError;
  int get calories => throw _privateConstructorUsedError;
  int get heartRateAvg => throw _privateConstructorUsedError;
  int get activeMinutes => throw _privateConstructorUsedError;
  int get waterGlasses => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this HealthData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthDataCopyWith<HealthData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthDataCopyWith<$Res> {
  factory $HealthDataCopyWith(
          HealthData value, $Res Function(HealthData) then) =
      _$HealthDataCopyWithImpl<$Res, HealthData>;
  @useResult
  $Res call(
      {int steps,
      int calories,
      int heartRateAvg,
      int activeMinutes,
      int waterGlasses,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$HealthDataCopyWithImpl<$Res, $Val extends HealthData>
    implements $HealthDataCopyWith<$Res> {
  _$HealthDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? steps = null,
    Object? calories = null,
    Object? heartRateAvg = null,
    Object? activeMinutes = null,
    Object? waterGlasses = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      heartRateAvg: null == heartRateAvg
          ? _value.heartRateAvg
          : heartRateAvg // ignore: cast_nullable_to_non_nullable
              as int,
      activeMinutes: null == activeMinutes
          ? _value.activeMinutes
          : activeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      waterGlasses: null == waterGlasses
          ? _value.waterGlasses
          : waterGlasses // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthDataImplCopyWith<$Res>
    implements $HealthDataCopyWith<$Res> {
  factory _$$HealthDataImplCopyWith(
          _$HealthDataImpl value, $Res Function(_$HealthDataImpl) then) =
      __$$HealthDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int steps,
      int calories,
      int heartRateAvg,
      int activeMinutes,
      int waterGlasses,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$HealthDataImplCopyWithImpl<$Res>
    extends _$HealthDataCopyWithImpl<$Res, _$HealthDataImpl>
    implements _$$HealthDataImplCopyWith<$Res> {
  __$$HealthDataImplCopyWithImpl(
      _$HealthDataImpl _value, $Res Function(_$HealthDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? steps = null,
    Object? calories = null,
    Object? heartRateAvg = null,
    Object? activeMinutes = null,
    Object? waterGlasses = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$HealthDataImpl(
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      heartRateAvg: null == heartRateAvg
          ? _value.heartRateAvg
          : heartRateAvg // ignore: cast_nullable_to_non_nullable
              as int,
      activeMinutes: null == activeMinutes
          ? _value.activeMinutes
          : activeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      waterGlasses: null == waterGlasses
          ? _value.waterGlasses
          : waterGlasses // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthDataImpl implements _HealthData {
  const _$HealthDataImpl(
      {required this.steps,
      required this.calories,
      required this.heartRateAvg,
      required this.activeMinutes,
      required this.waterGlasses,
      required this.createdAt,
      required this.updatedAt});

  factory _$HealthDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthDataImplFromJson(json);

  @override
  final int steps;
  @override
  final int calories;
  @override
  final int heartRateAvg;
  @override
  final int activeMinutes;
  @override
  final int waterGlasses;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'HealthData(steps: $steps, calories: $calories, heartRateAvg: $heartRateAvg, activeMinutes: $activeMinutes, waterGlasses: $waterGlasses, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthDataImpl &&
            (identical(other.steps, steps) || other.steps == steps) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.heartRateAvg, heartRateAvg) ||
                other.heartRateAvg == heartRateAvg) &&
            (identical(other.activeMinutes, activeMinutes) ||
                other.activeMinutes == activeMinutes) &&
            (identical(other.waterGlasses, waterGlasses) ||
                other.waterGlasses == waterGlasses) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, steps, calories, heartRateAvg,
      activeMinutes, waterGlasses, createdAt, updatedAt);

  /// Create a copy of HealthData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthDataImplCopyWith<_$HealthDataImpl> get copyWith =>
      __$$HealthDataImplCopyWithImpl<_$HealthDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthDataImplToJson(
      this,
    );
  }
}

abstract class _HealthData implements HealthData {
  const factory _HealthData(
      {required final int steps,
      required final int calories,
      required final int heartRateAvg,
      required final int activeMinutes,
      required final int waterGlasses,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$HealthDataImpl;

  factory _HealthData.fromJson(Map<String, dynamic> json) =
      _$HealthDataImpl.fromJson;

  @override
  int get steps;
  @override
  int get calories;
  @override
  int get heartRateAvg;
  @override
  int get activeMinutes;
  @override
  int get waterGlasses;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of HealthData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthDataImplCopyWith<_$HealthDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
