import 'package:intl/intl.dart';

/// 日期格式化工具类
class DateUtils {
  /// 格式化日期为 YYYY-MM-DD
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// 格式化日期为中文显示 YYYY年MM月DD日
  static String formatDateChinese(DateTime date) {
    return DateFormat('yyyy年MM月dd日').format(date);
  }

  /// 格式化日期为显示 MM月DD日
  static String formatDateShort(DateTime date) {
    return DateFormat('MM月dd日').format(date);
  }

  /// 格式化时间为 HH:mm
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// 格式化日期时间为 YYYY-MM-DD HH:mm
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  /// 格式化日期时间为中文显示 YYYY年MM月DD日 HH:mm
  static String formatDateTimeChinese(DateTime dateTime) {
    return DateFormat('yyyy年MM月dd日 HH:mm').format(dateTime);
  }

  /// 解析字符串日期 YYYY-MM-DD
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// 解析字符串时间 HH:mm
  static DateTime? parseTime(String timeString) {
    try {
      return DateFormat('HH:mm').parse(timeString);
    } catch (e) {
      return null;
    }
  }

  /// 获取星期几的中文名称
  static String getWeekdayChinese(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[date.weekday - 1];
  }

  /// 判断是否为今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// 判断是否为明天
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// 获取日期的显示文本（今天、明天或日期）
  static String getDateDisplayText(DateTime date) {
    if (isToday(date)) {
      return '今天';
    } else if (isTomorrow(date)) {
      return '明天';
    } else {
      return '${formatDateShort(date)} ${getWeekdayChinese(date)}';
    }
  }

  /// 获取完整的日期显示文本
  static String getFullDateDisplayText(DateTime date) {
    if (isToday(date)) {
      return '今天 ${formatDateShort(date)} ${getWeekdayChinese(date)}';
    } else if (isTomorrow(date)) {
      return '明天 ${formatDateShort(date)} ${getWeekdayChinese(date)}';
    } else {
      return '${formatDateShort(date)} ${getWeekdayChinese(date)}';
    }
  }

  /// 计算两个日期之间的天数差
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// 获取当前日期
  static DateTime getCurrentDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 获取指定日期的开始时间 (00:00:00)
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 获取指定日期的结束时间 (23:59:59)
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// 组合日期和时间字符串为DateTime
  static DateTime? combineDateAndTime(String dateString, String timeString) {
    try {
      final date = parseDate(dateString);
      final time = parseTime(timeString);
      if (date == null || time == null) return null;

      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取相对时间描述（刚刚、几分钟前、几小时前等）
  static String getRelativeTimeText(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return formatDate(dateTime);
    }
  }
}
