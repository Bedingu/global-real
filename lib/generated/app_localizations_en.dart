// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get headline => 'Build wealth\nwith real estate investments';

  @override
  String get subheadline =>
      'Curation, strategy and real estate intelligence for investors.';

  @override
  String get signup => 'Sign up';

  @override
  String get login => 'Login';

  @override
  String get authority_curation => 'Curation';

  @override
  String get authority_curation_desc => 'Strategic asset selection';

  @override
  String get login_title => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login_button => 'Login';

  @override
  String get no_account => 'Don\'t have an account?';

  @override
  String get create_account => 'Create account';

  @override
  String get signup_title => 'Create account';

  @override
  String get signup_button => 'Sign up';

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String get total_assets => 'Total assets';

  @override
  String get monthly_return => 'Monthly return';

  @override
  String get email_required => 'Please enter your email';

  @override
  String get email_invalid => 'Invalid email address';

  @override
  String get password_required => 'Please enter your password';

  @override
  String get password_short => 'Password must be at least 6 characters';

  @override
  String get login_invalid => 'Invalid email or password';
}
