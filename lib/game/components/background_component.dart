import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../regions/region_data.dart';

/// Procedurally painted parallax background: sky with sun/cloud layer,
/// three depth-graded landmark silhouette bands, a water-reflection strip
/// for coastal/river regions, and a textured road. No external art assets
/// — every region gets a distinct, reasonably rich read purely from
/// shape, gradient shading and multi-speed parallax motion.
class BackgroundComponent extends PositionComponent {
  BackgroundComponent({required this.screenSize, required this.laneXs}) : super(priority: -10);

  final Vector2 screenSize;
  final List<double> laneXs;

  RegionData region = Regions.all.first;
  double _scroll = 0;
  double speed = 200;

  final Random _rng = Random(7);
  late List<double> _farOffsets;
  late List<double> _midOffsets;
  late List<double> _nearOffsets;
  late List<Offset> _cloudSeeds;

  bool get _hasWater => const {
        'mumbai',
        'goa',
        'kerala',
        'varanasi',
        'kashmir',
        'northeast',
      }.contains(region.id);

  @override
  Future<void> onLoad() async {
    size = screenSize;
    _farOffsets = List.generate(6, (i) => _rng.nextDouble());
    _midOffsets = List.generate(5, (i) => _rng.nextDouble());
    _nearOffsets = List.generate(4, (i) => _rng.nextDouble());
    _cloudSeeds = List.generate(5, (i) => Offset(_rng.nextDouble(), _rng.nextDouble() * 0.5));
  }

  void setRegion(RegionData r) => region = r;

