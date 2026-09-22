import 'dart:math' as math;

import 'package:cryptotrack2/rgbWheel.dart';
import 'package:flutter/material.dart';

class RgbColorPicker extends StatefulWidget {
  final Function(Color) onColorSelected;
  final double size;


  const RgbColorPicker({
    super.key,
    required this.onColorSelected,
    this.size = 200,
  });

  @override
  State<RgbColorPicker> createState() => _RgbColorPickerState();
}

class _RgbColorPickerState extends State<RgbColorPicker> {
  Offset? dokunulanKonum;
  Color secilenRenk = Colors.red;

  void _renkGuncelle(Offset localPosition) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    double radians = math.atan2(dy, dx);
    double degrees = radians * (180 / math.pi);
    if (degrees < 0) degrees += 360;

    final color = HSVColor.fromAHSV(1.0, degrees, 1.0, 1.0).toColor();

    setState(() {
      dokunulanKonum = localPosition;
      secilenRenk = color;
    });

    widget.onColorSelected(color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      // Stack doğrudan renk çemberi bileşeninin içinde!
      child: Stack(
        clipBehavior:
            Clip.none, // Önizleme kutusu çemberin dışına biraz taşabilsin
        children: [
          // 1. KATMAN: Renk Çemberi ve Dokunma Alanı
          GestureDetector(
            onPanStart: (details) => _renkGuncelle(
              details.localPosition

            ),
            onPanUpdate: (details) => _renkGuncelle(
              details.localPosition

            ),
            onPanEnd: (_) {
              setState(() {
                dokunulanKonum = null; // Parmağı kaldırınca önizleme kaybolur
              });
            },
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: RgbWheelPainter(),
            ),
          ),

          // 2. KATMAN: Dokunulduğunda Çıkan Önizleme Kutusu
          if (dokunulanKonum != null)
            Positioned(
              left: dokunulanKonum!.dx - 25, // Kutuyu yatayda ortala (50 / 2)
              top: dokunulanKonum!.dy - 65, // Parmağın 65px üzerinde dursun
              child: IgnorePointer(
                // Dokunma olaylarını engellemesin
                child: placeHolder(secilenRenk),
              ),
            ),
        ],
      ),
    );
  }
}

Widget placeHolder(Color renk) {
  return Container(
    height: 50,
    width: 50,
    decoration: BoxDecoration(
      color: renk,
      shape: BoxShape.circle, // Daire şeklinde önizleme
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
    ),
  );
}
