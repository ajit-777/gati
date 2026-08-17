import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../regions/region_data.dart';

/// How the player must avoid it.
enum ObstacleKind {
  low, // jump over
  high, // slide under
  full, // change lane
}

class ObstacleComponent extends PositionComponent with CollisionCallbacks {
  ObstacleComponent({
    required Vector2 position,
    required this.kind,
    required this.region,
    required this.label,
  }) : super(
          position: position,
          size: kind == ObstacleKind.high ? Vector2(52, 26) : Vector2(46, 54),
          anchor: Anchor.bottomCenter,
        );

  final ObstacleKind kind;
  final RegionData region;
  final String label;
  bool passed = false;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      size: Vector2(size.x - 8, size.y - 6),
      position: Vector2(4, 3),
    ));
  }

  @override
  void render(Canvas canvas) {
    final basePaint = Paint()..color = region.accentColor.withValues(alpha: 0.95);
    final darkPaint = Paint()..color = Colors.black.withValues(alpha: 0.25);

    switch (kind) {
      case ObstacleKind.full:
        // Full-width barrier — cart / stall silhouette.
        final rect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 8, size.x, size.y - 8), const Radius.circular(6));
        canvas.drawRRect(rect, basePaint);
        canvas.drawRRect(rect, Paint()..color = darkPaint.color..style = PaintingStyle.stroke..strokeWidth = 2);
        // wheels
        canvas.drawCircle(Offset(10, size.y - 2), 6, Paint()..color = const Color(0xFF2A2A2A));
        canvas.drawCircle(Offset(size.x - 10, size.y - 2), 6, Paint()..color = const Color(0xFF2A2A2A));
        break;
      case ObstacleKind.low:
        // Pole / barrier that must be jumped.
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(size.x / 2 - 6, 0, 12, size.y), const Radius.circular(4)),
          basePaint,
        );
        canvas.drawRect(Rect.fromLTWH(0, size.y - 10, size.x, 8), darkPaint);
        break;
      case ObstacleKind.high:
        // Overhead beam that must be slid under.
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(6)),
          basePaint,
        );
        canvas.drawLine(const Offset(4, 4), Offset(size.x - 4, 4), Paint()..color = darkPaint.color..strokeWidth = 3);
        break;
    }
  }
}
