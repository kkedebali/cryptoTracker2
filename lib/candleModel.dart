class Candle {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  Candle({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  bool get isBullish => close >= open;

  factory Candle.fromJson(Map<String, dynamic> json) {
    final kline = json['k'];
    return Candle(
      date: DateTime.fromMillisecondsSinceEpoch(kline['t']),
      open: double.parse(kline['o']),
      high: double.parse(kline['h']),
      low: double.parse(kline['l']),
      close: double.parse(kline['c']),
      volume: double.parse(kline['v']),
    );
  }
}