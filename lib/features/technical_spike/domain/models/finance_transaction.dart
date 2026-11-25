class FinanceTransaction {
  const FinanceTransaction({required this.type, required this.amount});

  final String type;
  final int amount;

  Map<String, Object> toJson() => {'type': type, 'amount': amount};
}
