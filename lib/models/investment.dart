class Investment {
  final String id;
  final String name;
  final String city;
  final String country;
  final double amount;
  final String currency;

  Investment({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.amount,
    required this.currency,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      country: json['country'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
    );
  }
}
