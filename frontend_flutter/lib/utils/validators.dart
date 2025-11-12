/// 表单验证工具类
class Validators {
  /// 验证手机号
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }

    // 中国大陆手机号正则：1开头，第二位是3-9，后面9位数字
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return '请输入正确的手机号';
    }

    return null;
  }

  /// 验证验证码
  static String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }

    // 验证码通常是4-6位数字
    final codeRegex = RegExp(r'^\d{4,6}$');
    if (!codeRegex.hasMatch(value)) {
      return '请输入正确的验证码';
    }

    return null;
  }

  /// 验证昵称
  static String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入昵称';
    }

    if (value.length < 2) {
      return '昵称至少2个字符';
    }

    if (value.length > 20) {
      return '昵称最多20个字符';
    }

    return null;
  }

  /// 验证必填字段
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '请输入${fieldName ?? '内容'}';
    }
    return null;
  }

  /// 验证邮箱
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return '请输入正确的邮箱地址';
    }

    return null;
  }

  /// 验证密码
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }

    if (value.length < 6) {
      return '密码至少6位';
    }

    if (value.length > 20) {
      return '密码最多20位';
    }

    return null;
  }

  /// 验证确认密码
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return '请再次输入密码';
    }

    if (value != password) {
      return '两次输入的密码不一致';
    }

    return null;
  }

  /// 验证身份证号
  static String? validateIdCard(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入身份证号';
    }

    // 18位身份证号正则
    final idCardRegex = RegExp(
      r'^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$',
    );
    if (!idCardRegex.hasMatch(value)) {
      return '请输入正确的身份证号';
    }

    return null;
  }

  /// 验证数字
  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '请输入${fieldName ?? '数字'}';
    }

    if (double.tryParse(value) == null) {
      return '请输入有效的数字';
    }

    return null;
  }

  /// 验证整数
  static String? validateInteger(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '请输入${fieldName ?? '整数'}';
    }

    if (int.tryParse(value) == null) {
      return '请输入有效的整数';
    }

    return null;
  }

  /// 验证长度范围
  static String? validateLength(
    String? value, {
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '请输入${fieldName ?? '内容'}';
    }

    if (minLength != null && value.length < minLength) {
      return '${fieldName ?? '内容'}至少$minLength个字符';
    }

    if (maxLength != null && value.length > maxLength) {
      return '${fieldName ?? '内容'}最多$maxLength个字符';
    }

    return null;
  }

  /// 验证数值范围
  static String? validateRange(
    String? value, {
    double? min,
    double? max,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '请输入${fieldName ?? '数值'}';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '请输入有效的数值';
    }

    if (min != null && number < min) {
      return '${fieldName ?? '数值'}不能小于$min';
    }

    if (max != null && number > max) {
      return '${fieldName ?? '数值'}不能大于$max';
    }

    return null;
  }

  /// 验证URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入网址';
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    if (!urlRegex.hasMatch(value)) {
      return '请输入正确的网址';
    }

    return null;
  }

  /// 组合多个验证器
  static String? combine(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
