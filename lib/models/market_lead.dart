class MarketLead {
  final String id;
  final String market;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String interest;
  final double? budget;
  final String status;
  final String notes;
  final int aiScore;
  final String aiSummary;
  final String? assignedTo;
  final List<Map<String, dynamic>> aiRecommendations;
  final DateTime createdAt;

  MarketLead({
    required this.id,
    required this.market,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.interest,
    this.budget,
    required this.status,
    required this.notes,
    required this.aiScore,
    required this.aiSummary,
    this.assignedTo,
    this.aiRecommendations = const [],
    required this.createdAt,
  });

  factory MarketLead.fromJson(Map<String, dynamic> json) {
    return MarketLead(
      id: json['id'] ?? '',
      market: json['market'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      company: json['company'] ?? '',
      interest: json['interest'] ?? '',
      budget: (json['budget'] as num?)?.toDouble(),
      status: json['status'] ?? 'new',
      notes: json['notes'] ?? '',
      aiScore: json['ai_score'] ?? 0,
      aiSummary: json['ai_summary'] ?? '',
      assignedTo: json['assigned_to'],
      aiRecommendations: json['ai_recommendations'] != null
          ? List<Map<String, dynamic>>.from(
              (json['ai_recommendations'] as List).map((e) => Map<String, dynamic>.from(e)))
          : [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'new': return 'Novo';
      case 'contacted': return 'Contatado';
      case 'qualified': return 'Qualificado';
      case 'closed': return 'Fechado';
      default: return status;
    }
  }

  String get marketLabel => market == 'sao_paulo' ? 'São Paulo' : 'Florida';
}
