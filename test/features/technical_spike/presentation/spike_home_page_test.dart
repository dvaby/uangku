import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/core/constants/channel_constants.dart';
import 'package:uangku/features/technical_spike/data/native_bridge.dart';
import 'package:uangku/features/technical_spike/presentation/pages/spike_home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(nativeBridgeChannelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  testWidgets('shows initial state and renders Kotlin ping response', (
    tester,
  ) async {
    MethodCall? receivedCall;
    messenger.setMockMethodCallHandler(channel, (call) async {
      receivedCall = call;
      return <String, Object>{
        'message': 'Pong dari Kotlin!',
        'platform': 'Android Native',
        'sdkInt': 35,
      };
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SpikeHomePage(
          nativeBridge: NativeBridge(platformOverride: TargetPlatform.android),
        ),
      ),
    );
    expect(find.text('NOT TESTED'), findsOneWidget);

    await tester.tap(find.text('Test Native Connection'));
    await tester.pumpAndSettle();

    expect(receivedCall?.method, 'ping');
    expect(find.text('SUCCESS'), findsOneWidget);
    expect(find.text('Pong dari Kotlin!'), findsOneWidget);
    expect(find.text('Android Native'), findsOneWidget);
    expect(find.text('35'), findsOneWidget);
  });

  testWidgets('shows a clear error without exposing platform details', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(
        code: 'BRIDGE_FAILURE',
        message: 'sensitive diagnostic detail',
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SpikeHomePage(
          nativeBridge: NativeBridge(platformOverride: TargetPlatform.android),
        ),
      ),
    );
    await tester.tap(find.text('Test Native Connection'));
    await tester.pumpAndSettle();

    expect(find.text('ERROR'), findsOneWidget);
    expect(find.textContaining('BRIDGE_FAILURE'), findsOneWidget);
    expect(find.textContaining('sensitive diagnostic detail'), findsNothing);
  });

  testWidgets('reports a missing native handler safely', (tester) async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw MissingPluginException();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SpikeHomePage(
          nativeBridge: NativeBridge(platformOverride: TargetPlatform.android),
        ),
      ),
    );
    await tester.tap(find.text('Test Native Connection'));
    await tester.pumpAndSettle();

    expect(find.text('ERROR'), findsOneWidget);
    expect(find.textContaining('Native bridge is unavailable'), findsOneWidget);
  });

  testWidgets('rejects non-Android platforms without invoking the channel', (
    tester,
  ) async {
    var methodCallCount = 0;
    messenger.setMockMethodCallHandler(channel, (_) async {
      methodCallCount++;
      return null;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SpikeHomePage(
          nativeBridge: NativeBridge(platformOverride: TargetPlatform.linux),
        ),
      ),
    );
    await tester.tap(find.text('Test Native Connection'));
    await tester.pumpAndSettle();

    expect(find.text('ERROR'), findsOneWidget);
    expect(find.textContaining('Android only'), findsOneWidget);
    expect(methodCallCount, 0);
  });

  testWidgets('prevents a second request while the first is connecting', (
    tester,
  ) async {
    final responseCompleter = Completer<Object?>();
    var methodCallCount = 0;
    messenger.setMockMethodCallHandler(channel, (_) {
      methodCallCount++;
      return responseCompleter.future;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SpikeHomePage(
          nativeBridge: NativeBridge(platformOverride: TargetPlatform.android),
        ),
      ),
    );
    await tester.tap(find.text('Test Native Connection'));
    await tester.pump();

    expect(find.text('CONNECTING'), findsOneWidget);
    await tester.tap(find.text('Test Native Connection'));
    expect(methodCallCount, 1);

    responseCompleter.complete(<String, Object>{
      'message': 'Pong dari Kotlin!',
      'platform': 'Android Native',
      'sdkInt': 35,
    });
    await tester.pumpAndSettle();

    expect(find.text('SUCCESS'), findsOneWidget);
    expect(methodCallCount, 1);
  });
}
