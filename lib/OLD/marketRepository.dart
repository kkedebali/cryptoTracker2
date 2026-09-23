import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:paintapp/OLD/candleModel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class CryptoMarketRepository {
  Isolate? _isolate;
  ReceivePort? _receivePort;

  // Ana thread'e akan işlenmiş mum verileri
  final StreamController<Candle> _candleController =
      StreamController<Candle>.broadcast();
  Stream<Candle> get candleStream => _candleController.stream;

  Future<void> startCandleStream(String symbol) async {
    _receivePort = ReceivePort();

    // 2. threadi oluştur kutuya gönder
    _isolate = await Isolate.spawn(
      _isolateEntryPoint,
      _IsolateInitParams(
        sendPort: _receivePort!.sendPort,
        symbol: symbol.toLowerCase(),
      ),
    );

    // gönderilen kutuyu dinle
    _receivePort!.listen((message) {
      if (message is Map<String, dynamic>) {
        final candle = Candle.fromJson(message);
        _candleController.add(candle);
      }
    });
  }

  Future<List<Candle>> fetchCandleHistory(String symbol) async {
  
    final url = Uri.parse(
      'https://api.binance.com/api/v3/klines?symbol=${symbol.toUpperCase()}&interval=1m&limit=50',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) {
        return Candle(
          date: DateTime.fromMillisecondsSinceEpoch(item[0]),
          open: double.parse(item[1]),
          high: double.parse(item[2]),
          low: double.parse(item[3]),
          close: double.parse(item[4]),
          volume: double.parse(item[5]),
        );
      }).toList();
    } else {
      throw Exception('Geçmiş mum verileri çekilemedi!');
    }
  }

  // Isolate içinde çalışacak isolasyonlu fonksiyon
  static void _isolateEntryPoint(_IsolateInitParams params) {
    final channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/ws/${params.symbol}@kline_1m'),
    );

    channel.stream.listen((rawData) {
      // string parsing ve JSON çözme işlemi UI'a dokunmadan burada gerçekleşir
      final Map<String, dynamic> parsedJson = jsonDecode(rawData as String);
      params.sendPort.send(parsedJson);
    });
  }

  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    _candleController.close();
  }
}

class _IsolateInitParams {
  final SendPort sendPort;
  final String symbol;

  _IsolateInitParams({required this.sendPort, required this.symbol});
}
