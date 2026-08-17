import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../characters/character_data.dart';

enum ObstacleAvoidance { none, jump, slide }

/// The runner. Drawn procedurally with a jointed skeleton (hip/knee/ankle,
/// shoulder/elbow/wrist) so the gait actually reads as running rather than
/// a static figure sliding across the screen — no external art assets,
/// but real forward-kinematic limb motion, gradient shading and a
/// per-character silhouette (headwear/accessory) instead of flat shapes.
class PlayerComponent extends PositionComponent with CollisionCallbacks {
  PlayerComponent({required this.character, required this.laneXs})
      : super(size: Vector2(58, 88), anchor: Anchor.bottomCenter);

  final CharacterData character;
  final List<double> laneXs;

  int lane = 1;
  double groundY = 0;

  double _jumpVelocity = 0;
  double jumpOffset = 0; // negative = up
  bool get isJumping => jumpOffset < -1;
  bool isSliding = false;
  double _slideTimer = 0;

  double _runCycle = 0;
  double invincibleTimer = 0;
  bool get isInvincible => invincibleTimer > 0;

  static const double gravity = 2600;
  static const double jumpSpeed = 900;
  static const double laneSwitchSpeed = 14;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: Vector2(34, 56), position: Vector2(12, 20)));
  }

  void moveLeft() {
    if (lane > 0) lane--;
  }

  void moveRight() {
    if (lane < laneXs.length - 1) lane++;
  }

  void jump() {
    if (!isJumping && !isSliding) {
      _jumpVelocity = -jumpSpeed;
    }
  }

  void slide() {
    if (!isJumping) {
      isSliding = true;
      _slideTimer = 0.55;
    }
  }

  void flashInvincible(double seconds) {
    invincibleTimer = max(invincibleTimer, seconds);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final stride = isJumping ? 5.5 : 13.5;
    _runCycle += dt * stride;

    final targetX = laneXs[lane];
    final dx = targetX - x;
    x += dx * min(1, laneSwitchSpeed * dt);

    if (isJumping || jumpOffset < 0) {
      jumpOffset += _jumpVelocity * dt;
      _jumpVelocity += gravity * dt;
      if (jumpOffset >= 0) {
        jumpOffset = 0;
        _jumpVelocity = 0;
      }
    }

    if (isSliding) {
      _slideTimer -= dt;
      if (_slideTimer <= 0) isSliding = false;
    }

    if (invincibleTimer > 0) invincibleTimer -= dt;

    y = groundY + jumpOffset;
  }

  @override
  void render(Canvas canvas) {
    final opacity = isInvincible ? (0.55 + 0.45 * sin(_runCycle * 4)) : 1.0;
    final t = _runCycle;

    // Ground contact shadow — widens/darkens on the ground, shrinks in air.
    final airLift = (-jumpOffset).clamp(0, 160) / 160;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 3),
        width: 36 * (1 - airLift * 0.5),
        height: 9 * (1 - airLift * 0.5),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: (0.32 - airLift * 0.18) * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    if (isSliding) {
      _renderSliding(canvas, opacity);
    } else {
      _renderRunning(canvas, t, opacity);
    }
  }

  // ---- Running pose: hip/knee/ankle + shoulder/elbow/wrist chains --------

  void _renderRunning(Canvas canvas, double t, double opacity) {
    final grounded = !isJumping;
    final lean = grounded ? 0.10 : -0.05;
    final bob = grounded ? sin(t * 2).abs() * 4 : 0.0;

    final hipY = size.y - 34 - bob;
    final hipX = size.x / 2;

    // Leg swing: thigh leads, shin trails/bends more during the recovery
    // (backswing) half of the cycle — the thing that actually sells "run".
    void leg(double phase, Color skin) {
      final thighAngle = (grounded ? sin(t + phase) : 0.35) * 0.95 + lean;
      final recovery = grounded ? max(0, -sin(t + phase)) : 0.6;
      final shinBend = recovery * 1.35;
      final shinAngle = thighAngle - shinBend;

      final knee = _extend(Offset(hipX, hipY), thighAngle, 24);
      final ankle = _extend(knee, shinAngle, 22);

      _bone(canvas, Offset(hipX, hipY), knee, 8.5, skin, opacity);
      _bone(canvas, knee, ankle, 6.5, skin, opacity);
      // Foot
      final footAngle = shinAngle + 0.6;
      final toe = _extend(ankle, footAngle, 11);
      canvas.drawLine(ankle, toe, Paint()
        ..color = const Color(0xFF2A2118).withValues(alpha: opacity)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round);
    }

    // Back leg first (drawn behind torso), front leg after.
    leg(pi, _shade(character.skinColor, 0.8));
    _renderTorsoAndHead(canvas, hipX, hipY, lean, t, opacity);
    leg(0, character.skinColor);

    void arm(double phase) {
      final shoulderY = hipY - 34;
      final upperAngle = sin(t + phase) * 0.85 - lean * 0.5;
      final elbowBend = 0.5 + max(0, sin(t + phase)) * 0.5;
      final elbow = _extend(Offset(hipX, shoulderY), upperAngle, 17);
      final wrist = _extend(elbow, upperAngle - elbowBend, 16);
      _bone(canvas, Offset(hipX, shoulderY), elbow, 6.5, character.skinColor, opacity);
      _bone(canvas, elbow, wrist, 5.5, character.skinColor, opacity);
    }

    arm(pi);
    arm(0);

    _drawAccessory(canvas, hipX, hipY - 34, opacity, t);
  }

  void _renderSliding(Canvas canvas, double opacity) {
    final baseY = size.y - 20;
    final skin = Paint()..color = character.skinColor.withValues(alpha: opacity);
    final outfit = Paint()
      ..shader = LinearGradient(
        colors: [character.outfitPrimary.withValues(alpha: opacity), _shade(character.outfitPrimary, 0.75).withValues(alpha: opacity)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(4, baseY - 20, size.x - 8, 24));

    // Low, elongated torso — a crouch/slide silhouette.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(4, baseY - 20, size.x - 8, 24), const Radius.circular(12)),
      outfit,
    );
    // Tucked legs
    canvas.drawLine(Offset(size.x - 10, baseY), Offset(size.x + 4, baseY - 6),
        Paint()..color = const Color(0xFF2A2118).withValues(alpha: opacity)..strokeWidth = 7..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(10, baseY), Offset(-2, baseY - 4),
        Paint()..color = const Color(0xFF2A2118).withValues(alpha: opacity)..strokeWidth = 7..strokeCap = StrokeCap.round);
    // Head tucked low
    canvas.drawCircle(Offset(size.x - 16, baseY - 26), 12, skin);
  }

  void _renderTorsoAndHead(Canvas canvas, double hipX, double hipY, double lean, double t, double opacity) {
    final shoulderY = hipY - 34;
    final shoulderX = hipX + lean * 14;

    final torsoRect = Rect.fromLTRB(hipX - 13, shoulderY, hipX + 13, hipY + 6);
    canvas.save();
    canvas.translate((shoulderX - hipX) * 0.5, 0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(torsoRect, const Radius.circular(9)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _shade(character.outfitPrimary, 1.18).withValues(alpha: opacity),
            character.outfitPrimary.withValues(alpha: opacity),
            _shade(character.outfitPrimary, 0.7).withValues(alpha: opacity),
          ],
        ).createShader(torsoRect),
    );
    canvas.restore();

    // Neck + head with subtle shading.
    final headCenter = Offset(shoulderX, shoulderY - 15);
    canvas.drawLine(Offset(shoulderX, shoulderY), headCenter, Paint()
      ..color = character.skinColor.withValues(alpha: opacity)
      ..strokeWidth = 8);

    final headRect = Rect.fromCircle(center: headCenter, radius: 12.5);
    canvas.drawOval(
      headRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          colors: [
            _shade(character.skinColor, 1.15).withValues(alpha: opacity),
            character.skinColor.withValues(alpha: opacity),
            _shade(character.skinColor, 0.8).withValues(alpha: opacity),
          ],
        ).createShader(headRect),
    );

    // Simple face: eye + hint of a smile so it reads as a person, not a blob.
    canvas.drawCircle(headCenter + const Offset(4, -1), 1.4, Paint()..color = Colors.black.withValues(alpha: opacity * 0.8));

    _drawHair(canvas, headCenter, opacity);
  }

  void _drawHair(Canvas canvas, Offset headCenter, double opacity) {
    final hairPaint = Paint()..color = const Color(0xFF2A2118).withValues(alpha: opacity);
    switch (character.bodyType) {
      case BodyType.schoolKid:
        canvas.drawArc(Rect.fromCircle(center: headCenter + const Offset(0, -1), radius: 12.5), pi, pi, true, hairPaint);
        break;
      case BodyType.collegeStudent:
        canvas.drawArc(Rect.fromCircle(center: headCenter + const Offset(0, -1), radius: 12.5), pi, pi, true, hairPaint);
        // ponytail
        canvas.drawLine(headCenter + const Offset(11, -4), headCenter + const Offset(20, 8), hairPaint..strokeWidth = 5);
        break;
      case BodyType.deliveryRider:
        // helmet
        canvas.drawOval(Rect.fromCenter(center: headCenter + const Offset(0, -1), width: 27, height: 27),
            Paint()..color = character.outfitAccent.withValues(alpha: opacity));
        canvas.drawRect(Rect.fromLTWH(headCenter.dx - 13, headCenter.dy + 2, 26, 5),
            Paint()..color = Colors.black.withValues(alpha: opacity * 0.6));
        break;
      case BodyType.cricketPlayer:
        // cap with brim
        canvas.drawArc(Rect.fromCircle(center: headCenter + const Offset(0, -2), radius: 13), pi, pi, true,
            Paint()..color = character.outfitPrimary.withValues(alpha: opacity));
        canvas.drawOval(Rect.fromCenter(center: headCenter + const Offset(8, 2), width: 14, height: 6),
            Paint()..color = character.outfitPrimary.withValues(alpha: opacity));
        break;
      case BodyType.dancer:
        canvas.drawArc(Rect.fromCircle(center: headCenter + const Offset(0, -1), radius: 12.5), pi, pi, true, hairPaint);
        canvas.drawCircle(headCenter + const Offset(-9, -6), 3, Paint()..color = character.outfitAccent.withValues(alpha: opacity));
        break;
    }
  }

  void _drawAccessory(Canvas canvas, double hipX, double shoulderY, double opacity, double t) {
    final accentPaint = Paint()..color = character.outfitAccent.withValues(alpha: opacity);
    switch (character.bodyType) {
      case BodyType.schoolKid:
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(hipX - 15, shoulderY + 2, 30, 20), const Radius.circular(6)),
          accentPaint..color = accentPaint.color.withValues(alpha: opacity * 0.9),
        );
        break;
      case BodyType.collegeStudent:
        canvas.drawLine(Offset(hipX - 13, shoulderY), Offset(hipX + 10, shoulderY + 32),
            Paint()..color = character.outfitAccent.withValues(alpha: opacity)..strokeWidth = 3.5);
        break;
      case BodyType.deliveryRider:
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(hipX - 11, shoulderY, 22, 22), const Radius.circular(4)),
          accentPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(hipX - 11, shoulderY, 22, 22),
          Paint()
            ..color = Colors.black.withValues(alpha: 0.35 * opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
        break;
      case BodyType.cricketPlayer:
        final swing = sin(t) * 0.3;
        canvas.save();
        canvas.translate(hipX + 13, shoulderY + 10);
        canvas.rotate(0.5 + swing);
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-3, 0, 6, 30), const Radius.circular(3)),
          Paint()..color = const Color(0xFFD8B378).withValues(alpha: opacity),
        );
        canvas.restore();
        break;
      case BodyType.dancer:
        final flare = 8 + sin(t * 2).abs() * 4;
        canvas.drawArc(Rect.fromLTWH(hipX - 14 - flare / 2, shoulderY + 24, 28 + flare, 20), 0, pi, false, accentPaint);
        break;
    }
  }

  // ---- helpers -------------------------------------------------------------

  Offset _extend(Offset origin, double angle, double length) {
    return origin + Offset(sin(angle) * length, cos(angle) * length);
  }

  void _bone(Canvas canvas, Offset a, Offset b, double thickness, Color color, double opacity) {
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round,
    );
  }

  Color _shade(Color c, double factor) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * factor).clamp(0.0, 1.0)).toColor();
  }
}
