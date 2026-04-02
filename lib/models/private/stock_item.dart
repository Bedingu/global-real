class StockItem {
  final String id;
  final String name;
  final String description;
  final String region;
  final String unitRef;
  final double areaM2;
  final String deliveryDate;
  final int availableUnits;

  // Preços
  final double priceTable;
  final double priceTabelao;
  final double priceWeek;

  // Condições de pagamento
  final double downPaymentPct;    // ex: 0.20
  final double downPaymentValue;  // ex: 40800
  final int installments306090;   // ex: 3
  final double installmentValue;  // ex: 13600
  final double financingTotal;    // ex: 326400
  final double firstInstallment;  // ex: 3790
  final double lastInstallment;   // ex: 915

  final String? imageUrl;
  final DateTime createdAt;

  const StockItem({
    required this.id,
    required this.name,
    required this.description,
    required this.region,
    required this.unitRef,
    required this.areaM2,
    required this.deliveryDate,
    required this.availableUnits,
    required this.priceTable,
    required this.priceTabelao,
    required this.priceWeek,
    required this.downPaymentPct,
    required this.downPaymentValue,
    required this.installments306090,
    required this.installmentValue,
    required this.financingTotal,
    required this.firstInstallment,
    required this.lastInstallment,
    this.imageUrl,
    required this.createdAt,
  });

  double get discountPct =>
      priceTable > 0 ? ((priceTable - priceWeek) / priceTable * 100) : 0;

  factory StockItem.fromJson(Map<String, dynamic> j) {
    double d(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0;
      return 0;
    }

    return StockItem(
      id: j['id'].toString(),
      name: j['name'] ?? '',
      description: j['description'] ?? '',
      region: j['region'] ?? '',
      unitRef: j['unit_ref'] ?? '',
      areaM2: d(j['area_m2']),
      deliveryDate: j['delivery_date'] ?? '',
      availableUnits: j['available_units'] ?? 0,
      priceTable: d(j['price_table']),
      priceTabelao: d(j['price_tabelao']),
      priceWeek: d(j['price_week']),
      downPaymentPct: d(j['down_payment_pct']),
      downPaymentValue: d(j['down_payment_value']),
      installments306090: j['installments_306090'] ?? 3,
      installmentValue: d(j['installment_value']),
      financingTotal: d(j['financing_total']),
      firstInstallment: d(j['first_installment']),
      lastInstallment: d(j['last_installment']),
      imageUrl: j['image_url'],
      createdAt: j['created_at'] != null
          ? DateTime.parse(j['created_at'])
          : DateTime.now(),
    );
  }
}
