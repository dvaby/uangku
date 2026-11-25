import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uangku/core/constants/channel_constants.dart';
import 'package:uangku/features/technical_spike/domain/models/native_response.dart';

class NativeBridge {
  const NativeBridge({
    this._channel = const MethodChannel(nativeBridgeChannelName),
    this._platformOverride,
  });

  final MethodChannel _channel;
  final TargetPlatform? _platformOverride;

  Future<NativeResponse> ping() async {
    if ((_platformOverride ?? defaultTargetPlatform) !=
        TargetPlatform.android) {
      throw const NativeBridgeException(
        'Native connection is available on Android only.',
      );
    }

    try {
      final result = await _channel.invokeMethod<Object?>(
        nativeBridgePingMethod,
      );

      if (result is! Map<Object?, Object?>) {
        throw const FormatException('Invalid native bridge response.');
      }

      return NativeResponse.fromMap(result);
    } on PlatformException catch (error) {
      throw NativeBridgeException(
        'Native bridge failed (code: ${error.code}).',
      );
    } on MissingPluginException {
      throw const NativeBridgeException(
        'Native bridge is unavailable. Restart or reinstall the Android app.',
      );
    } on NativeBridgeException {
      rethrow;
    } catch (_) {
      throw const NativeBridgeException(
        'An unexpected error occurred while connecting to the Android bridge.',
      );
    }
  }
}

class NativeBridgeException implements Exception {
  const NativeBridgeException(this.message);

  final String message;
}
