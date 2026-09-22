import 'dart:async';

import 'package:cryptotrack2/candleModel.dart';
import 'package:cryptotrack2/candlePainter.dart';
import 'package:cryptotrack2/colorPickerWidget.dart';
import 'package:cryptotrack2/marketRepository.dart';
import 'package:cryptotrack2/mockCryptoRepository.dart';
import 'package:cryptotrack2/sliderWidget.dart';
import 'package:cryptotrack2/testPainter.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late CryptoMarketRepository repo;
  StreamSubscription<Candle>? _candleSubscription;

  final MockCryptoRepository mockRepo = MockCryptoRepository();
  final List<Candle> _candles = [];

  double _scale = 1.0;
  double _baseScale = 1.0;
  double _offsetX = 0.0;
  double baseOffsetX = 0.0;
  double _offsetY = 0.0;
  double baseOffsetY = 0.0;

  @override
  void initState() {
    super.initState();
    repo = CryptoMarketRepository();

   // _loadInitialDataAndStartStream();
  }

  void loadMockData() {
    DateTime now = DateTime.now().subtract(const Duration(minutes: 20));
    double basePrice = 63800.0;

    for (int i = 0; i < 20; i++) {
      double open = basePrice + (i * 3);
      double close = open + ((i % 2 == 0 ? 1 : -1) * 25);
      _candles.add(
        Candle(
          date: now.add(Duration(minutes: i)),
          open: open,
          high: (open > close ? open : close) + 150,
          low: (open < close ? open : close) - 150,
          close: close,
          volume: 5000,
        ),
      );
      basePrice = close;
    }
    mockRepo.startLiveStream();

    mockRepo.candleStream.listen((newCandle) {
      if (!mounted) return;
      setState(() {
        if (_candles.isEmpty) {
          _candles.add(newCandle);
        } else {
          final lastCandle = _candles.last;
          if (lastCandle.date.minute == newCandle.date.minute) {
            // Son mumu canlı güncelle
            _candles[_candles.length - 1] = newCandle;
          } else {
            // Yeni dakikaya geçildi, yeni mum ekle
            _candles.add(newCandle);
          }
        }
      });
    });
  }

  Future<void> _loadInitialDataAndStartStream() async {
    try {
      // 1. Geçmiş 50 mumu çek
      final history = await repo.fetchCandleHistory('btcusdt');
      setState(() {
        _candles.clear();
        _candles.addAll(history);
      });

      // 2. Canlı yayını başlat
      repo.startCandleStream('btcusdt');

      _candleSubscription = repo.candleStream.listen((newCandle) {
        debugPrint("CANLI FİYAT GELDİ: ${newCandle.close}");

        setState(() {
          if (_candles.isEmpty) {
            _candles.add(newCandle);
            return;
          }

          final lastIndex = _candles.length - 1;
          final lastCandle = _candles.last;

          // Ayni dakikanin mumu mu?
          if (lastCandle.date.minute == newCandle.date.minute) {
            _candles[lastIndex] =
                newCandle; // Doğrudan güncelleyebilirsin, shouldRepaint = true olduğu için çalışır!
          } else {
            _candles.add(newCandle);
            if (_candles.length > 50) {
              _candles.removeAt(0);
            }
          }
        });
      });
      resetChart();
    } catch (e) {
      debugPrint("Hata oluştu: $e");
    }
  }

  void resetChart() {
    if (_candles.isEmpty) return;

    // Widget/Ekran genişliğini alıyoruz (MediaQuery veya Context üzerinden)
    double screenWidth = MediaQuery.of(context).size.width;

    // Painter içindeki sabit mum genişliği
    double candleWidth = screenWidth / 25;

    // Son mumun indeksi
    int lastIndex = _candles.length - 1;

    // Son mumun "offset'siz" varsayılan X konumu
    double lastCandleRawX = (lastIndex * candleWidth);

    double targetX = screenWidth * 0.80;

    setState(() {
      _scale = _scale;
      _offsetY = 0.0;
      _offsetX = targetX - lastCandleRawX;
    });
  }

  @override
  void dispose() {
    mockRepo.dispose();
    _candleSubscription?.cancel();
    repo.dispose();
    super.dispose();
  }

  final List<Cizgi> cizgiler = [];
  Color selectedColor = Colors.white;

  double awidth = 1;
  double aopacity = 1;
  double asaturation = 1;
  double abright = 1;
  bool isRgbOpen = false;
  bool isSetOpen = false;
  @override
  Widget build(BuildContext context) {
    HSVColor hsvColor = HSVColor.fromColor(selectedColor);
    Color sonRenk = hsvColor
        .withSaturation(asaturation)
        .withValue(abright)
        .toColor()
        .withValues(alpha: aopacity);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 14, 17),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white70),
          onPressed: () {
            setState(() {
              isSetOpen = !isSetOpen;
            });
          },
        ),
        title: GestureDetector(
          onTap: () {
            setState(() {
              isRgbOpen = !isRgbOpen;
            });
          },
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: sonRenk,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white70),
            tooltip: "Reset",
            onPressed: () => cizgiler.clear(),
          ),
        ],
        backgroundColor: const Color(0xFF1E222D),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SizedBox.expand(
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      cizgiler.add(
                        Cizgi(
                          points: [details.localPosition], // İlk noktayı koyduk
                          adjWidth: awidth, // O anki kalınlığı verdik
                          color: sonRenk,
                        ),
                      );
                    });
                  },

                  onPanUpdate: (details) {
                    setState(() {
                      cizgiler.last.points.add(details.localPosition);
                    });
                  },

                  onPanEnd: (details) {},
                  child: CustomPaint(painter: TestPaint(cizgi: cizgiler)),
                ),
              ),
            ),
            if (isRgbOpen)
              RgbColorPicker(
                size: 150,
                onColorSelected: (p0) {
                  setState(() {
                    selectedColor = p0;
                    hsvColor = HSVColor.fromColor(p0);
                  });
                },
              ),
            if (isSetOpen)
              Column(
                children: [
                  CustomSliderSection(
                    label: 'Parlaklık',
                    value: abright,
                    min: 0.0, // 0.0 = Tam Siyah
                    max: 1.0,
                    onChanged: (value) {
                      setState(() {
                        abright = value;
                      });
                    },
                  ),
                  CustomSliderSection(
                    label: 'Opaklık',
                    min: 0.1,
                    max: 1,
                    value: aopacity,
                    onChanged: (value) {
                      setState(() {
                        aopacity = value;
                      });
                    },
                  ),
                  CustomSliderSection(
                    label: 'Doygunluk',
                    min: 0.0,
                    max: 1,
                    value: asaturation,
                    onChanged: (value) {
                      setState(() {
                        asaturation = value;
                      });
                    },
                  ),
                  CustomSliderSection(
                    label: 'Boyut',
                    min: 1,
                    max: 20,
                    value: awidth,
                    onChanged: (value) {
                      setState(() {
                        awidth = value;
                      });
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
