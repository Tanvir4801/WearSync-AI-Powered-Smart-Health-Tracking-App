// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'smart_insight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SmartInsight _$SmartInsightFromJson(Map<String, dynamic> json) {
  return _SmartInsight.fromJson(json);
}

/// @nodoc
mixin _$SmartInsight {
  String get headline => throw _privateConstructorUsedError;
  String get detail => throw _privateConstructorUsedError;
  String get suggestion => throw _privateConstructorUsedError;
  SmartInsightType get type => throw _privateConstructorUsedError;

  /// Serializes this SmartInsight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SmartInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SmartInsightCopyWith<SmartInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmartInsightCopyWith<$Res> {
  factory $SmartInsightCopyWith(
          SmartInsight value, $Res Function(SmartInsight) then) =
      _$SmartInsightCopyWithImpl<$Res, SmartInsight>;
  @useResult
  $Res call(
      {String headline,
      String detail,
      String suggestion,
      SmartInsightType type});
}

/// @nodoc
class _$SmartInsightCopyWithImpl<$Res, $Val extends SmartInsight>
    implements $SmartInsightCopyWith<$Res> {
  _$SmartInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SmartInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = null,
    Object? detail = null,
    Object? suggestion = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      headline: null == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String,
      detail: null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String,
      suggestion: null == suggestion
          ? _value.suggestion
          : suggestion // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SmartInsightType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SmartInsightImplCopyWith<$Res>
    implements $SmartInsightCopyWith<$Res> {
  factory _$$SmartInsightImplCopyWith(
          _$SmartInsightImpl value, $Res Function(_$SmartInsightImpl) then) =
      __$$SmartInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String headline,
      String detail,
      String suggestion,
      SmartInsightType type});
}

/// @nodoc
class __$$SmartInsightImplCopyWithImpl<$Res>
    extends _$SmartInsightCopyWithImpl<$Res, _$SmartInsightImpl>
    implements _$$SmartInsightImplCopyWith<$Res> {
  __$$SmartInsightImplCopyWithImpl(
      _$SmartInsightImpl _value, $Res Function(_$SmartInsightImpl) _then)
      : super(_value, _then);

  /// Create a copy of SmartInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = null,
    Object? detail = null,
    Object? suggestion = null,
    Object? type = null,
  }) {
    return _then(_$SmartInsightImpl(
      headline: null == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String,
      detail: null == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String,
      suggestion: null == suggestion
          ? _value.suggestion
          : suggestion // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SmartInsightType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SmartInsightImpl implements _SmartInsight {
  const _$SmartInsightImpl(
      {required this.headline,
      required this.detail,
      required this.suggestion,
      required this.type});

  factory _$SmartInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmartInsightImplFromJson(json);

  @override
  final String headline;
  @override
  final String detail;
  @override
  final String suggestion;
  @override
  final SmartInsightType type;

  @override
  String toString() {
    return 'SmartInsight(headline: $headline, detail: $detail, suggestion: $suggestion, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmartInsightImpl &&
            (identical(other.headline, headline) ||
                other.headline == headline) &&
            (identical(other.detail, detail) || other.detail == detail) &&
            (identical(other.suggestion, suggestion) ||
                other.suggestion == suggestion) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, headline, detail, suggestion, type);

  /// Create a copy of SmartInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SmartInsightImplCopyWith<_$SmartInsightImpl> get copyWith =>
      __$$SmartInsightImplCopyWithImpl<_$SmartInsightImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmartInsightImplToJson(
      this,
    );
  }
}

abstract class _SmartInsight implements SmartInsight {
  const factory _SmartInsight(
      {required final String headline,
      required final String detail,
      required final String suggestion,
      required final SmartInsightType type}) = _$SmartInsightImpl;

  factory _SmartInsight.fromJson(Map<String, dynamic> json) =
      _$SmartInsightImpl.fromJson;

  @override
  String get headline;
  @override
  String get detail;
  @override
  String get suggestion;
  @override
  SmartInsightType get type;

  /// Create a copy of SmartInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SmartInsightImplCopyWith<_$SmartInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
