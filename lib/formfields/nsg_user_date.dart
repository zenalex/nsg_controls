import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:nsg_data/nsg_data.dart';

/// Дата и время так, как их видит пользователь.
///
/// Язык берётся из приложения, регион — из локалей устройства.
/// [resolve] вызывают один раз на старте и при смене языка или системной
/// локали. Виджеты читают [instance] и сами [resolve] не считают.
class NsgUserDate {
  static NsgUserDate instance = NsgUserDate.legacy();

  final Locale locale;
  final bool use24Hour;
  final bool mobile;

  /// Пока приложение не вызвало [install], пикеры остаются на dd.MM.yyyy и HH:mm.
  final bool legacy;

  /// Регион устройства пустой: не подставляем голый `en` (это месяц-день).
  final bool fixedDayMonth;

  const NsgUserDate({
    required this.locale,
    required this.use24Hour,
    required this.mobile,
    required this.legacy,
    required this.fixedDayMonth,
  });

  factory NsgUserDate.legacy() {
    return const NsgUserDate(
      locale: Locale('ru'),
      use24Hour: true,
      mobile: false,
      legacy: true,
      fixedDayMonth: true,
    );
  }

  static void install(NsgUserDate value) {
    instance = value;
  }

  /// [appLanguage] без региона. [deviceLocales] — PlatformDispatcher.locales,
  /// на вебе это navigator.languages. [mobile] — iOS/Android.
  /// На мобильных [alwaysUse24Hour] важнее шаблона локали.
  factory NsgUserDate.resolve({
    required Locale appLanguage,
    required List<Locale> deviceLocales,
    required bool mobile,
    required bool alwaysUse24Hour,
  }) {
    _ensureLocales();
    final language = appLanguage.languageCode;
    final country = _countryOf(deviceLocales);
    if (country == null) {
      return NsgUserDate(
        locale: Locale(language),
        use24Hour: true,
        mobile: mobile,
        legacy: false,
        fixedDayMonth: true,
      );
    }
    final pair = '${language}_$country';
    final String tag;
    if (DateFormat.localeExists(pair)) {
      tag = pair;
    } else if (DateFormat.localeExists(language)) {
      tag = language;
    } else {
      return NsgUserDate(
        locale: Locale(language, country),
        use24Hour: true,
        mobile: mobile,
        legacy: false,
        fixedDayMonth: true,
      );
    }
    final parsed = _splitTag(tag);
    final use24 = mobile ? alwaysUse24Hour : !_localeIs12Hour(tag);
    return NsgUserDate(
      locale: parsed,
      use24Hour: use24,
      mobile: mobile,
      legacy: false,
      fixedDayMonth: false,
    );
  }

  String formatDate(DateTime value) {
    if (_empty(value)) return '';
    if (fixedDayMonth) return DateFormat('dd.MM.yyyy').format(value);
    _ensureLocales();
    return DateFormat.yMd(_tag).format(value);
  }

  String formatShortDate(DateTime value) {
    if (_empty(value)) return '';
    if (fixedDayMonth) return DateFormat('dd.MM.yy').format(value);
    _ensureLocales();
    final pattern = DateFormat.yMd(_tag).pattern ?? 'dd.MM.y';
    return DateFormat(_shortYear(pattern), _tag).format(value);
  }

  String formatDayMonth(DateTime value) {
    if (_empty(value)) return '';
    if (fixedDayMonth) return DateFormat('dd.MM').format(value);
    _ensureLocales();
    return DateFormat.Md(_tag).format(value);
  }

  String formatMonthDay(DateTime value) {
    if (_empty(value)) return '';
    if (fixedDayMonth) return DateFormat('d MMMM', 'ru').format(value);
    _ensureLocales();
    return DateFormat.MMMMd(_tag).format(value);
  }

  String formatTime(DateTime value) {
    if (fixedDayMonth || use24Hour) {
      if (fixedDayMonth) return DateFormat('HH:mm').format(value);
      _ensureLocales();
      return DateFormat.Hm(_tag).format(value);
    }
    _ensureLocales();
    return DateFormat.jm(_tag).format(value);
  }