  @override
  void update(double dt) {
    super.update(dt);
    _scroll += speed * dt;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x, h = size.y;
    final horizon = h * 0.55;

    _drawSky(canvas, w, horizon);
    _drawClouds(canvas, w, horizon);

    // Three parallax bands: far (slowest), mid, near (fastest) — depth.
    _drawLandmarkLayer(canvas, w, horizon, _shade(region.layerColors[0], 0.85), 0.12, 0, scale: 0.75);
    _drawLandmarkLayer(canvas, w, horizon, region.layerColors[0], 0.22, 1, scale: 0.9);
    _drawLandmarkLayer(canvas, w, horizon, region.layerColors[1], 0.4, 2, scale: 1.15);

    if (_hasWater) _drawWaterStrip(canvas, w, horizon);

    final groundRect = Rect.fromLTWH(0, horizon, w, h - horizon);
    canvas.drawRect(
      groundRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_shade(region.groundColor, 1.1), _shade(region.groundColor, 0.75)],
        ).createShader(groundRect),
    );

    _drawGroundProps(canvas, w, horizon, h);
    _drawRoad(canvas, w, horizon, h);
  }

  void _drawSky(Canvas canvas, double w, double horizon) {
    final skyRect = Rect.fromLTWH(0, 0, w, horizon);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [region.skyTop, region.skyBottom],
        ).createShader(skyRect),
    );

    // Sun/moon disc with soft glow — anchored, gently parallaxes with far layer.
    final sunX = w * 0.74 - (_scroll * 0.03) % (w * 0.3);
    final sunY = horizon * 0.32;
    canvas.drawCircle(Offset(sunX, sunY), 46, Paint()
      ..color = region.accentColor.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22));
    canvas.drawCircle(Offset(sunX, sunY), 20, Paint()
      ..color = Colors.white.withValues(alpha: 0.85));
  }

  void _drawClouds(Canvas canvas, double w, double horizon) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    final offset = (_scroll * 0.05) % (w + 300) - 300;
    for (final seed in _cloudSeeds) {
      final x = (seed.dx * (w + 300) + offset) % (w + 300) - 150;
      final y = horizon * (0.15 + seed.dy);
      canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 70, height: 20), paint);
      canvas.drawOval(Rect.fromCenter(center: Offset(x + 22, y - 6), width: 46, height: 18), paint);
    }
  }

  void _drawWaterStrip(Canvas canvas, double w, double horizon) {
    final stripRect = Rect.fromLTWH(0, horizon - 14, w, 14);
    canvas.drawRect(
      stripRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [region.skyBottom.withValues(alpha: 0.4), region.layerColors[1].withValues(alpha: 0.55)],
        ).createShader(stripRect),
    );
    final shimmer = Paint()..color = Colors.white.withValues(alpha: 0.3);
    final off = (_scroll * 0.4) % 30;
    for (double x = -off; x < w; x += 30) {
      canvas.drawLine(Offset(x, horizon - 6), Offset(x + 12, horizon - 6), shimmer..strokeWidth = 1.2);
    }
  }

  void _drawLandmarkLayer(Canvas canvas, double w, double horizon, Color color, double parallax, int seed,
      {double scale = 1}) {
    final paint = Paint()..color = color;
    final offset = (_scroll * parallax) % (w + 240) - 240;
    final positions = seed == 0
        ? _farOffsets
        : seed == 1
            ? _midOffsets
            : _nearOffsets;
    final spacing = seed == 2 ? 170.0 : 220.0;

    for (int i = -1; i < 5; i++) {
      final baseX = i * spacing + offset;
      for (int j = 0; j < positions.length; j++) {
        final x = baseX + positions[j] * spacing;
        if (x < -150 || x > w + 150) continue;
        canvas.save();
        canvas.translate(x, horizon);
        canvas.scale(scale);
        canvas.translate(-x, -horizon);
        _drawSilhouette(canvas, x, horizon, paint, j + seed * 10);
        canvas.restore();
      }
    }
  }

  void _drawSilhouette(Canvas canvas, double x, double horizon, Paint paint, int variant) {
    final windowPaint = Paint()..color = region.accentColor.withValues(alpha: 0.55);
    switch (region.landmark) {
      case Landmark.mumbaiSkyline:
        final hgt = 44.0 + (variant % 5) * 24;
        final rect = Rect.fromLTWH(x, horizon - hgt, 32, hgt);
        canvas.drawRect(rect, paint);
        for (double yy = horizon - hgt + 8; yy < horizon - 6; yy += 11) {
          for (double xx = x + 5; xx < x + 27; xx += 9) {
            if ((xx + yy).toInt() % 3 == 0) canvas.drawRect(Rect.fromLTWH(xx, yy, 4, 5), windowPaint);
          }
        }
        break;
      case Landmark.goaBeach:
        canvas.drawLine(Offset(x, horizon), Offset(x - 4, horizon - 48),
            Paint()..color = paint.color..strokeWidth = 6..strokeCap = StrokeCap.round);
        for (int k = 0; k < 6; k++) {
          final a = (k - 2.5) * 0.45;
          canvas.drawLine(
            Offset(x - 4, horizon - 48),
            Offset(x - 4 + sin(a) * 24, horizon - 48 - cos(a).abs() * 18),
            Paint()
              ..color = paint.color
              ..strokeWidth = 4
              ..strokeCap = StrokeCap.round,
          );
        }
        break;
      case Landmark.keralaBackwaters:
        canvas.drawLine(Offset(x, horizon), Offset(x, horizon - 52),
            Paint()..color = paint.color..strokeWidth = 5);
        canvas.drawOval(Rect.fromCenter(center: Offset(x, horizon - 56), width: 26, height: 16), paint);
        break;
      case Landmark.bengaluruTech:
        final hgt = 54.0 + (variant % 4) * 28;
        final rect = Rect.fromLTWH(x, horizon - hgt, 28, hgt);
        canvas.drawRect(rect, paint);
        for (double yy = horizon - hgt + 6; yy < horizon - 6; yy += 9) {
          canvas.drawRect(Rect.fromLTWH(x + 3, yy, 22, 4), Paint()..color = region.accentColor.withValues(alpha: 0.35));
        }
        break;
      case Landmark.chennaiTemple:
        final path = Path()..moveTo(x, horizon);
        for (int tier = 0; tier < 4; tier++) {
          final tw = 30.0 - tier * 6;
          final ty = horizon - tier * 15.0;
          path.lineTo(x + (32 - tw) / 2, ty);
          path.lineTo(x + (32 - tw) / 2 + tw, ty);
        }
        path.lineTo(x + 16, horizon - 66);
        path.close();
        canvas.drawPath(path, paint);
        for (int tier = 0; tier < 3; tier++) {
          canvas.drawCircle(Offset(x + 16, horizon - 12 - tier * 15.0), 2, windowPaint);
        }
        break;
      case Landmark.hyderabadCharminar:
        canvas.drawRect(Rect.fromLTWH(x, horizon - 58, 9, 58), paint);
        canvas.drawRect(Rect.fromLTWH(x + 25, horizon - 58, 9, 58), paint);
        canvas.drawArc(Rect.fromLTWH(x, horizon - 74, 34, 32), pi, pi, true, paint);
        canvas.drawCircle(Offset(x + 4.5, horizon - 20), 1.6, windowPaint);
        canvas.drawCircle(Offset(x + 29.5, horizon - 20), 1.6, windowPaint);
        canvas.drawCircle(Offset(x + 4.5, horizon - 40), 1.6, windowPaint);
        canvas.drawCircle(Offset(x + 29.5, horizon - 40), 1.6, windowPaint);
        break;
      case Landmark.jaipurFort:
        final path = Path()
          ..moveTo(x, horizon)
          ..lineTo(x, horizon - 40)
          ..lineTo(x + 5, horizon - 46)
          ..lineTo(x + 5, horizon - 40)
          ..lineTo(x + 10, horizon - 52)
          ..lineTo(x + 15, horizon - 40)
          ..lineTo(x + 15, horizon - 46)
          ..lineTo(x + 20, horizon - 40)
          ..lineTo(x + 20, horizon)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case Landmark.delhiGate:
        canvas.drawRect(Rect.fromLTWH(x, horizon - 48, 11, 48), paint);
        canvas.drawRect(Rect.fromLTWH(x + 27, horizon - 48, 11, 48), paint);
        canvas.drawRect(Rect.fromLTWH(x, horizon - 58, 38, 11), paint);
        canvas.drawArc(Rect.fromLTWH(x + 11, horizon - 42, 16, 42), pi, pi, false,
            Paint()..color = region.skyBottom..style = PaintingStyle.stroke..strokeWidth = 3);
        break;
      case Landmark.varanasiGhats:
        for (int s = 0; s < 5; s++) {
          canvas.drawRect(Rect.fromLTWH(x, horizon - s * 7.5, 42, 7.5), Paint()..color = _shade(paint.color, 1 + s * 0.04));
        }
        canvas.drawCircle(Offset(x + 6, horizon - 4), 1.6, Paint()..color = Colors.orangeAccent.withValues(alpha: 0.8));
        canvas.drawCircle(Offset(x + 34, horizon - 4), 1.6, Paint()..color = Colors.orangeAccent.withValues(alpha: 0.8));
        break;
      case Landmark.northeastHills:
        final path = Path()
          ..moveTo(x, horizon)
          ..lineTo(x + 20, horizon - 48)
          ..lineTo(x + 40, horizon);
        canvas.drawPath(path, paint);
        canvas.drawRect(Rect.fromLTWH(x + 5, horizon - 30, 30, 3),
            Paint()..color = Colors.white.withValues(alpha: 0.25));
        break;
      case Landmark.kashmirValley:
      case Landmark.ladakhPeaks:
        final path = Path()
          ..moveTo(x - 6, horizon)
          ..lineTo(x + 12, horizon - 44)
          ..lineTo(x + 22, horizon - 64)
          ..lineTo(x + 32, horizon - 40)
          ..lineTo(x + 50, horizon)
          ..close();
        canvas.drawPath(path, paint);
        final capPath = Path()
          ..moveTo(x + 15, horizon - 40)
          ..lineTo(x + 22, horizon - 64)
          ..lineTo(x + 29, horizon - 40)
          ..close();
        canvas.drawPath(capPath, Paint()..color = Colors.white.withValues(alpha: 0.9));
        break;
    }
  }

  void _drawGroundProps(Canvas canvas, double w, double horizon, double h) {
    final offset = (_scroll * 0.9) % 160;
    final paint = Paint()..color = _shade(region.groundColor, 0.6).withValues(alpha: 0.7);
    for (double x = -offset; x < w; x += 160) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, horizon + 4, 60, 7), const Radius.circular(3)),
        paint,
      );
    }
  }

  void _drawRoad(Canvas canvas, double w, double horizon, double h) {
    final roadRect = Rect.fromLTWH(w * 0.06, horizon, w * 0.88, h - horizon);
    canvas.drawRect(
      roadRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF34343A), const Color(0xFF201F22)],
        ).createShader(roadRect),
    );

    // Curb strips.
    final curbPaint = Paint()..color = region.accentColor.withValues(alpha: 0.7);
    canvas.drawRect(Rect.fromLTWH(w * 0.06 - 4, horizon, 4, h - horizon), curbPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.94, horizon, 4, h - horizon), curbPaint);

    final dashOffset = (_scroll * 1.4) % 40;
    final dashPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    for (int i = 0; i < laneXs.length - 1; i++) {
      final lx = (laneXs[i] + laneXs[i + 1]) / 2;
      for (double y = horizon - dashOffset; y < h; y += 40) {
        if (y < horizon) continue;
        canvas.drawRect(Rect.fromLTWH(lx - 2, y, 4, 20), dashPaint);
      }
    }
  }

  Color _shade(Color c, double factor) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * factor).clamp(0.0, 1.0)).toColor();
  }
}
