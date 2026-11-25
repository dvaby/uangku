import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uangku/core/constants/channel_constants.dart';
import 'package:uangku/features/technical_spike/domain/models/finance_summary.dart';
import 'package:uangku/features/technical_spike/domain/models/finance_transaction.dart';

class FinanceBridge {
  const FinanceBridge({
    this._channel = const MethodChannel(nativeBridgeChannelName),
    this._platformOverride,
  });

  final MethodChannel _channel;
  final TargetPlatform? _platformOverride;

  Future<FinanceSummary> summarize(
    List<FinanceTransaction> transactions,
  ) async {
    if ((_platformOverride ?? defaultTargetPlatform) !=
        TargetPlatform.android) {
      throw const FinanceBridgeException(
        'The Go finance bridge is available on Android only.',
      );
    }

    try {
      final result = await _channel.invokeMethod<Object?>(
        nativeBridgeSummaryMethod,
        {
          'transactionsJson': jsonEncode(
            transactions.map((transaction) => transaction.toJson()).toList(),
          ),
        },
      );

      if (result is! Map<Object?, Object?>) {
        throw const FormatException('Invalid Go finance summary response.');
      }

      return FinanceSummary.fromMap(result);
    } on PlatformException catch (error) {
      final message = switch (error.code) {
        'INVALID_ARGUMENT' => 'Go rejected the transaction data. Use non-negative whole-rupiah amounts.',
        'GO_BRIDGE_UNAVAILABLE' => 'The Go finance bridge is unavailable.',
        _ => 'The Go finance calculation could not be completed.',
      };
      throw FinanceBridgeException(message);
    } on MissingPluginException {
      throw const FinanceBridgeException(
        'The Go finance bridge is unavailable. Rebuild and restart the Android app.',
      );
    } on FinanceBridgeException {
      rethrow;
    } catch (_) {
      throw const FinanceBridgeException(
        'An unexpected error occurred while calling the Go finance bridge.',
      );
    }
  }
}

class FinanceBridgeException implements Exception {
  const FinanceBridgeException(this.message);

  final String message;
}
