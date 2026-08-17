import 'package:flutter/material.dart';
import '../../game/regions/region_data.dart';
import '../../game/systems/save_system.dart';
import 'game_screen.dart';
import 'home_screen.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    super.key,
    required this.distanceMeters,
    required this.sparksEarned,
    required this.regionReached,
  });

  final double distanceMeters;
  final int sparksEarned;
  final RegionData regionReached;

  @override
  Widget build(BuildContext context) {
    final isBest = distanceMeters >= SaveSystem.bestDistance;
    final km = (distanceMeters / 1000).toStringAsFixed(2);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [regionReached.skyTop, const Color(0xFF1E1030)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isBest ? Icons.emoji_events : Icons.flag_circle,
                  color: Colors.amberAccent,
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  isBest ? 'New Best!' : 'Run Ended',
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Caught by ${regionReached.chaseFlavor} in ${regionReached.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 28),
                _StatRow(label: 'Distance', value: '$km km'),
                _StatRow(label: 'Region reached', value: regionReached.name),
                _StatRow(label: 'Sparks earned', value: '$sparksEarned'),
                _StatRow(label: 'Total Sparks', value: '${SaveSystem.totalSparks}'),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    ),
                    icon: const Icon(Icons.replay),
                    label: const Text('RUN AGAIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A3D),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  ),
                  child: const Text('Home', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 15)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