  String formatDateTime(DateTime value) {
    if (_empty(value)) return '';
    if (fixedDayMonth) {
      return '${formatDate(value)} ${formatTime(value)}';
    }
    _ensureLocales();
    final date = DateFormat.yMd(_tag);
    final both = use24Hour ? date.add_Hm() : date.add_jm();
    return both.format(value);
  }

  /// [preset] — старый явный шаблон вроде `dd.MM.yyyy`. Неизвестный шаблон
  /// остаётся служебным и идёт в [NsgDateFormat].
  String formatWithPreset(DateTime value, String? preset, {String fallbackLocale = 'ru'}) {
    switch (preset) {
      case null:
      case '':
      case 'dd.MM.yy':
        return formatShortDate(value);
      case 'dd.MM.yyyy':
        return formatDate(value);
      case 'dd.MM':
        return formatDayMonth(value);
      case 'HH:mm':
        return formatTime(value);
      case 'HH:mm:ss':
        return _formatClock(value, withSeconds: true);
      case 'dd.MM.yyyy HH:mm':
        return formatDateTime(value);
      case 'HH:mm dd.MM.yyyy':
        if (_empty(value)) return '';
        return '${formatTime(value)} ${formatDate(value)}';
      case 'HH:mm:ss dd.MM.yyyy':
        if (_empty(value)) return '';
        return '${_formatClock(value, withSeconds: true)} ${formatDate(value)}';
      case 'HH dd.MM.yyyy':
        if (_empty(value)) return '';
        return '${_formatClock(value, hourOnly: true)} ${formatDate(value)}';
      case 'MM.yyyy':
        return _formatMonthYear(value);
      case 'yyyy':
        if (_empty(value)) return '';
        return DateFormat('yyyy').format(value);
      case 'dd.MM.yy, EE':
        return _formatWithWeekday(value, shortYear: true);
      case 'dd.MM, EE':
        return _formatWithWeekday(value, shortYear: false);
      default:
        return NsgDateFormat.dateFormat(value, format: preset, locale: fallbackLocale);
    }
  }

