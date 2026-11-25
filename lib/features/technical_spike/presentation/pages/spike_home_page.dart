import 'package:flutter/material.dart';
import 'package:uangku/features/technical_spike/data/finance_bridge.dart';
import 'package:uangku/features/technical_spike/data/native_bridge.dart';
import 'package:uangku/features/technical_spike/domain/models/finance_summary.dart';
import 'package:uangku/features/technical_spike/domain/models/finance_transaction.dart';
import 'package:uangku/features/technical_spike/domain/models/native_response.dart';
import 'package:uangku/features/technical_spike/presentation/widgets/connection_result_card.dart';
import 'package:uangku/features/technical_spike/presentation/widgets/finance_summary_card.dart';

class SpikeHomePage extends StatefulWidget {
  const SpikeHomePage({
    super.key,
    NativeBridge? nativeBridge,
    FinanceBridge? financeBridge,
  }) : _nativeBridge = nativeBridge ?? const NativeBridge(),
       _financeBridge = financeBridge ?? const FinanceBridge();

  final NativeBridge _nativeBridge;
  final FinanceBridge _financeBridge;

  @override
  State<SpikeHomePage> createState() => _SpikeHomePageState();
}

class _SpikeHomePageState extends State<SpikeHomePage> {
  ConnectionStatus _status = ConnectionStatus.notTested;
  NativeResponse? _response;
  String? _errorMessage;
  ConnectionStatus _financeStatus = ConnectionStatus.notTested;
  FinanceSummary? _financeSummary;
  String? _financeErrorMessage;

  static const _sampleTransactions = [
    FinanceTransaction(type: 'income', amount: 125000),
    FinanceTransaction(type: 'income', amount: 50000),
    FinanceTransaction(type: 'expense', amount: 25000),
  ];

  Future<void> _testConnection() async {
    if (_status == ConnectionStatus.connecting) {
      return;
    }

    setState(() {
      _status = ConnectionStatus.connecting;
      _response = null;
      _errorMessage = null;
    });

    try {
      final response = await widget._nativeBridge.ping();
      if (!mounted) return;

      setState(() {
        _status = ConnectionStatus.success;
        _response = response;
      });
    } on NativeBridgeException catch (error) {
      if (!mounted) return;

      setState(() {
        _status = ConnectionStatus.error;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _status = ConnectionStatus.error;
        _errorMessage = 'An unexpected error occurred while connecting to the Android bridge.';
      });
    }
  }

  Future<void> _testGoSummary() async {
    if (_financeStatus == ConnectionStatus.connecting) {
      return;
    }

    setState(() {
      _financeStatus = ConnectionStatus.connecting;
      _financeSummary = null;
      _financeErrorMessage = null;
    });

    try {
      final summary = await widget._financeBridge.summarize(
        _sampleTransactions,
      );
      if (!mounted) return;

      setState(() {
        _financeStatus = ConnectionStatus.success;
        _financeSummary = summary;
      });
    } on FinanceBridgeException catch (error) {
      if (!mounted) return;

      setState(() {
        _financeStatus = ConnectionStatus.error;
        _financeErrorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _financeStatus = ConnectionStatus.error;
        _financeErrorMessage =
            'An unexpected error occurred while calling the Go finance bridge.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uangku — Technical Spike 01')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Text(
                'Flutter ↔ Kotlin Native Bridge',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ConnectionResultCard(
                status: _status,
                response: _response,
                errorMessage: _errorMessage,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _status == ConnectionStatus.connecting
                    ? null
                    : _testConnection,
                icon: _status == ConnectionStatus.connecting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link),
                label: const Text('Test Native Connection'),
              ),
              const SizedBox(height: 32),
              Text(
                'Kotlin ↔ Go Finance Bridge',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FinanceSummaryCard(
                status: _financeStatus,
                summary: _financeSummary,
                errorMessage: _financeErrorMessage,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _financeStatus == ConnectionStatus.connecting
                    ? null
                    : _testGoSummary,
                icon: _financeStatus == ConnectionStatus.connecting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate),
                label: const Text('Test Go Finance Summary'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
