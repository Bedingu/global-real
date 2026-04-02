class FractionWeek {
  final DateTime start;
  bool isReserved;
  bool isBlocked;

  FractionWeek({
    required this.start,
    this.isReserved = false,
    this.isBlocked = false,
  });
}