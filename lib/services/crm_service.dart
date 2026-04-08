import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class CrmDashboardData {
  final int activitiesDueToday;
  final int propertiesTotal;
  final int propertiesPending;
  final int propertiesUpdated;
  final int propertiesExpiring;
  final int propertiesOutdated;
  final int proposalsActive;
  final int proposalsDueToday;
  final int rentalsPendingInvoices;
  final int rentalsBoletos7d;
  final int rentalsPendingTransfers;
  final int contractsNotice;
  final int contractsGuaranteesExpiring;
  final int contractsReadjust;
  final int keysWithdrawn;
  final int keysLate;

  CrmDashboardData({
    this.activitiesDueToday = 0,
    this.propertiesTotal = 0,
    this.propertiesPending = 0,
    this.propertiesUpdated = 0,
    this.propertiesExpiring = 0,
    this.propertiesOutdated = 0,
    this.proposalsActive = 0,
    this.proposalsDueToday = 0,
    this.rentalsPendingInvoices = 0,
    this.rentalsBoletos7d = 0,
    this.rentalsPendingTransfers = 0,
    this.contractsNotice = 0,
    this.contractsGuaranteesExpiring = 0,
    this.contractsReadjust = 0,
    this.keysWithdrawn = 0,
    this.keysLate = 0,
  });
}

class CrmService {
  static final _supabase = Supabase.instance.client;

  static Future<CrmDashboardData> fetchDashboard() async {
    final userId = AuthService.currentUserId();
    if (userId == null) return CrmDashboardData();

    final now = DateTime.now();
    final todayStr = now.toIso8601String().substring(0, 10);

    // Activities due today
    final activities = await _supabase
        .from('crm_activities')
        .select('id')
        .eq('completed', false)
        .lte('due_date', '${todayStr}T23:59:59');
    final activitiesDue = (activities as List).length;

    // Properties
    final props = await _supabase.from('crm_properties').select('id, status');
    final propsList = props as List;
    final propsTotal = propsList.length;
    final propsPending = propsList.where((p) => p['status'] == 'pending_approval').length;
    final propsUpdated = propsList.where((p) => p['status'] == 'active').length;
    final propsExpiring = propsList.where((p) => p['status'] == 'expiring').length;
    final propsOutdated = propsList.where((p) => p['status'] == 'outdated').length;

    // Proposals
    final proposals = await _supabase.from('crm_proposals').select('id, status, due_date');
    final proposalsList = proposals as List;
    final propsActive = proposalsList.where((p) => p['status'] == 'active').length;
    final propsDueToday = proposalsList.where((p) =>
        p['status'] == 'active' &&
        p['due_date'] != null &&
        p['due_date'].toString().startsWith(todayStr)).length;

    // Rentals
    final rentals = await _supabase.from('crm_rentals').select('id, status');
    final rentalsList = rentals as List;
    final pendingInvoices = rentalsList.where((r) => r['status'] == 'pending_invoice').length;

    // Contracts
    final contracts = await _supabase.from('crm_contracts').select('id, status');
    final contractsList = contracts as List;
    final contractsNotice = contractsList.where((c) => c['status'] == 'notice').length;
    final contractsGuarantees = contractsList.where((c) => c['status'] == 'guarantee_expiring').length;
    final contractsReadjust = contractsList.where((c) => c['status'] == 'readjust').length;

    // Keys
    final keys = await _supabase.from('crm_keys').select('id, status');
    final keysList = keys as List;
    final keysWithdrawn = keysList.where((k) => k['status'] == 'withdrawn').length;
    final keysLate = keysList.where((k) => k['status'] == 'late').length;

    return CrmDashboardData(
      activitiesDueToday: activitiesDue,
      propertiesTotal: propsTotal,
      propertiesPending: propsPending,
      propertiesUpdated: propsUpdated,
      propertiesExpiring: propsExpiring,
      propertiesOutdated: propsOutdated,
      proposalsActive: propsActive,
      proposalsDueToday: propsDueToday,
      rentalsPendingInvoices: pendingInvoices,
      rentalsBoletos7d: 0,
      rentalsPendingTransfers: 0,
      contractsNotice: contractsNotice,
      contractsGuaranteesExpiring: contractsGuarantees,
      contractsReadjust: contractsReadjust,
      keysWithdrawn: keysWithdrawn,
      keysLate: keysLate,
    );
  }
}