  DateTime? tryParseDate(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    _ensureLocales();
    final format = fixedDayMonth ? DateFormat('dd.MM.yyyy') : DateFormat.yMd(_tag);
    try {
      final parsed = format.parseStrict(trimmed);
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (_) {
      return null;
    }
  }

  /// Неполное, чужое и неоднозначное значение — null. Час не берётся по модулю 24.
  DateTime? tryParseTime(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final plain = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
    if (plain != null) {
      return _fromPlain(plain, allowAmbiguous: use24Hour || fixedDayMonth);
    }
    if (use24Hour || fixedDayMonth) {
      return _parse24WithSuffix(trimmed);
    }
    return _parse12(trimmed);
  }

  String get dateHint => formatDate(DateTime(2026, 11, 3));

  bool phonePicker(bool runningOnPhone) => legacy ? runningOnPhone : mobile;

  static bool _localesReady = false;

  static void _ensureLocales() {
    if (_localesReady) return;
    initializeDateFormatting();
    _localesReady = true;
  }

  String get _tag {
    final country = locale.countryCode;
    if (country != null && country.isNotEmpty) return '${locale.languageCode}_$country';
    return locale.languageCode;
  }

  static String? _countryOf(List<Locale> locales) {
    for (final locale in locales) {
      final country = locale.countryCode;
      if (country != null && country.isNotEmpty) return country;
    }
    return null;
  }

  static Locale _splitTag(String tag) {
    final parts = tag.split('_');
    if (parts.length >= 2 && parts[1].isNotEmpty) return Locale(parts[0], parts[1]);
    return Locale(parts[0]);
  }

  static bool _localeIs12Hour(String tag) {
    final pattern = DateFormat.jm(tag).pattern ?? '';
    return pattern.contains('a');
  }

  static bool _empty(DateTime value) => NsgDateHelper.isEmptyDate(value);

  static String _shortYear(String pattern) {
    final withoutLong = pattern.replaceAll('yyyy', 'yy');
    return withoutLong.replaceAllMapped(RegExp('y+'), (match) {
      final token = match.group(0)!;
      if (token == 'yy') return token;
      return 'yy';
    });
  }

  String _formatClock(DateTime value, {bool withSeconds = false, bool hourOnly = false}) {
    if (fixedDayMonth || use24Hour) {
      if (hourOnly) return DateFormat('HH').format(value);
      return DateFormat(withSeconds ? 'HH:mm:ss' : 'HH:mm').format(value);
    }
    _ensureLocales();
    if (hourOnly) return DateFormat('h a', _tag).format(value);
    return DateFormat(withSeconds ? 'h:mm:ss a' : 'h:mm a', _tag).format(value);
  }

  String _formatMonthYear(DateTime value) {
    if (_empty(value)) return '';
    if (fixedDayMonth) return DateFormat('MM.yyyy').format(value);
    _ensureLocales();
    return DateFormat.yM(_tag).format(value);
  }

  String _formatWithWeekday(DateTime value, {required bool shortYear}) {
    if (_empty(value)) return '';
    if (fixedDayMonth || locale.languageCode == 'ru') {
      final pattern = shortYear ? 'dd.MM.yy, EE' : 'dd.MM, EE';
      return DateFormat(pattern, 'ru').format(value);
    }
    _ensureLocales();
    final numeric = shortYear ? formatShortDate(value) : formatDayMonth(value);
    return '$numeric, ${DateFormat.E(_tag).format(value)}';
  }

  DateTime? _fromPlain(RegExpMatch plain, {required bool allowAmbiguous}) {
    final hour = int.parse(plain.group(1)!);
    final minute = int.parse(plain.group(2)!);
    if (minute > 59 || hour > 23) return null;
    if (!allowAmbiguous && hour >= 1 && hour <= 12) return null;
    return DateTime(1970, 1, 1, hour, minute);
  }

  DateTime? _parse24WithSuffix(String trimmed) {
    if (fixedDayMonth) return null;
    _ensureLocales();
    final sample = DateFormat.Hm(_tag).format(DateTime(1970, 1, 1, 15, 30));
    final suffix = sample.replaceFirst('15:30', '').trim();
    var text = trimmed;
    if (suffix.isNotEmpty && text.endsWith(suffix)) {
      text = text.substring(0, text.length - suffix.length).trim();
    }
    final plain = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text);
    if (plain == null) return null;
    return _fromPlain(plain, allowAmbiguous: true);
  }

  DateTime? _parse12(String trimmed) {
    _ensureLocales();
    final jm = DateFormat.jm(_tag);
    final normalized = _normalize12(trimmed, jm);
    if (normalized == null) return null;
    try {
      final parsed = jm.parseStrict(normalized);
      return DateTime(1970, 1, 1, parsed.hour, parsed.minute);
    } catch (_) {
      return null;
    }
  }

  String? _normalize12(String trimmed, DateFormat jm) {
    final spaced = trimmed.replaceAll(RegExp('[\u00A0\u202F\u2007]'), ' ').trim();
    final periods = jm.dateSymbols.AMPMS;
    final parts = spaced.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return _joinPeriod(parts.first, parts.sublist(1).join(' '), periods);
    }
    final glued = RegExp(r'^(\d{1,2}:\d{2})([^\d].+)$').firstMatch(spaced);
    if (glued == null) return null;
    return _joinPeriod(glued.group(1)!, glued.group(2)!, periods);
  }

  String? _joinPeriod(String time, String word, List<String> periods) {
    if (!RegExp(r'^\d{1,2}:\d{2}$').hasMatch(time)) return null;
    final hour = int.parse(time.split(':').first);
    if (hour > 12) return null;
    final folded = word.replaceAll('.', '').toLowerCase();
    for (final period in periods) {
      if (period.replaceAll('.', '').toLowerCase() == folded) {
        return '$time\u202f$period';
      }
    }
    return null;
  }
}
