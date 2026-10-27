import 'package:intl/intl.dart';

const List<String> _thaiMonthsFull = [
  'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
  'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
];

const List<String> _thaiMonthsShort = [
  'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
  'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
];

const List<String> _thaiWeekdaysShort = [
  'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.',
];

final NumberFormat _plain = NumberFormat('#,##0', 'en_US');
final NumberFormat _withDecimals = NumberFormat('#,##0.00', 'en_US');

/// `฿1,234` — drops the decimals when the amount is a whole number.
String formatBaht(double amount) {
  final rounded = amount.roundToDouble();
  final body = amount == rounded ? _plain.format(amount) : _withDecimals.format(amount);
  return amount < 0 ? '-฿${body.replaceFirst('-', '')}' : '฿$body';
}

/// `1,234` without the currency symbol.
String formatNumber(double amount) => _plain.format(amount);

/// `฿12.4K` / `฿1.2M` — for tight spots like chart axes and pills.
String formatCompactBaht(double amount) {
  final abs = amount.abs();
  final sign = amount < 0 ? '-' : '';
  if (abs >= 1000000) return '$sign฿${(abs / 1000000).toStringAsFixed(abs >= 10000000 ? 0 : 1)}M';
  if (abs >= 10000) return '$sign฿${(abs / 1000).toStringAsFixed(0)}K';
  if (abs >= 1000) return '$sign฿${(abs / 1000).toStringAsFixed(1)}K';
  return formatBaht(amount);
}

/// `17 ก.ค.`
String formatDayMonthThai(DateTime date) =>
    '${date.day} ${_thaiMonthsShort[date.month - 1]}';

/// `17 กรกฎาคม 2026`
String formatFullDateThai(DateTime date) =>
    '${date.day} ${_thaiMonthsFull[date.month - 1]} ${date.year}';

/// `กรกฎาคม 2026`
String formatMonthYearThai(DateTime date) =>
    '${_thaiMonthsFull[date.month - 1]} ${date.year}';

/// `ก.ค. 26`
String formatMonthYearShortThai(DateTime date) =>
    '${_thaiMonthsShort[date.month - 1]} ${date.year % 100}';

/// `จ.` — Monday-first weekday abbreviation.
String formatWeekdayThai(DateTime date) =>
    _thaiWeekdaysShort[date.weekday - 1];

/// `วันนี้` / `เมื่อวาน` / `17 ก.ค.`
String formatRelativeDayThai(DateTime date, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final d = DateTime(date.year, date.month, date.day);
  final t = DateTime(today.year, today.month, today.day);
  final diff = t.difference(d).inDays;
  if (diff == 0) return 'วันนี้';
  if (diff == 1) return 'เมื่อวาน';
  return formatDayMonthThai(date);
}

/// `อีก 42 วัน` / `เลยกำหนด 3 วัน` / `วันนี้`
String formatDeadlineThai(DateTime deadline, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final days = DateTime(deadline.year, deadline.month, deadline.day)
      .difference(DateTime(today.year, today.month, today.day))
      .inDays;
  if (days == 0) return 'ครบกำหนดวันนี้';
  if (days < 0) return 'เลยกำหนด ${-days} วัน';
  if (days < 31) return 'อีก $days วัน';
  final months = (days / 30).floor();
  return 'อีกประมาณ $months เดือน';
}

/// `+12%` / `-8%`
String formatSignedPercent(double percent) {
  final sign = percent > 0 ? '+' : '';
  return '$sign${percent.toStringAsFixed(0)}%';
}
