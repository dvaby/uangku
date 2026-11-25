import 'package:flutter/material.dart';
import 'package:uangku/features/technical_spike/presentation/pages/spike_home_page.dart';

void main() {
  runApp(const UangkuSpikeApp());
}

class UangkuSpikeApp extends StatelessWidget {
  const UangkuSpikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2F4A3A);

    return MaterialApp(
      title: 'Uangku — Technical Spike 01',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      home: const SpikeHomePage(),
    );
  }
}
