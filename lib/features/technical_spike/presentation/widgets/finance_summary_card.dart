import 'package:flutter/material.dart';
import 'package:uangku/features/technical_spike/domain/models/finance_summary.dart';
import 'package:uangku/features/technical_spike/presentation/widgets/connection_result_card.dart';

class FinanceSummaryCard extends StatelessWidget {
  const FinanceSummaryCard({
    required this.status,
    this.summary,
    this.errorMessage,
    super.key,
  });

  final ConnectionStatus status;
  final FinanceSummary? summary;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      ConnectionStatus.notTested => ('NOT TESTED', colorScheme.outline),
      ConnectionStatus.connecting => ('CONNECTING', colorScheme.primary),
      ConnectionStatus.success => ('SUCCESS', colorScheme.primary),
      ConnectionStatus.error => ('ERROR', colorScheme.error),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 16),
            if (summary case final result?) ...[
              _SummaryRow(label: 'Total income', amount: result.incomeTotal),
              _SummaryRow(label: 'Total expense', amount: result.expenseTotal),
              _SummaryRow(label: 'Net balance', amount: result.netBalance),
            ] else if (errorMessage case final message?) ...[
              Text(message, style: TextStyle(color: colorScheme.error)),
            ] else
              const Text('Run Go to calculate the sample transactions.'),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          SelectableText(
            'Rp $amount',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
