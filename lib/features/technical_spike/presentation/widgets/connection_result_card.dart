import 'package:flutter/material.dart';
import 'package:uangku/features/technical_spike/domain/models/native_response.dart';

enum ConnectionStatus { notTested, connecting, success, error }

class ConnectionResultCard extends StatelessWidget {
  const ConnectionResultCard({
    required this.status,
    this.response,
    this.errorMessage,
    super.key,
  });

  final ConnectionStatus status;
  final NativeResponse? response;
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
            if (response case final result?) ...[
              _ResultRow(label: 'Message', value: result.message),
              _ResultRow(label: 'Platform', value: result.platform),
              _ResultRow(
                label: 'Android SDK',
                value: result.sdkInt.toString(),
              ),
            ] else if (errorMessage case final message?) ...[
              Text(message, style: TextStyle(color: colorScheme.error)),
            ] else
              const Text('Tap the button to test the native connection.'),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          SelectableText(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
