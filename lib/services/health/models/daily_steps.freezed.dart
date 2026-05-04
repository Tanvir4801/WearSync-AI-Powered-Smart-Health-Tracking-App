// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_steps.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailySteps _$DailyStepsFromJson(Map<String, dynamic> json) {
  return _DailySteps.fromJson(json);
}

/// @nodoc
mixin _$DailySteps {
  DateTime get date => throw _privateConstructorUsedError;
  int get steps => throw _privateConstructorUsedError;

  /// Serializes this DailySteps to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailySteps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyStepsCopyWith<DailySteps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStepsCopyWith<$Res> {
  factory $DailyStepsCopyWith(
          DailySteps value, $Res Function(DailySteps) then) =
      _$DailyStepsCopyWithImpl<$Res, DailySteps>;
  @useResult
  $Res call({DateTime date, int steps});
}

/// @nodoc
class _$DailyStepsCopyWithImpl<$Res, $Val extends DailySteps>
    implements $DailyStepsCopyWith<$Res> {
  _$DailyStepsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailySteps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? steps = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyStepsImplCopyWith<$Res>
    implements $DailyStepsCopyWith<$Res> {
  factory _$$DailyStepsImplCopyWith(
          _$DailyStepsImpl value, $Res Function(_$DailyStepsImpl) then) =
      __$$DailyStepsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, int steps});
}

/// @nodoc
class __$$DailyStepsImplCopyWithImpl<$Res>
    extends _$DailyStepsCopyWithImpl<$Res, _$DailyStepsImpl>
    implements _$$DailyStepsImplCopyWith<$Res> {
  __$$DailyStepsImplCopyWithImpl(
      _$DailyStepsImpl _value, $Res Function(_$DailyStepsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailySteps
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? steps = null,
  }) {
    return _then(_$DailyStepsImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStepsImpl implements _DailySteps {
  const _$DailyStepsImpl({required this.date, required this.steps});

  factory _$DailyStepsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStepsImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int steps;

  @override
  String toString() {
    return 'DailySteps(date: $date, steps: $steps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStepsImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.steps, steps) || other.steps == steps));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, steps);

  /// Create a copy of DailySteps
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStepsImplCopyWith<_$DailyStepsImpl> get copyWith =>
      __$$DailyStepsImplCopyWithImpl<_$DailyStepsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStepsImplToJson(
      this,
    );
  }
}

abstract class _DailySteps implements DailySteps {
  const factory _DailySteps(
      {required final DateTime date,
      required final int steps}) = _$DailyStepsImpl;

  factory _DailySteps.fromJson(Map<String, dynamic> json) =
      _$DailyStepsImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get steps;

  /// Create a copy of DailySteps
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyStepsImplCopyWith<_$DailyStepsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
