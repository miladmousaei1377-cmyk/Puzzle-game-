import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fa, this message translates to:
  /// **'باغ خاموش'**
  String get appTitle;

  /// No description provided for @menuContinue.
  ///
  /// In fa, this message translates to:
  /// **'ادامه بازی'**
  String get menuContinue;

  /// No description provided for @menuLevels.
  ///
  /// In fa, this message translates to:
  /// **'مراحل'**
  String get menuLevels;

  /// No description provided for @menuHelp.
  ///
  /// In fa, this message translates to:
  /// **'راهنما'**
  String get menuHelp;

  /// No description provided for @menuSettings.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get menuSettings;

  /// No description provided for @menuAbout.
  ///
  /// In fa, this message translates to:
  /// **'درباره بازی'**
  String get menuAbout;

  /// No description provided for @hintButton.
  ///
  /// In fa, this message translates to:
  /// **'راهنمایی'**
  String get hintButton;

  /// No description provided for @hintRemaining.
  ///
  /// In fa, this message translates to:
  /// **'{count} راهنمایی باقی‌مانده'**
  String hintRemaining(int count);

  /// No description provided for @clearInput.
  ///
  /// In fa, this message translates to:
  /// **'پاک کردن'**
  String get clearInput;

  /// No description provided for @puzzleSolved.
  ///
  /// In fa, this message translates to:
  /// **'حل شد!'**
  String get puzzleSolved;

  /// No description provided for @nextLevel.
  ///
  /// In fa, this message translates to:
  /// **'مرحله بعد'**
  String get nextLevel;

  /// No description provided for @backToMap.
  ///
  /// In fa, this message translates to:
  /// **'بازگشت به نقشه'**
  String get backToMap;

  /// No description provided for @backToMenu.
  ///
  /// In fa, this message translates to:
  /// **'بازگشت به منو'**
  String get backToMenu;

  /// No description provided for @settingsLanguage.
  ///
  /// In fa, this message translates to:
  /// **'زبان'**
  String get settingsLanguage;

  /// No description provided for @settingsMusic.
  ///
  /// In fa, this message translates to:
  /// **'صدای موزیک'**
  String get settingsMusic;

  /// No description provided for @settingsSfx.
  ///
  /// In fa, this message translates to:
  /// **'صدای افکت‌ها'**
  String get settingsSfx;

  /// No description provided for @settingsReducedMotion.
  ///
  /// In fa, this message translates to:
  /// **'کاهش حرکت'**
  String get settingsReducedMotion;

  /// No description provided for @settingsColorblind.
  ///
  /// In fa, this message translates to:
  /// **'حالت دوستدار کوررنگی'**
  String get settingsColorblind;

  /// No description provided for @settingsResetProgress.
  ///
  /// In fa, this message translates to:
  /// **'بازنشانی پیشرفت'**
  String get settingsResetProgress;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In fa, this message translates to:
  /// **'آیا مطمئنی؟'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmBody.
  ///
  /// In fa, this message translates to:
  /// **'تمام پیشرفت بازی برای همیشه حذف می‌شود.'**
  String get resetConfirmBody;

  /// No description provided for @confirm.
  ///
  /// In fa, this message translates to:
  /// **'تأیید'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In fa, this message translates to:
  /// **'انصراف'**
  String get cancel;

  /// No description provided for @levelLocked.
  ///
  /// In fa, this message translates to:
  /// **'قفل'**
  String get levelLocked;

  /// No description provided for @levelSolved.
  ///
  /// In fa, this message translates to:
  /// **'حل شده'**
  String get levelSolved;

  /// No description provided for @levelInProgress.
  ///
  /// In fa, this message translates to:
  /// **'در حال انجام'**
  String get levelInProgress;

  /// No description provided for @hintTitle.
  ///
  /// In fa, this message translates to:
  /// **'سرنخ'**
  String get hintTitle;

  /// No description provided for @wrongCode.
  ///
  /// In fa, this message translates to:
  /// **'کد درست نیست، دوباره امتحان کن'**
  String get wrongCode;

  /// No description provided for @congratulations.
  ///
  /// In fa, this message translates to:
  /// **'آفرین!'**
  String get congratulations;

  /// No description provided for @levelComplete.
  ///
  /// In fa, this message translates to:
  /// **'مرحله را با موفقیت حل کردی'**
  String get levelComplete;

  /// No description provided for @persian.
  ///
  /// In fa, this message translates to:
  /// **'فارسی'**
  String get persian;

  /// No description provided for @english.
  ///
  /// In fa, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @aboutText.
  ///
  /// In fa, this message translates to:
  /// **'باغ خاموش — یک بازی پازلی آرام و رویاگونه'**
  String get aboutText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
