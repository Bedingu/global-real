import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';
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
    Locale('es'),
    Locale('pt'),
    Locale('zh')
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

  /// No description provided for @authority_strategy.
  ///
  /// In pt, this message translates to:
  /// **'Estratégia'**
  String get authority_strategy;

  /// No description provided for @authority_strategy_desc.
  ///
  /// In pt, this message translates to:
  /// **'Planejamento de portfólio imobiliário'**
  String get authority_strategy_desc;

  /// No description provided for @authority_intelligence.
  ///
  /// In pt, this message translates to:
  /// **'Inteligência'**
  String get authority_intelligence;

  /// No description provided for @authority_intelligence_desc.
  ///
  /// In pt, this message translates to:
  /// **'Dados e análises de mercado em tempo real'**
  String get authority_intelligence_desc;

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

  /// No description provided for @forgot_password.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu sua senha?'**
  String get forgot_password;

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
  /// **'Valor Geral de Vendas (VGV)'**
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

  /// No description provided for @subscribe_monthly.
  ///
  /// In pt, this message translates to:
  /// **'Assinar Mensal'**
  String get subscribe_monthly;

  /// No description provided for @subscribe_annual.
  ///
  /// In pt, this message translates to:
  /// **'Assinar Anual'**
  String get subscribe_annual;

  /// No description provided for @filter_title.
  ///
  /// In pt, this message translates to:
  /// **'Filtro de Mercado'**
  String get filter_title;

  /// No description provided for @filter_capacity.
  ///
  /// In pt, this message translates to:
  /// **'Capacidade'**
  String get filter_capacity;

  /// No description provided for @filter_capacity_any.
  ///
  /// In pt, this message translates to:
  /// **'Qualquer'**
  String get filter_capacity_any;

  /// No description provided for @filter_bathrooms.
  ///
  /// In pt, this message translates to:
  /// **'Banheiros'**
  String get filter_bathrooms;

  /// No description provided for @filter_min.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo'**
  String get filter_min;

  /// No description provided for @filter_max.
  ///
  /// In pt, this message translates to:
  /// **'Máximo'**
  String get filter_max;

  /// No description provided for @filter_listing_count.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade de Anúncios'**
  String get filter_listing_count;

  /// No description provided for @filter_demand_drivers.
  ///
  /// In pt, this message translates to:
  /// **'Fatores de Demanda'**
  String get filter_demand_drivers;

  /// No description provided for @filter_reset.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get filter_reset;

  /// No description provided for @filter_apply.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get filter_apply;

  /// No description provided for @driver_airport.
  ///
  /// In pt, this message translates to:
  /// **'Aeroporto'**
  String get driver_airport;

  /// No description provided for @driver_arts.
  ///
  /// In pt, this message translates to:
  /// **'Artes e Cultura'**
  String get driver_arts;

  /// No description provided for @driver_coastal.
  ///
  /// In pt, this message translates to:
  /// **'Litoral'**
  String get driver_coastal;

  /// No description provided for @driver_golf.
  ///
  /// In pt, this message translates to:
  /// **'Golfe'**
  String get driver_golf;

  /// No description provided for @driver_lake.
  ///
  /// In pt, this message translates to:
  /// **'Lago'**
  String get driver_lake;

  /// No description provided for @driver_military.
  ///
  /// In pt, this message translates to:
  /// **'Militar'**
  String get driver_military;

  /// No description provided for @driver_mountains.
  ///
  /// In pt, this message translates to:
  /// **'Montanhas'**
  String get driver_mountains;

  /// No description provided for @driver_national_park.
  ///
  /// In pt, this message translates to:
  /// **'Parque Nacional'**
  String get driver_national_park;

  /// No description provided for @driver_ski.
  ///
  /// In pt, this message translates to:
  /// **'Esqui'**
  String get driver_ski;

  /// No description provided for @driver_university.
  ///
  /// In pt, this message translates to:
  /// **'Universidade'**
  String get driver_university;

  /// No description provided for @driver_winery.
  ///
  /// In pt, this message translates to:
  /// **'Vinícola'**
  String get driver_winery;

  /// No description provided for @capacity_bedrooms.
  ///
  /// In pt, this message translates to:
  /// **'Quartos'**
  String get capacity_bedrooms;

  /// No description provided for @capacity_baths.
  ///
  /// In pt, this message translates to:
  /// **'Banheiros'**
  String get capacity_baths;

  /// No description provided for @capacity_guests.
  ///
  /// In pt, this message translates to:
  /// **'Número de hóspedes'**
  String get capacity_guests;

  /// No description provided for @capacity_bedrooms_plus.
  ///
  /// In pt, this message translates to:
  /// **'10+ quartos'**
  String get capacity_bedrooms_plus;

  /// No description provided for @capacity_baths_plus.
  ///
  /// In pt, this message translates to:
  /// **'6+ banheiros'**
  String get capacity_baths_plus;

  /// No description provided for @capacity_guests_plus.
  ///
  /// In pt, this message translates to:
  /// **'20+ hóspedes'**
  String get capacity_guests_plus;

  /// No description provided for @budget_title.
  ///
  /// In pt, this message translates to:
  /// **'Budget e Retorno'**
  String get budget_title;

  /// No description provided for @budget_max_capex.
  ///
  /// In pt, this message translates to:
  /// **'CAPEX Máximo'**
  String get budget_max_capex;

  /// No description provided for @budget_price_m2.
  ///
  /// In pt, this message translates to:
  /// **'Preço por m²'**
  String get budget_price_m2;

  /// No description provided for @budget_min_adr.
  ///
  /// In pt, this message translates to:
  /// **'ADR Mínimo'**
  String get budget_min_adr;

  /// No description provided for @budget_min_yield.
  ///
  /// In pt, this message translates to:
  /// **'Yield Mínimo'**
  String get budget_min_yield;

  /// No description provided for @amenities_title.
  ///
  /// In pt, this message translates to:
  /// **'Comodidades'**
  String get amenities_title;

  /// No description provided for @amenity_parking.
  ///
  /// In pt, this message translates to:
  /// **'Estacionamento'**
  String get amenity_parking;

  /// No description provided for @amenity_pool.
  ///
  /// In pt, this message translates to:
  /// **'Piscina'**
  String get amenity_pool;

  /// No description provided for @amenity_air_conditioning.
  ///
  /// In pt, this message translates to:
  /// **'Ar-condicionado'**
  String get amenity_air_conditioning;

  /// No description provided for @amenity_pet_friendly.
  ///
  /// In pt, this message translates to:
  /// **'Aceita pets'**
  String get amenity_pet_friendly;

  /// No description provided for @paywall_title.
  ///
  /// In pt, this message translates to:
  /// **'Conteúdo Premium'**
  String get paywall_title;

  /// No description provided for @paywall_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Desbloqueie ferramentas exclusivas para assessores de alto nível.'**
  String get paywall_subtitle;

  /// No description provided for @paywall_benefit_filters.
  ///
  /// In pt, this message translates to:
  /// **'Filtros avançados de investimento'**
  String get paywall_benefit_filters;

  /// No description provided for @paywall_benefit_analysis.
  ///
  /// In pt, this message translates to:
  /// **'Análise de retorno e yield'**
  String get paywall_benefit_analysis;

  /// No description provided for @paywall_benefit_videos.
  ///
  /// In pt, this message translates to:
  /// **'Vídeos e insights exclusivos'**
  String get paywall_benefit_videos;

  /// No description provided for @paywall_benefit_data.
  ///
  /// In pt, this message translates to:
  /// **'Acesso total aos dados premium'**
  String get paywall_benefit_data;

  /// No description provided for @paywall_cta.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear Premium'**
  String get paywall_cta;

  /// No description provided for @paywall_footer.
  ///
  /// In pt, this message translates to:
  /// **'Cancele quando quiser • Pagamento seguro'**
  String get paywall_footer;

  /// No description provided for @paywall_monthly.
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get paywall_monthly;

  /// No description provided for @paywall_annual.
  ///
  /// In pt, this message translates to:
  /// **'Anual'**
  String get paywall_annual;

  /// No description provided for @paywall_monthly_price.
  ///
  /// In pt, this message translates to:
  /// **'R\$ 99/mês'**
  String get paywall_monthly_price;

  /// No description provided for @paywall_annual_price.
  ///
  /// In pt, this message translates to:
  /// **'R\$ 899/ano'**
  String get paywall_annual_price;

  /// No description provided for @paywall_annual_savings.
  ///
  /// In pt, this message translates to:
  /// **'Economize 25%'**
  String get paywall_annual_savings;

  /// No description provided for @proximity_any.
  ///
  /// In pt, this message translates to:
  /// **'Metrô'**
  String get proximity_any;

  /// No description provided for @proximity_300m.
  ///
  /// In pt, this message translates to:
  /// **'Até 300m'**
  String get proximity_300m;

  /// No description provided for @proximity_500m.
  ///
  /// In pt, this message translates to:
  /// **'Até 500m'**
  String get proximity_500m;

  /// No description provided for @proximity_800m.
  ///
  /// In pt, this message translates to:
  /// **'Até 800m'**
  String get proximity_800m;

  /// No description provided for @proximity_1km.
  ///
  /// In pt, this message translates to:
  /// **'Até 1 km'**
  String get proximity_1km;

  /// No description provided for @filter_property_type.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de Imóvel'**
  String get filter_property_type;

  /// No description provided for @filter_delivery_date.
  ///
  /// In pt, this message translates to:
  /// **'Data de Entrega'**
  String get filter_delivery_date;

  /// No description provided for @filter_price_range.
  ///
  /// In pt, this message translates to:
  /// **'Faixa de Preço'**
  String get filter_price_range;

  /// No description provided for @property_type_apartment.
  ///
  /// In pt, this message translates to:
  /// **'Apartamento'**
  String get property_type_apartment;

  /// No description provided for @property_type_studio.
  ///
  /// In pt, this message translates to:
  /// **'Studio'**
  String get property_type_studio;

  /// No description provided for @property_type_house.
  ///
  /// In pt, this message translates to:
  /// **'Casa'**
  String get property_type_house;

  /// No description provided for @property_type_commercial.
  ///
  /// In pt, this message translates to:
  /// **'Comercial'**
  String get property_type_commercial;

  /// No description provided for @property_type_land.
  ///
  /// In pt, this message translates to:
  /// **'Terreno'**
  String get property_type_land;

  /// No description provided for @property_type_flat.
  ///
  /// In pt, this message translates to:
  /// **'Flat'**
  String get property_type_flat;

  /// No description provided for @delivery_from.
  ///
  /// In pt, this message translates to:
  /// **'A partir de'**
  String get delivery_from;

  /// No description provided for @delivery_to.
  ///
  /// In pt, this message translates to:
  /// **'Até'**
  String get delivery_to;

  /// No description provided for @price_min.
  ///
  /// In pt, this message translates to:
  /// **'Preço mínimo'**
  String get price_min;

  /// No description provided for @price_max.
  ///
  /// In pt, this message translates to:
  /// **'Preço máximo'**
  String get price_max;

  /// No description provided for @all_filters.
  ///
  /// In pt, this message translates to:
  /// **'Todos os filtros'**
  String get all_filters;

  /// No description provided for @all_filters_developments.
  ///
  /// In pt, this message translates to:
  /// **'Empreendimentos'**
  String get all_filters_developments;

  /// No description provided for @all_filters_capacity.
  ///
  /// In pt, this message translates to:
  /// **'Capacidade'**
  String get all_filters_capacity;

  /// No description provided for @all_filters_proximity.
  ///
  /// In pt, this message translates to:
  /// **'Proximidade'**
  String get all_filters_proximity;

  /// No description provided for @all_filters_amenities.
  ///
  /// In pt, this message translates to:
  /// **'Comodidades'**
  String get all_filters_amenities;

  /// No description provided for @all_filters_demand_drivers.
  ///
  /// In pt, this message translates to:
  /// **'Fatores de Demanda'**
  String get all_filters_demand_drivers;

  /// No description provided for @all_filters_reset.
  ///
  /// In pt, this message translates to:
  /// **'Resetar'**
  String get all_filters_reset;

  /// No description provided for @all_filters_apply.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get all_filters_apply;

  /// No description provided for @filter_investment.
  ///
  /// In pt, this message translates to:
  /// **'Investimento'**
  String get filter_investment;

  /// No description provided for @private_title.
  ///
  /// In pt, this message translates to:
  /// **'Formas de Investimentos'**
  String get private_title;

  /// No description provided for @private_type_private.
  ///
  /// In pt, this message translates to:
  /// **'Investimentos Privados'**
  String get private_type_private;

  /// No description provided for @private_type_fraction.
  ///
  /// In pt, this message translates to:
  /// **'Fração Imobiliária'**
  String get private_type_fraction;

  /// No description provided for @private_irr_annual.
  ///
  /// In pt, this message translates to:
  /// **'IRR Anual'**
  String get private_irr_annual;

  /// No description provided for @private_irr_annual_desc.
  ///
  /// In pt, this message translates to:
  /// **'Taxa interna de retorno anualizada'**
  String get private_irr_annual_desc;

  /// No description provided for @private_irr_monthly.
  ///
  /// In pt, this message translates to:
  /// **'IRR Mensal'**
  String get private_irr_monthly;

  /// No description provided for @private_irr_monthly_desc.
  ///
  /// In pt, this message translates to:
  /// **'Taxa interna de retorno mensal'**
  String get private_irr_monthly_desc;

  /// No description provided for @private_roi.
  ///
  /// In pt, this message translates to:
  /// **'ROI'**
  String get private_roi;

  /// No description provided for @private_roi_desc.
  ///
  /// In pt, this message translates to:
  /// **'Retorno sobre o investimento total'**
  String get private_roi_desc;

  /// No description provided for @private_payback.
  ///
  /// In pt, this message translates to:
  /// **'Payback'**
  String get private_payback;

  /// No description provided for @private_payback_desc.
  ///
  /// In pt, this message translates to:
  /// **'Tempo para recuperar o investimento'**
  String get private_payback_desc;

  /// No description provided for @private_payback_months.
  ///
  /// In pt, this message translates to:
  /// **'{count} meses'**
  String private_payback_months(Object count);

  /// No description provided for @private_payback_years.
  ///
  /// In pt, this message translates to:
  /// **'{years}a {months}m'**
  String private_payback_years(Object months, Object years);

  /// No description provided for @private_npv.
  ///
  /// In pt, this message translates to:
  /// **'VPL'**
  String get private_npv;

  /// No description provided for @private_npv_desc.
  ///
  /// In pt, this message translates to:
  /// **'Valor presente líquido do fluxo de caixa'**
  String get private_npv_desc;

  /// No description provided for @private_cumulative.
  ///
  /// In pt, this message translates to:
  /// **'Acumulado'**
  String get private_cumulative;

  /// No description provided for @private_monthly.
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get private_monthly;

  /// No description provided for @private_chart_months.
  ///
  /// In pt, this message translates to:
  /// **'Meses'**
  String get private_chart_months;

  /// No description provided for @private_legend_revenue.
  ///
  /// In pt, this message translates to:
  /// **'Receita'**
  String get private_legend_revenue;

  /// No description provided for @private_legend_cost.
  ///
  /// In pt, this message translates to:
  /// **'Custos'**
  String get private_legend_cost;

  /// No description provided for @private_legend_net.
  ///
  /// In pt, this message translates to:
  /// **'Resultado Líquido'**
  String get private_legend_net;

  /// No description provided for @private_invested.
  ///
  /// In pt, this message translates to:
  /// **'Investido'**
  String get private_invested;

  /// No description provided for @private_return.
  ///
  /// In pt, this message translates to:
  /// **'Retorno'**
  String get private_return;

  /// No description provided for @private_profit.
  ///
  /// In pt, this message translates to:
  /// **'Lucro'**
  String get private_profit;

  /// No description provided for @private_launches.
  ///
  /// In pt, this message translates to:
  /// **'Lançamentos'**
  String get private_launches;

  /// No description provided for @fraction_title.
  ///
  /// In pt, this message translates to:
  /// **'Fração Imobiliária'**
  String get fraction_title;

  /// No description provided for @fraction_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Invista em frações de imóveis premium'**
  String get fraction_subtitle;

  /// No description provided for @fraction_select_development.
  ///
  /// In pt, this message translates to:
  /// **'EMPREENDIMENTO'**
  String get fraction_select_development;

  /// No description provided for @fraction_weeks_label.
  ///
  /// In pt, this message translates to:
  /// **'semanas'**
  String get fraction_weeks_label;

  /// No description provided for @fraction_days_year.
  ///
  /// In pt, this message translates to:
  /// **'dias/ano'**
  String get fraction_days_year;

  /// No description provided for @fraction_days.
  ///
  /// In pt, this message translates to:
  /// **'dias'**
  String get fraction_days;

  /// No description provided for @fraction_months.
  ///
  /// In pt, this message translates to:
  /// **'meses'**
  String get fraction_months;

  /// No description provided for @fraction_investment.
  ///
  /// In pt, this message translates to:
  /// **'Investimento'**
  String get fraction_investment;

  /// No description provided for @fraction_annual_use.
  ///
  /// In pt, this message translates to:
  /// **'Uso anual'**
  String get fraction_annual_use;

  /// No description provided for @fraction_simultaneous.
  ///
  /// In pt, this message translates to:
  /// **'Reservas simultâneas'**
  String get fraction_simultaneous;

  /// No description provided for @fraction_schedule.
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get fraction_schedule;

  /// No description provided for @fraction_calendar.
  ///
  /// In pt, this message translates to:
  /// **'Calendário de Reservas'**
  String get fraction_calendar;

  /// No description provided for @fraction_legend_reserved.
  ///
  /// In pt, this message translates to:
  /// **'Reservado'**
  String get fraction_legend_reserved;

  /// No description provided for @fraction_legend_blocked.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueado'**
  String get fraction_legend_blocked;

  /// No description provided for @fraction_legend_premium.
  ///
  /// In pt, this message translates to:
  /// **'Premium'**
  String get fraction_legend_premium;

  /// No description provided for @fraction_occupancy.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard de Ocupação'**
  String get fraction_occupancy;

  /// No description provided for @fraction_your_usage.
  ///
  /// In pt, this message translates to:
  /// **'Sua utilização'**
  String get fraction_your_usage;

  /// No description provided for @fraction_total_occupancy.
  ///
  /// In pt, this message translates to:
  /// **'Ocupação total'**
  String get fraction_total_occupancy;

  /// No description provided for @fraction_future_value.
  ///
  /// In pt, this message translates to:
  /// **'Valor futuro'**
  String get fraction_future_value;

  /// No description provided for @fraction_rental_income.
  ///
  /// In pt, this message translates to:
  /// **'Renda acumulada'**
  String get fraction_rental_income;

  /// No description provided for @fraction_valuation_title.
  ///
  /// In pt, this message translates to:
  /// **'Simulador de Valorização'**
  String get fraction_valuation_title;

  /// No description provided for @fraction_holding_years.
  ///
  /// In pt, this message translates to:
  /// **'Período de retenção'**
  String get fraction_holding_years;

  /// No description provided for @fraction_years.
  ///
  /// In pt, this message translates to:
  /// **'anos'**
  String get fraction_years;

  /// No description provided for @fraction_appreciation.
  ///
  /// In pt, this message translates to:
  /// **'Valorização anual'**
  String get fraction_appreciation;

  /// No description provided for @fraction_yield.
  ///
  /// In pt, this message translates to:
  /// **'Yield anual'**
  String get fraction_yield;

  /// No description provided for @fraction_benchmark.
  ///
  /// In pt, this message translates to:
  /// **'Benchmark de Mercado'**
  String get fraction_benchmark;

  /// No description provided for @fraction_volatility.
  ///
  /// In pt, this message translates to:
  /// **'Volatilidade estimada'**
  String get fraction_volatility;

  /// No description provided for @fraction_cta.
  ///
  /// In pt, this message translates to:
  /// **'Quero investir nesta fração'**
  String get fraction_cta;

  /// No description provided for @edu_section_title.
  ///
  /// In pt, this message translates to:
  /// **'Capacitação'**
  String get edu_section_title;

  /// No description provided for @edu_videos_title.
  ///
  /// In pt, this message translates to:
  /// **'Vídeos e Insights'**
  String get edu_videos_title;

  /// No description provided for @edu_videos_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Como vender imóveis para investimento'**
  String get edu_videos_subtitle;

  /// No description provided for @edu_no_content.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum conteúdo disponível ainda'**
  String get edu_no_content;

  /// No description provided for @edu_coming_soon.
  ///
  /// In pt, this message translates to:
  /// **'Em breve novos vídeos e materiais'**
  String get edu_coming_soon;

  /// No description provided for @partnership_section_title.
  ///
  /// In pt, this message translates to:
  /// **'Parceria'**
  String get partnership_section_title;

  /// No description provided for @partnership_proposals.
  ///
  /// In pt, this message translates to:
  /// **'Proposta de Parceria'**
  String get partnership_proposals;

  /// No description provided for @partnership_title.
  ///
  /// In pt, this message translates to:
  /// **'Proposta de Parceria'**
  String get partnership_title;

  /// No description provided for @partnership_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Torne-se um parceiro estratégico'**
  String get partnership_subtitle;

  /// No description provided for @partnership_audience_title.
  ///
  /// In pt, this message translates to:
  /// **'A quem se destina?'**
  String get partnership_audience_title;

  /// No description provided for @partnership_audience_desc.
  ///
  /// In pt, this message translates to:
  /// **'Nosso programa de parceria é voltado para profissionais do mercado imobiliário.'**
  String get partnership_audience_desc;

  /// No description provided for @partnership_audience_1.
  ///
  /// In pt, this message translates to:
  /// **'Assessores de investimento imobiliário'**
  String get partnership_audience_1;

  /// No description provided for @partnership_audience_2.
  ///
  /// In pt, this message translates to:
  /// **'Corretores com foco em alta renda'**
  String get partnership_audience_2;

  /// No description provided for @partnership_audience_3.
  ///
  /// In pt, this message translates to:
  /// **'Consultores financeiros independentes'**
  String get partnership_audience_3;

  /// No description provided for @partnership_types_title.
  ///
  /// In pt, this message translates to:
  /// **'Tipos de Parceria'**
  String get partnership_types_title;

  /// No description provided for @partnership_vip_title.
  ///
  /// In pt, this message translates to:
  /// **'Consultoria VIP'**
  String get partnership_vip_title;

  /// No description provided for @partnership_vip_desc.
  ///
  /// In pt, this message translates to:
  /// **'Atendimento exclusivo e personalizado para seus clientes.'**
  String get partnership_vip_desc;

  /// No description provided for @partnership_vip_1.
  ///
  /// In pt, this message translates to:
  /// **'Acesso prioritário a lançamentos'**
  String get partnership_vip_1;

  /// No description provided for @partnership_vip_2.
  ///
  /// In pt, this message translates to:
  /// **'Relatórios personalizados'**
  String get partnership_vip_2;

  /// No description provided for @partnership_vip_3.
  ///
  /// In pt, this message translates to:
  /// **'Suporte dedicado'**
  String get partnership_vip_3;

  /// No description provided for @partnership_mentoring_title.
  ///
  /// In pt, this message translates to:
  /// **'Mentoria Estratégica'**
  String get partnership_mentoring_title;

  /// No description provided for @partnership_mentoring_desc.
  ///
  /// In pt, this message translates to:
  /// **'Desenvolvimento profissional com especialistas do setor.'**
  String get partnership_mentoring_desc;

  /// No description provided for @partnership_mentoring_1.
  ///
  /// In pt, this message translates to:
  /// **'Sessões individuais mensais'**
  String get partnership_mentoring_1;

  /// No description provided for @partnership_mentoring_2.
  ///
  /// In pt, this message translates to:
  /// **'Estratégias de captação'**
  String get partnership_mentoring_2;

  /// No description provided for @partnership_mentoring_3.
  ///
  /// In pt, this message translates to:
  /// **'Análise de portfólio'**
  String get partnership_mentoring_3;

  /// No description provided for @partnership_prospecting_title.
  ///
  /// In pt, this message translates to:
  /// **'Prospecção de Negócios'**
  String get partnership_prospecting_title;

  /// No description provided for @partnership_prospecting_desc.
  ///
  /// In pt, this message translates to:
  /// **'Ferramentas e leads para expandir sua carteira.'**
  String get partnership_prospecting_desc;

  /// No description provided for @partnership_prospecting_1.
  ///
  /// In pt, this message translates to:
  /// **'Leads qualificados'**
  String get partnership_prospecting_1;

  /// No description provided for @partnership_prospecting_2.
  ///
  /// In pt, this message translates to:
  /// **'CRM integrado'**
  String get partnership_prospecting_2;

  /// No description provided for @partnership_prospecting_3.
  ///
  /// In pt, this message translates to:
  /// **'Comissões diferenciadas'**
  String get partnership_prospecting_3;

  /// No description provided for @partnership_cta.
  ///
  /// In pt, this message translates to:
  /// **'Quero ser parceiro'**
  String get partnership_cta;

  /// No description provided for @tools_section_title.
  ///
  /// In pt, this message translates to:
  /// **'Ferramentas'**
  String get tools_section_title;

  /// No description provided for @catalog_title.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo de Investimentos'**
  String get catalog_title;

  /// No description provided for @catalog_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Produtos SPE com rentabilidade vs proposta'**
  String get catalog_subtitle;

  /// No description provided for @catalog_no_items.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum produto disponível'**
  String get catalog_no_items;

  /// No description provided for @catalog_return_chart.
  ///
  /// In pt, this message translates to:
  /// **'RENTABILIDADE'**
  String get catalog_return_chart;

  /// No description provided for @catalog_target.
  ///
  /// In pt, this message translates to:
  /// **'Meta'**
  String get catalog_target;

  /// No description provided for @catalog_proposed.
  ///
  /// In pt, this message translates to:
  /// **'Proposta'**
  String get catalog_proposed;

  /// No description provided for @catalog_min_investment.
  ///
  /// In pt, this message translates to:
  /// **'Investimento mínimo'**
  String get catalog_min_investment;

  /// No description provided for @catalog_status_open.
  ///
  /// In pt, this message translates to:
  /// **'Aberto'**
  String get catalog_status_open;

  /// No description provided for @catalog_status_closed.
  ///
  /// In pt, this message translates to:
  /// **'Encerrado'**
  String get catalog_status_closed;

  /// No description provided for @calculator_title.
  ///
  /// In pt, this message translates to:
  /// **'Calculadora de Investimentos'**
  String get calculator_title;

  /// No description provided for @calculator_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Compare imóveis com outros índices de mercado'**
  String get calculator_subtitle;

  /// No description provided for @calc_real_estate.
  ///
  /// In pt, this message translates to:
  /// **'Imóveis'**
  String get calc_real_estate;

  /// No description provided for @calc_savings.
  ///
  /// In pt, this message translates to:
  /// **'Poupança'**
  String get calc_savings;

  /// No description provided for @calc_initial_value.
  ///
  /// In pt, this message translates to:
  /// **'Valor inicial'**
  String get calc_initial_value;

  /// No description provided for @calc_period.
  ///
  /// In pt, this message translates to:
  /// **'Prazo'**
  String get calc_period;

  /// No description provided for @calc_years.
  ///
  /// In pt, this message translates to:
  /// **'anos'**
  String get calc_years;

  /// No description provided for @calc_results.
  ///
  /// In pt, this message translates to:
  /// **'Resultado da Simulação'**
  String get calc_results;

  /// No description provided for @calc_after.
  ///
  /// In pt, this message translates to:
  /// **'Após'**
  String get calc_after;

  /// No description provided for @markets_section_title.
  ///
  /// In pt, this message translates to:
  /// **'Mercados'**
  String get markets_section_title;

  /// No description provided for @market_sp_title.
  ///
  /// In pt, this message translates to:
  /// **'Mercado de São Paulo'**
  String get market_sp_title;

  /// No description provided for @market_sp_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Leads de investidores na região de São Paulo'**
  String get market_sp_subtitle;

  /// No description provided for @market_fl_title.
  ///
  /// In pt, this message translates to:
  /// **'Mercado da Flórida'**
  String get market_fl_title;

  /// No description provided for @market_fl_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Leads de investidores na região da Flórida'**
  String get market_fl_subtitle;

  /// No description provided for @market_no_leads.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum lead disponível no momento'**
  String get market_no_leads;

  /// No description provided for @lead_status_new.
  ///
  /// In pt, this message translates to:
  /// **'Novo'**
  String get lead_status_new;

  /// No description provided for @lead_status_contacted.
  ///
  /// In pt, this message translates to:
  /// **'Contatado'**
  String get lead_status_contacted;

  /// No description provided for @lead_status_qualified.
  ///
  /// In pt, this message translates to:
  /// **'Qualificado'**
  String get lead_status_qualified;

  /// No description provided for @lead_status_closed.
  ///
  /// In pt, this message translates to:
  /// **'Fechado'**
  String get lead_status_closed;

  /// No description provided for @private_launches_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Empreendimentos lançados recentemente'**
  String get private_launches_subtitle;

  /// No description provided for @private_no_launches.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum lançamento recente encontrado'**
  String get private_no_launches;

  /// No description provided for @private_stock.
  ///
  /// In pt, this message translates to:
  /// **'Estoque'**
  String get private_stock;

  /// No description provided for @private_ipo.
  ///
  /// In pt, this message translates to:
  /// **'IPO / FIIs'**
  String get private_ipo;

  /// No description provided for @stock_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Empreendimentos em liquidação com preços abaixo do mercado'**
  String get stock_subtitle;

  /// No description provided for @stock_no_items.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum item em estoque disponível'**
  String get stock_no_items;

  /// No description provided for @stock_liquidation.
  ///
  /// In pt, this message translates to:
  /// **'Liquidação de Estoque'**
  String get stock_liquidation;

  /// No description provided for @stock_units_available.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 unidade disponível} other{{count} unidades disponíveis}}'**
  String stock_units_available(num count);

  /// No description provided for @stock_price_table.
  ///
  /// In pt, this message translates to:
  /// **'Tabela'**
  String get stock_price_table;

  /// No description provided for @stock_price_tabelao.
  ///
  /// In pt, this message translates to:
  /// **'Tabelão'**
  String get stock_price_tabelao;

  /// No description provided for @stock_price_week.
  ///
  /// In pt, this message translates to:
  /// **'Preço Week'**
  String get stock_price_week;

  /// No description provided for @stock_discount.
  ///
  /// In pt, this message translates to:
  /// **'Desconto'**
  String get stock_discount;

  /// No description provided for @stock_payment_conditions.
  ///
  /// In pt, this message translates to:
  /// **'Condições de Pagamento'**
  String get stock_payment_conditions;

  /// No description provided for @stock_down_payment.
  ///
  /// In pt, this message translates to:
  /// **'Entrada'**
  String get stock_down_payment;

  /// No description provided for @stock_installments.
  ///
  /// In pt, this message translates to:
  /// **'Parcelas 30/60/90'**
  String get stock_installments;

  /// No description provided for @stock_financing.
  ///
  /// In pt, this message translates to:
  /// **'Financiamento'**
  String get stock_financing;

  /// No description provided for @stock_first_installment.
  ///
  /// In pt, this message translates to:
  /// **'Primeira parcela'**
  String get stock_first_installment;

  /// No description provided for @stock_last_installment.
  ///
  /// In pt, this message translates to:
  /// **'Última parcela'**
  String get stock_last_installment;

  /// No description provided for @str_analytics_title.
  ///
  /// In pt, this message translates to:
  /// **'Análise STR'**
  String get str_analytics_title;

  /// No description provided for @str_revenue_calc.
  ///
  /// In pt, this message translates to:
  /// **'Calculadora de Receita'**
  String get str_revenue_calc;

  /// No description provided for @str_revenue_calc_sub.
  ///
  /// In pt, this message translates to:
  /// **'Estime a receita mensal e anual de aluguel de curta temporada'**
  String get str_revenue_calc_sub;

  /// No description provided for @str_heatmap.
  ///
  /// In pt, this message translates to:
  /// **'Mapa de Calor'**
  String get str_heatmap;

  /// No description provided for @str_heatmap_sub.
  ///
  /// In pt, this message translates to:
  /// **'Regiões mais rentáveis por score de demanda e ocupação'**
  String get str_heatmap_sub;

  /// No description provided for @str_comp_sets.
  ///
  /// In pt, this message translates to:
  /// **'Comparativo'**
  String get str_comp_sets;

  /// No description provided for @str_comp_sets_sub.
  ///
  /// In pt, this message translates to:
  /// **'Compare listings similares na mesma região'**
  String get str_comp_sets_sub;

  /// No description provided for @str_dynamic_pricing.
  ///
  /// In pt, this message translates to:
  /// **'Preço Dinâmico'**
  String get str_dynamic_pricing;

  /// No description provided for @str_dynamic_pricing_sub.
  ///
  /// In pt, this message translates to:
  /// **'Recomendação de diária por mês baseada em sazonalidade'**
  String get str_dynamic_pricing_sub;

  /// No description provided for @str_seasonality.
  ///
  /// In pt, this message translates to:
  /// **'Sazonalidade'**
  String get str_seasonality;

  /// No description provided for @str_seasonality_sub.
  ///
  /// In pt, this message translates to:
  /// **'Demanda por mês em cada mercado — identifique alta e baixa temporada'**
  String get str_seasonality_sub;

  /// No description provided for @str_properties.
  ///
  /// In pt, this message translates to:
  /// **'Imóveis STR'**
  String get str_properties;

  /// No description provided for @str_properties_sub.
  ///
  /// In pt, this message translates to:
  /// **'Propriedades à venda com projeção de receita de aluguel'**
  String get str_properties_sub;

  /// No description provided for @str_city.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get str_city;

  /// No description provided for @str_bedrooms.
  ///
  /// In pt, this message translates to:
  /// **'Quartos'**
  String get str_bedrooms;

  /// No description provided for @str_bathrooms.
  ///
  /// In pt, this message translates to:
  /// **'Banheiros'**
  String get str_bathrooms;

  /// No description provided for @str_guests.
  ///
  /// In pt, this message translates to:
  /// **'Hóspedes'**
  String get str_guests;

  /// No description provided for @str_calculate.
  ///
  /// In pt, this message translates to:
  /// **'Calcular Receita Estimada'**
  String get str_calculate;

  /// No description provided for @str_estimated_revenue.
  ///
  /// In pt, this message translates to:
  /// **'RECEITA ESTIMADA'**
  String get str_estimated_revenue;

  /// No description provided for @str_adr.
  ///
  /// In pt, this message translates to:
  /// **'Diária média'**
  String get str_adr;

  /// No description provided for @str_occupancy.
  ///
  /// In pt, this message translates to:
  /// **'Ocupação'**
  String get str_occupancy;

  /// No description provided for @str_monthly.
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get str_monthly;

  /// No description provided for @str_annual.
  ///
  /// In pt, this message translates to:
  /// **'Anual'**
  String get str_annual;

  /// No description provided for @str_heat_high.
  ///
  /// In pt, this message translates to:
  /// **'Alta demanda (85+)'**
  String get str_heat_high;

  /// No description provided for @str_heat_medium.
  ///
  /// In pt, this message translates to:
  /// **'Média (75-84)'**
  String get str_heat_medium;

  /// No description provided for @str_heat_low.
  ///
  /// In pt, this message translates to:
  /// **'Moderada (<75)'**
  String get str_heat_low;

  /// No description provided for @str_avg_adr.
  ///
  /// In pt, this message translates to:
  /// **'ADR médio'**
  String get str_avg_adr;

  /// No description provided for @str_avg_occupancy.
  ///
  /// In pt, this message translates to:
  /// **'Ocupação média'**
  String get str_avg_occupancy;

  /// No description provided for @str_listings_count.
  ///
  /// In pt, this message translates to:
  /// **'Listings'**
  String get str_listings_count;

  /// No description provided for @str_listing.
  ///
  /// In pt, this message translates to:
  /// **'Listing'**
  String get str_listing;

  /// No description provided for @str_high_demand.
  ///
  /// In pt, this message translates to:
  /// **'ALTA'**
  String get str_high_demand;

  /// No description provided for @str_insights.
  ///
  /// In pt, this message translates to:
  /// **'Insights de Mercado'**
  String get str_insights;

  /// No description provided for @str_insight_miami.
  ///
  /// In pt, this message translates to:
  /// **'Miami: alta temporada de Jan-Mar (snowbirds) e pico em fevereiro'**
  String get str_insight_miami;

  /// No description provided for @str_insight_orlando.
  ///
  /// In pt, this message translates to:
  /// **'Orlando: pico em Jun-Jul (férias escolares) e Dez (feriados)'**
  String get str_insight_orlando;

  /// No description provided for @str_insight_sp.
  ///
  /// In pt, this message translates to:
  /// **'São Paulo: demanda estável com picos em Jan e Jul (férias)'**
  String get str_insight_sp;

  /// No description provided for @str_insight_rj.
  ///
  /// In pt, this message translates to:
  /// **'Rio: forte em Jan-Fev (verão/carnaval) e Jul (férias de inverno)'**
  String get str_insight_rj;

  /// No description provided for @str_price.
  ///
  /// In pt, this message translates to:
  /// **'Preço'**
  String get str_price;

  /// No description provided for @str_monthly_rev.
  ///
  /// In pt, this message translates to:
  /// **'Receita/mês'**
  String get str_monthly_rev;

  /// No description provided for @str_payback_years.
  ///
  /// In pt, this message translates to:
  /// **'Payback'**
  String get str_payback_years;

  /// No description provided for @str_years.
  ///
  /// In pt, this message translates to:
  /// **'anos'**
  String get str_years;
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
      <String>['en', 'es', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
