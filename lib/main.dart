import 'package:cryptotrack2/home.dart';
import 'package:cryptotrack2/marketRepository.dart';
import 'package:flutter/material.dart';

CryptoMarketRepository repo = CryptoMarketRepository();

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Home()));
  }
}
