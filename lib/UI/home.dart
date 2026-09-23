import 'package:paintapp/UI/Widgets/colorPickerWidget.dart';
import 'package:paintapp/UI/Widgets/sliderWidget.dart';
import 'package:paintapp/Painters/testPainter.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
