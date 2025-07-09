import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_zh.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('pt'),
    Locale('sw'),
    Locale('zh')
  ];

  /// No description provided for @field_is_required.
  ///
  /// In en, this message translates to:
  /// **'Field is required'**
  String get field_is_required;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get select_date;

  /// No description provided for @select_option.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get select_option;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @powered_by.
  ///
  /// In en, this message translates to:
  /// **'Powered By '**
  String get powered_by;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @estimated_time.
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get estimated_time;

  /// No description provided for @responses.
  ///
  /// In en, this message translates to:
  /// **'responses'**
  String get responses;

  /// No description provided for @unsupported_question_type.
  ///
  /// In en, this message translates to:
  /// **'Unsupported question type'**
  String get unsupported_question_type;

  /// No description provided for @address1_required.
  ///
  /// In en, this message translates to:
  /// **'Address Line 1 is required'**
  String get address1_required;

  /// No description provided for @address2_required.
  ///
  /// In en, this message translates to:
  /// **'Address Line 2 is required'**
  String get address2_required;

  /// No description provided for @city_required.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get city_required;

  /// No description provided for @state_required.
  ///
  /// In en, this message translates to:
  /// **'State is required'**
  String get state_required;

  /// No description provided for @country_required.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get country_required;

  /// No description provided for @zip_required.
  ///
  /// In en, this message translates to:
  /// **'Zip is required'**
  String get zip_required;

  /// No description provided for @could_not_open_calendar.
  ///
  /// In en, this message translates to:
  /// **'Could not open calendar'**
  String get could_not_open_calendar;

  /// No description provided for @pls_schedule_meeting.
  ///
  /// In en, this message translates to:
  /// **'Please schedule a meeting'**
  String get pls_schedule_meeting;

  /// No description provided for @schedule_meeting.
  ///
  /// In en, this message translates to:
  /// **'Schedule Meeting'**
  String get schedule_meeting;

  /// No description provided for @meeting_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Meeting Scheduled'**
  String get meeting_scheduled;

  /// No description provided for @please_provide_consent.
  ///
  /// In en, this message translates to:
  /// **'Please provide consent'**
  String get please_provide_consent;

  /// No description provided for @i_agree.
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get i_agree;

  /// No description provided for @all_fields_are_required.
  ///
  /// In en, this message translates to:
  /// **'All fields are required'**
  String get all_fields_are_required;

  /// No description provided for @please_enter_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get please_enter_valid_email;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @please_take_action.
  ///
  /// In en, this message translates to:
  /// **'Please take action'**
  String get please_take_action;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @please_select_date.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get please_select_date;

  /// No description provided for @file_size_exceeds_limit.
  ///
  /// In en, this message translates to:
  /// **'File size exceeds limit'**
  String get file_size_exceeds_limit;

  /// No description provided for @error_uploading_file.
  ///
  /// In en, this message translates to:
  /// **'Error uploading file'**
  String get error_uploading_file;

  /// No description provided for @please_upload_file.
  ///
  /// In en, this message translates to:
  /// **'Please upload a file'**
  String get please_upload_file;

  /// No description provided for @upload_file.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get upload_file;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @type_answer_here.
  ///
  /// In en, this message translates to:
  /// **'Type your answer here...'**
  String get type_answer_here;

  /// No description provided for @min_character_required.
  ///
  /// In en, this message translates to:
  /// **'Minimum characters required'**
  String get min_character_required;

  /// No description provided for @max_character_required.
  ///
  /// In en, this message translates to:
  /// **'Maximum characters required'**
  String get max_character_required;

  /// No description provided for @please_rate_all.
  ///
  /// In en, this message translates to:
  /// **'Please rate all items'**
  String get please_rate_all;

  /// No description provided for @please_select_option.
  ///
  /// In en, this message translates to:
  /// **'Please select an option'**
  String get please_select_option;

  /// No description provided for @please_select_score.
  ///
  /// In en, this message translates to:
  /// **'Please select a score'**
  String get please_select_score;

  /// No description provided for @please_rank_all_options.
  ///
  /// In en, this message translates to:
  /// **'Please rank all options'**
  String get please_rank_all_options;

  /// No description provided for @please_select_rating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get please_select_rating;

  /// No description provided for @click_here.
  ///
  /// In en, this message translates to:
  /// **'Click here'**
  String get click_here;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'es', 'fr', 'ja', 'pt', 'sw', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'ja': return AppLocalizationsJa();
    case 'pt': return AppLocalizationsPt();
    case 'sw': return AppLocalizationsSw();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
