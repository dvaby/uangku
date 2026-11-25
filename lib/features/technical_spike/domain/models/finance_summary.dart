class FinanceSummary {
  const FinanceSummary({
    required this.incomeTotal,
    required this.expenseTotal,
    required this.netBalance,
  });

  final int incomeTotal;
  final int expenseTotal;
  final int netBalance;

  factory FinanceSummary.fromMap(Map<Object?, Object?> map) {
    final incomeTotal = map['incomeTotal'];
    final expenseTotal = map['expenseTotal'];
    final netBalance = map['netBalance'];

    if (incomeTotal is! int || expenseTotal is! int || netBalance is! int) {
      throw const FormatException('Invalid Go finance summary response.');
    }

    return FinanceSummary(
      incomeTotal: incomeTotal,
      expenseTotal: expenseTotal,
      netBalance: netBalance,
    );
  }
}
