import 'package:cryptotrack2/candleModel.dart';
import 'package:flutter/material.dart';

class CandlePainter extends CustomPainter {
  final List<Candle> candles;
  final double scale;
  final double offsetX;
  final double offsetY;

  CandlePainter({
    required this.candles,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    double candleWidth = size.width / 25;

    // 1. YALNIZCA EKRANDA GÖRÜNEN MUMLARI BUL VE ONLARA GÖRE ÖLÇEKLEN (Ortalama)
    List<Candle> visibleCandles = [];
    for (int i = 0; i < candles.length; i++) {
      double x = (i * candleWidth) + (candleWidth / 2) + offsetX;
      if (x >= -candleWidth && x <= size.width + candleWidth) {
        visibleCandles.add(candles[i]);
      }
    }

    // Görünür mum yoksa tüm listeyi baz al
    final targetCandles = visibleCandles.isNotEmpty ? visibleCandles : candles;

    double maxPrice = targetCandles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    double minPrice = targetCandles.map((c) => c.low).reduce((a, b) => a < b ? a : b);

    if (maxPrice == minPrice) {
      maxPrice += 1;
      minPrice -= 1;
    }
    
    // Üstten ve alttan %10 marj bırak (Ortalama hissi verir)
    double priceMargin = (maxPrice - minPrice) * 0.1;
    maxPrice += priceMargin;
    minPrice -= priceMargin;
    double priceRange = maxPrice - minPrice;

    // 2. Dikey Zoom ve Y Kaydırması Eklenmiş Koordinat Dönüştürücü
    double centerY = size.height / 2;

    double priceToY(double price) {
      // Temel Y pozisyonu
      double rawY = size.height - ((price - minPrice) / priceRange * size.height);
      
      // Zoom ve offsetY (Dikey kaydırma) uygulaması
      return centerY + (rawY - centerY) * scale + offsetY;
    }

    final greenPaint = Paint()..color = const Color(0xFF00C076);
    final redPaint = Paint()..color = const Color(0xFFFF0055);
    final wickPaint = Paint()..strokeWidth = 1.2;

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      double x = (i * candleWidth) + (candleWidth / 2) + offsetX;

      if (x < -candleWidth || x > size.width + candleWidth) continue;

      double highY = priceToY(candle.high);
      double lowY = priceToY(candle.low);
      double openY = priceToY(candle.open);
      double closeY = priceToY(candle.close);

      bool isBullish = candle.isBullish;
      Paint currentPaint = isBullish ? greenPaint : redPaint;
      wickPaint.color = isBullish ? const Color(0xFF00C076) : const Color(0xFFFF0055);

      // Fitil
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      // Gövde
      double topY = isBullish ? closeY : openY;
      double bottomY = isBullish ? openY : closeY;
      double bodyHeight = (bottomY - topY).abs();
      if (bodyHeight < 1) bodyHeight = 1;

      Rect bodyRect = Rect.fromLTWH(
        x - (candleWidth * 0.35),
        topY,
        candleWidth * 0.7,
        bodyHeight,
      );

      canvas.drawRect(bodyRect, currentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CandlePainter oldDelegate) {
    return true;
  }
}