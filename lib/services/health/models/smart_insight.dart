import 'package:freezed_annotation/freezed_annotation.dart';

part 'smart_insight.freezed.dart';
part 'smart_insight.g.dart';

enum SmartInsightType { positive, warning, tip }

@freezed
class SmartInsight with _$SmartInsight {
  const factory SmartInsight({
    required String headline,
    required String detail,
    required String suggestion,
    required SmartInsightType type,
  }) = _SmartInsight;

  factory SmartInsight.fromJson(Map<String, dynamic> json) =>
      _$SmartInsightFromJson(json);
}
