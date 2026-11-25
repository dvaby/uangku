import 'package:flutter/material.dart';
import 'package:uangku/features/technical_spike/data/native_bridge.dart';
import 'package:uangku/features/technical_spike/domain/models/native_response.dart';
import 'package:uangku/features/technical_spike/presentation/widgets/connection_result_card.dart';

class SpikeHomePage extends StatefulWidget {
  const SpikeHomePage({super.key, NativeBridge? nativeBridge})
    : _nativeBridge = nativeBridge ?? const NativeBridge();

  final NativeBridge _nativeBridge;

  @override
  State<SpikeHomePage> createState() => _SpikeHomePageState();
}

class _SpikeHomePageState extends State<SpikeHomePage> {
  ConnectionStatus _status = ConnectionStatus.notTested;
  NativeResponse? _response;
  String? _errorMessage;

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
        _errorMessage =
            'An unexpected error occurred while connecting to the Android bridge.';
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
            ],
          ),
        ),
      ),
    );
  }
}
