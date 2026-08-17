import 'package:flutter/material.dart';
import '../../game/regions/region_data.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({
    super.key,
    required this.distanceMeters,
    required this.gati,
    required this.hearts,
    required this.sparks,
    required this.region,
  });

  final double distanceMeters;
  final double gati;
  final int hearts;
  final int sparks;
  final RegionData region;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(distanceMeters).toStringAsFixed(0)} m',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                  Text(
                    region.name,
                    style: TextStyle(
                      color: region.accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      shadows: const [Shadow(color: Colors.black54, blurRadius: 3)],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(3, (i) {
                  final filled = i < hearts;
                  return Icon(
                    filled ? Icons.favorite : Icons.favorite_border,
                    color: filled ? Colors.redAccent : Colors.white38,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 16),
                  const SizedBox(width: 3),
                  Text('$sparks', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Gati meter — the game's momentum bar; if it hits zero, the
          // regional "chase" (monsoon wave, dust storm, avalanche...) catches you.
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (gati / 100).clamp(0, 1),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      gati < 30 ? Colors.redAccent : const Color(0xFFFF8A3D),
                      Colors.amberAccent,
                    ]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
