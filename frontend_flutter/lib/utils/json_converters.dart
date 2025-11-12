import 'package:json_annotation/json_annotation.dart';

/// 将字符串/数字转换为double的转换器
/// 用于处理后端Decimal类型字段（如价格、经纬度等）
class StringToDoubleConverter implements JsonConverter<double?, dynamic> {
  const StringToDoubleConverter();

  @override
  double? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  @override
  dynamic toJson(double? value) => value;
}

/// 非空double转换器
class StringToDoubleRequiredConverter implements JsonConverter<double, dynamic> {
  const StringToDoubleRequiredConverter();

  @override
  double fromJson(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  @override
  dynamic toJson(double value) => value;
}

/// 将字符串/数字转换为int的转换器
class StringToIntConverter implements JsonConverter<int?, dynamic> {
  const StringToIntConverter();

  @override
  int? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  @override
  dynamic toJson(int? value) => value;
}

/// 非空int转换器
class StringToIntRequiredConverter implements JsonConverter<int, dynamic> {
  const StringToIntRequiredConverter();

  @override
  int fromJson(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  @override
  dynamic toJson(int value) => value;
}

/// 将逗号分隔的字符串转换为字符串数组的转换器
/// 用于处理后端存储为逗号分隔字符串的数组字段（如specialties）
class CommaSeparatedStringToListConverter implements JsonConverter<List<String>?, dynamic> {
  const CommaSeparatedStringToListConverter();

  @override
  List<String>? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      if (value.isEmpty) return null;
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return null;
  }

  @override
  dynamic toJson(List<String>? value) {
    if (value == null || value.isEmpty) return null;
    return value.join(',');
  }
}
