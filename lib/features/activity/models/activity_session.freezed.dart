// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ActivitySession _$ActivitySessionFromJson(Map<String, dynamic> json) {
  return _ActivitySession.fromJson(json);
}

/// @nodoc
mixin _$ActivitySession {
  ActivityType get type => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  int get steps => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;

  /// Serializes this ActivitySession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivitySessionCopyWith<ActivitySession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivitySessionCopyWith<$Res> {
  factory $ActivitySessionCopyWith(
          ActivitySession value, $Res Function(ActivitySession) then) =
      _$ActivitySessionCopyWithImpl<$Res, ActivitySession>;
  @useResult
  $Res call({ActivityType type, int duration, int steps, DateTime startTime});
}

/// @nodoc
class _$ActivitySessionCopyWithImpl<$Res, $Val extends ActivitySession>
    implements $ActivitySessionCopyWith<$Res> {
  _$ActivitySessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? duration = null,
    Object? steps = null,
    Object? startTime = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivitySessionImplCopyWith<$Res>
    implements $ActivitySessionCopyWith<$Res> {
  factory _$$ActivitySessionImplCopyWith(_$ActivitySessionImpl value,
          $Res Function(_$ActivitySessionImpl) then) =
      __$$ActivitySessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ActivityType type, int duration, int steps, DateTime startTime});
}

/// @nodoc
class __$$ActivitySessionImplCopyWithImpl<$Res>
    extends _$ActivitySessionCopyWithImpl<$Res, _$ActivitySessionImpl>
    implements _$$ActivitySessionImplCopyWith<$Res> {
  __$$ActivitySessionImplCopyWithImpl(
      _$ActivitySessionImpl _value, $Res Function(_$ActivitySessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? duration = null,
    Object? steps = null,
    Object? startTime = null,
  }) {
    return _then(_$ActivitySessionImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ActivityType,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivitySessionImpl implements _ActivitySession {
  const _$ActivitySessionImpl(
      {required this.type,
      required this.duration,
      required this.steps,
      required this.startTime});

  factory _$ActivitySessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivitySessionImplFromJson(json);

  @override
  final ActivityType type;
  @override
  final int duration;
  @override
  final int steps;
  @override
  final DateTime startTime;

  @override
  String toString() {
    return 'ActivitySession(type: $type, duration: $duration, steps: $steps, startTime: $startTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivitySessionImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.steps, steps) || other.steps == steps) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, duration, steps, startTime);

  /// Create a copy of ActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivitySessionImplCopyWith<_$ActivitySessionImpl> get copyWith =>
      __$$ActivitySessionImplCopyWithImpl<_$ActivitySessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivitySessionImplToJson(
      this,
    );
  }
}

abstract class _ActivitySession implements ActivitySession {
  const factory _ActivitySession(
      {required final ActivityType type,
      required final int duration,
      required final int steps,
      required final DateTime startTime}) = _$ActivitySessionImpl;

  factory _ActivitySession.fromJson(Map<String, dynamic> json) =
      _$ActivitySessionImpl.fromJson;

  @override
  ActivityType get type;
  @override
  int get duration;
  @override
  int get steps;
  @override
  DateTime get startTime;

  /// Create a copy of ActivitySession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivitySessionImplCopyWith<_$ActivitySessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
