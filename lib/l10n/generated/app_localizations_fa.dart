// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'باغ خاموش';

  @override
  String get menuContinue => 'ادامه بازی';

  @override
  String get menuLevels => 'مراحل';

  @override
  String get menuHelp => 'راهنما';

  @override
  String get menuSettings => 'تنظیمات';

  @override
  String get menuAbout => 'درباره بازی';

  @override
  String get hintButton => 'راهنمایی';

  @override
  String hintRemaining(int count) {
    return '$count راهنمایی باقی‌مانده';
  }

  @override
  String get clearInput => 'پاک کردن';

  @override
  String get puzzleSolved => 'حل شد!';

  @override
  String get nextLevel => 'مرحله بعد';

  @override
  String get backToMap => 'بازگشت به نقشه';

  @override
  String get backToMenu => 'بازگشت به منو';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsMusic => 'صدای موزیک';

  @override
  String get settingsSfx => 'صدای افکت‌ها';

  @override
  String get settingsReducedMotion => 'کاهش حرکت';

  @override
  String get settingsColorblind => 'حالت دوستدار کوررنگی';

  @override
  String get settingsResetProgress => 'بازنشانی پیشرفت';

  @override
  String get resetConfirmTitle => 'آیا مطمئنی؟';

  @override
  String get resetConfirmBody => 'تمام پیشرفت بازی برای همیشه حذف می‌شود.';

  @override
  String get confirm => 'تأیید';

  @override
  String get cancel => 'انصراف';

  @override
  String get levelLocked => 'قفل';

  @override
  String get levelSolved => 'حل شده';

  @override
  String get levelInProgress => 'در حال انجام';

  @override
  String get hintTitle => 'سرنخ';

  @override
  String get wrongCode => 'کد درست نیست، دوباره امتحان کن';

  @override
  String get congratulations => 'آفرین!';

  @override
  String get levelComplete => 'مرحله را با موفقیت حل کردی';

  @override
  String get persian => 'فارسی';

  @override
  String get english => 'English';

  @override
  String get aboutText => 'باغ خاموش — یک بازی پازلی آرام و رویاگونه';
}
