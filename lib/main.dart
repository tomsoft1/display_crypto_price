import 'package:flutter/material.dart';
import 'screens/crypto_chart_screen.dart';

void main() {
  runApp(const CryptoPriceChartApp());
}

class CryptoPriceChartApp extends StatelessWidget {
  const CryptoPriceChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Price Chart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CryptoChartScreen(),
    );
  }
}
