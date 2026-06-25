// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Silent Garden';

  @override
  String get menuContinue => 'Continue';

  @override
  String get menuLevels => 'Levels';

  @override
  String get menuHelp => 'Help';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuAbout => 'About';

  @override
  String get hintButton => 'Hint';

  @override
  String hintRemaining(int count) {
    return '$count hints remaining';
  }

  @override
  String get clearInput => 'Clear';

  @override
  String get puzzleSolved => 'Solved!';

  @override
  String get nextLevel => 'Next Level';

  @override
  String get backToMap => 'Back to Map';

  @override
  String get backToMenu => 'Back to Menu';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsMusic => 'Music Volume';

  @override
  String get settingsSfx => 'Sound Effects';

  @override
  String get settingsReducedMotion => 'Reduced Motion';

  @override
  String get settingsColorblind => 'Colorblind Mode';

  @override
  String get settingsResetProgress => 'Reset Progress';

  @override
  String get resetConfirmTitle => 'Are you sure?';

  @override
  String get resetConfirmBody =>
      'All your progress will be permanently deleted.';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get levelLocked => 'Locked';

  @override
  String get levelSolved => 'Solved';

  @override
  String get levelInProgress => 'In Progress';

  @override
  String get hintTitle => 'Hint';

  @override
  String get wrongCode => 'Wrong code, try again';

  @override
  String get congratulations => 'Well done!';

  @override
  String get levelComplete => 'Level complete';

  @override
  String get persian => 'فارسی';

  @override
  String get english => 'English';

  @override
  String get aboutText => 'Silent Garden — a calm, dreamlike puzzle game';

  @override
  String get instructionsTitle => 'How to Play';

  @override
  String get instructionsSkip => 'Skip';

  @override
  String get instructionsStart => 'Start Playing';

  @override
  String get instructionsNext => 'Next';

  @override
  String progressOf(int solved, int total) {
    return '$solved of $total levels';
  }
}
