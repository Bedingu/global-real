import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('pt'),
  ];

  /// No description provided for @headline.
  ///
  /// In pt, this message translates to:
  /// **'Construa patrimônio\ncom investimentos imobiliários'**
  String get headline;

  /// No description provided for @subheadline.
  ///
  /// In pt, this message translates to:
  /// **'Curadoria, estratégia e inteligência imobiliária para investidores.'**
  String get subheadline;

  /// No description provided for @signup.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get signup;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @authority_curation.
  ///
  /// In pt, this message translates to:
  /// **'Curadoria'**
  String get authority_curation;

  /// No description provided for @authority_curation_desc.
  ///
  /// In pt, this message translates to:
  /// **'Seleção estratégica de ativos'**
  String get authority_curation_desc;

  /// No description provided for @login_title.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login_title;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @login_button.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login_button;

  /// No description provided for @no_account.
  ///
  /// In pt, this message translates to:
  /// **'Não tem conta?'**
  String get no_account;

  /// No description provided for @create_account.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get create_account;

  /// No description provided for @signup_title.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get signup_title;

  /// No description provided for @signup_button.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get signup_button;

  /// No description provided for @dashboard_title.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard'**
  String get dashboard_title;

  /// No description provided for @total_assets.
  ///
  /// In pt, this message translates to:
  /// **'Patrimônio total'**
  String get total_assets;

  /// No description provided for @monthly_return.
  ///
  /// In pt, this message translates to:
  /// **'Rentabilidade mensal'**
  String get monthly_return;

  /// No description provided for @email_required.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu e-mail'**
  String get email_required;

  /// No description provided for @email_invalid.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido'**
  String get email_invalid;

  /// No description provided for @password_required.
  ///
  /// In pt, this message translates to:
  /// **'Informe sua senha'**
  String get password_required;

  /// No description provided for @password_short.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter no mínimo 6 caracteres'**
  String get password_short;

  /// No description provided for @login_invalid.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha inválidos'**
  String get login_invalid;
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
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
