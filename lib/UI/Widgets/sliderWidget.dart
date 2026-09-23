import 'package:flutter/material.dart';

class CustomSliderSection extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const CustomSliderSection({
    super.key,
    required this.label,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                // İsteğe bağlı: Seçili değeri anlık yüzde/sayı olarak görmek için
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Text(
                    max == 1.0 
                        ? '%${(value * 100).toInt()}' // Opaklık/Saturation için % cinsinden
                        : value.toStringAsFixed(1),   // Boyut için 1.5 gibi küsuratlı
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Slider(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}