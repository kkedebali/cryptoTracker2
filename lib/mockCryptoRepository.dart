import 'dart:async';
import 'dart:math';

import 'package:cryptotrack2/candleModel.dart';

class MockCryptoRepository {

  final StreamController<Candle> _controller =
      StreamController<Candle>.broadcast();
      
  Timer? _timer;
  double _currentPrice = 64000.0;
  DateTime _currentMinute = DateTime.now();
  final Random _random = Random();

  Stream<Candle> get candleStream => _controller.stream;

  void startLiveStream() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Rastgele fiyat hareketi (-15$ ile +15$ arası)
      double change = (_random.nextDouble() - 0.48) * 30;
      _currentPrice += change;

      DateTime now = DateTime.now();
      // Dakika değişti mi kontrolü
      if (now.minute != _currentMinute.minute) {
        _currentMinute = now;
      }

      Candle liveCandle = Candle(
        date: DateTime(
          _currentMinute.year,
          _currentMinute.month,
          _currentMinute.day,
          _currentMinute.hour,
          _currentMinute.minute,
        ),
        open: _currentPrice - change,
        high: _currentPrice + _random.nextDouble() * 5,
        low: _currentPrice - _random.nextDouble() * 5,
        close: _currentPrice,
        volume: 1000 + _random.nextDouble() * 500,
      );

      _controller.add(liveCandle);
    });
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
