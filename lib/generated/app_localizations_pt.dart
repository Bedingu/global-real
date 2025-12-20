// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get headline => 'Construa patrimônio\ncom investimentos imobiliários';

  @override
  String get subheadline =>
      'Curadoria, estratégia e inteligência imobiliária para investidores.';

  @override
  String get signup => 'Criar conta';

  @override
  String get login => 'Entrar';

  @override
  String get authority_curation => 'Curadoria';

  @override
  String get authority_curation_desc => 'Seleção estratégica de ativos';

  @override
  String get login_title => 'Entrar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get login_button => 'Entrar';

  @override
  String get no_account => 'Não tem conta?';

  @override
  String get create_account => 'Criar conta';

  @override
  String get signup_title => 'Criar conta';

  @override
  String get signup_button => 'Cadastrar';

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String get total_assets => 'Patrimônio total';

  @override
  String get monthly_return => 'Rentabilidade mensal';

  @override
  String get email_required => 'Informe seu e-mail';

  @override
  String get email_invalid => 'E-mail inválido';

  @override
  String get password_required => 'Informe sua senha';

  @override
  String get password_short => 'A senha deve ter no mínimo 6 caracteres';

  @override
  String get login_invalid => 'E-mail ou senha inválidos';
}
