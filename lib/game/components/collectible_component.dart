import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../regions/region_data.dart';

/// A "Spark" — the region-flavored collectible. Glows and bobs in place;
/// the game applies magnet attraction toward the player when in range.
class CollectibleComponent extends PositionComponent with CollisionCallbacks {
  CollectibleComponent({required Vector2 position, required this.region})
      : super(position: position, size: Vector2(26, 26), anchor: Anchor.center);

  final RegionData region;
  double _t = 0;
  bool collected = false;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: 13));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt * 6;
  }

  @override
  void render(Canvas canvas) {
    final glow = 0.5 + 0.5 * sin(_t);
    final center = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(center, 13, Paint()..color = region.accentColor.withValues(alpha: 0.18 + glow * 0.15));
    canvas.drawCircle(center, 8, Paint()..color = region.accentColor);
    canvas.drawCircle(center, 8, Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    // Little star glint.
    canvas.drawLine(Offset(center.dx - 4, center.dy), Offset(center.dx + 4, center.dy),
        Paint()..color = Colors.white.withValues(alpha: 0.8)..strokeWidth = 1.5);
    canvas.drawLine(Offset(center.dx, center.dy - 4), Offset(center.dx, center.dy + 4),
        Paint()..color = Colors.white.withValues(alpha: 0.8)..strokeWidth = 1.5);
  }
}

/// Rare pickup that grants the region's themed power-up vehicle: a burst
/// of invincibility, auto-centered lane, and a score multiplier.
class PowerUpComponent extends PositionComponent with CollisionCallbacks {
  PowerUpComponent({required Vector2 position, required this.region})
      : super(position: position, size: Vector2(40, 40), anchor: Anchor.center);

  final RegionData region;
  double _t = 0;
  bool collected = false;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: 20));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt * 4;
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final pulse = 18 + sin(_t) * 3;
    canvas.drawCircle(center, pulse, Paint()..color = Colors.amberAccent.withValues(alpha: 0.35));
    canvas.drawCircle(center, 14, Paint()..color = Colors.amber);
    canvas.drawCircle(
        center, 14, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
  }
}
