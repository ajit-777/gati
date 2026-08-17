import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Color;
import '../game/characters/character_data.dart';
import 'components/background_component.dart';
import 'components/collectible_component.dart';
import 'components/obstacle_component.dart';
import 'components/player_component.dart';
import 'regions/region_data.dart';
import 'systems/save_system.dart';

class _LiveObstacle {
  _LiveObstacle(this.component);
  final ObstacleComponent component;
  bool resolved = false;
}

class _LiveCollectible {
  _LiveCollectible(this.component, {this.isPowerUp = false});
  final PositionComponent component;
  final bool isPowerUp;
  bool resolved = false;
}

/// Core endless-runner loop: three lanes, jump/slide/switch, a region that
/// advances with distance, and the "Gati" momentum meter — the game's own
/// twist on the chase mechanic. Losing all Gati (not just hearts) ends the
/// run, so hitting obstacles is costly even before your hearts run out.
class GatiGame extends FlameGame {
  GatiGame({
    required this.character,
    required this.onGameOver,
    required this.onRegionChanged,
    required this.onHudUpdate,
  });

  final CharacterData character;
  final void Function(double distanceMeters, int sparks) onGameOver;
  final void Function(RegionData region) onRegionChanged;
  final void Function({
    required double distance,
    required double gati,
    required int hearts,
    required int sparks,
    required RegionData region,
  }) onHudUpdate;

  late List<double> laneXs;
  double groundY = 0;
  Vector2 worldSize = Vector2(400, 760);

  late PlayerComponent player;
  late BackgroundComponent background;

  double distance = 0;
  double baseSpeed = 240;
  double speed = 240;
  double gati = 100;
  int hearts = 3;
  int sparks = 0;
  RegionData currentRegion = Regions.all.first;
  bool isGameOver = false;
  bool isPaused = false;

  double _spawnTimer = 0;
  double _powerUpTimer = 12;
  double _speedBoostTimer = 0;
  final Random _rng = Random();

  final List<_LiveObstacle> _obstacles = [];
  final List<_LiveCollectible> _collectibles = [];

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _recomputeLayout(size);
    background = BackgroundComponent(screenSize: worldSize, laneXs: laneXs);
    add(background);

    player = PlayerComponent(character: character, laneXs: laneXs);
    player.position = Vector2(laneXs[1], groundY);
    player.groundY = groundY;
    add(player);

    onHudUpdate(distance: 0, gati: gati, hearts: hearts, sparks: sparks, region: currentRegion);
    onRegionChanged(currentRegion);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _recomputeLayout(size);
    if (isLoaded) {
      background.size = worldSize;
      player.laneXs
        ..clear()
        ..addAll(laneXs);
      player.groundY = groundY;
    }
  }

  void _recomputeLayout(Vector2 size) {
    worldSize = size.clone();
    final w = size.x, h = size.y;
    laneXs = [w * 0.22, w * 0.5, w * 0.78];
    groundY = h * 0.80;
  }

  // ---- Input -------------------------------------------------------------

  void moveLeft() {
    if (!isGameOver) player.moveLeft();
  }

  void moveRight() {
    if (!isGameOver) player.moveRight();
  }

  void jump() {
    if (!isGameOver) player.jump();
  }

  void slide() {
    if (!isGameOver) player.slide();
  }

  // ---- Loop ---------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || !isLoaded) return;

    distance += (speed * dt) / 45.0;
    gati = (gati + (4.5 + character.gatiRegenBonus * 10) * dt).clamp(0, 100);

    baseSpeed = 240 + min(distance, 12000) * 0.028;
    speed = _speedBoostTimer > 0 ? baseSpeed * 1.6 : baseSpeed;
    if (_speedBoostTimer > 0) _speedBoostTimer -= dt;
    background.speed = speed;

    final region = Regions.forDistance(distance);
    if (region.id != currentRegion.id) {
      currentRegion = region;
      background.setRegion(region);
      onRegionChanged(region);
    }

    _updateSpawning(dt);
    _updateObstacles(dt);
    _updateCollectibles(dt);

    onHudUpdate(distance: distance, gati: gati, hearts: hearts, sparks: sparks, region: currentRegion);

    if (gati <= 0 || hearts <= 0) {
      _endRun();
    }
  }

  void _updateSpawning(double dt) {
    _spawnTimer -= dt;
    _powerUpTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnWave();
      final interval = (0.95 - min(distance, 9000) / 9000 * 0.45);
      _spawnTimer = interval.clamp(0.5, 0.95);
    }
    if (_powerUpTimer <= 0) {
      _spawnPowerUp();
      _powerUpTimer = 16 + _rng.nextDouble() * 8;
    }
  }

  void _spawnWave() {
    final blockedLanes = <int>{};
    final laneCount = laneXs.length;
    final obstacleLanes = 1 + _rng.nextInt(laneCount - 1); // leave >=1 lane open
    final lanes = List.generate(laneCount, (i) => i)..shuffle(_rng);
    for (int i = 0; i < obstacleLanes; i++) {
      blockedLanes.add(lanes[i]);
    }

    for (final lane in blockedLanes) {
      final kindRoll = _rng.nextDouble();
      final kind = kindRoll < 0.4
          ? ObstacleKind.low
          : kindRoll < 0.7
              ? ObstacleKind.high
              : ObstacleKind.full;
      final flavor = currentRegion.obstacleFlavors[_rng.nextInt(currentRegion.obstacleFlavors.length)];
      final comp = ObstacleComponent(
        position: Vector2(laneXs[lane], -60),
        kind: kind,
        region: currentRegion,
        label: flavor,
      );
      add(comp);
      _obstacles.add(_LiveObstacle(comp));
    }

    // Sprinkle sparks in an open lane as a reward for choosing it.
    final openLanes = List.generate(laneCount, (i) => i).where((l) => !blockedLanes.contains(l)).toList();
    if (openLanes.isNotEmpty && _rng.nextDouble() < 0.8) {
      final lane = openLanes[_rng.nextInt(openLanes.length)];
      for (int i = 0; i < 3; i++) {
        final comp = CollectibleComponent(
          position: Vector2(laneXs[lane], -60 - i * 34),
          region: currentRegion,
        );
        add(comp);
        _collectibles.add(_LiveCollectible(comp));
      }
    }
  }

  void _spawnPowerUp() {
    final lane = _rng.nextInt(laneXs.length);
    final comp = PowerUpComponent(position: Vector2(laneXs[lane], -80), region: currentRegion);
    add(comp);
    _collectibles.add(_LiveCollectible(comp, isPowerUp: true));
  }

  void _updateObstacles(double dt) {
    for (final o in List.of(_obstacles)) {
      o.component.position.y += speed * dt;

      if (!o.resolved && (o.component.position.x - player.x).abs() < 18) {
        final band = (o.component.position.y - groundY).abs();
        if (band < 30) {
          o.resolved = true;
          final avoided = (o.component.kind == ObstacleKind.low && player.isJumping) ||
              (o.component.kind == ObstacleKind.high && player.isSliding);
          if (avoided) {
            sparks += 1; // near-miss bonus
          } else if (!player.isInvincible) {
            _hitObstacle();
          }
        }
      }

      if (o.component.position.y > worldSize.y + 80) {
        o.component.removeFromParent();
        _obstacles.remove(o);
      }
    }
  }

  void _updateCollectibles(double dt) {
    for (final c in List.of(_collectibles)) {
      c.component.position.y += speed * dt;

      final magnetRadius = (c.isPowerUp ? 70 : 46) + character.magnetRadiusBonus * 60;
      final dx = player.x - c.component.position.x;
      final dy = groundY - c.component.position.y;
      final dist = sqrt(dx * dx + dy * dy);
      if (!c.resolved && dist < magnetRadius && dist > 6) {
        c.component.position.x += dx * min(1, 6 * dt);
      }

      if (!c.resolved && dist < 22) {
        c.resolved = true;
        if (c.isPowerUp) {
          _speedBoostTimer = 3.5;
          player.flashInvincible(3.5);
          sparks += 5;
        } else {
          sparks += 1;
          gati = (gati + 8).clamp(0, 100);
        }
        c.component.removeFromParent();
        _collectibles.remove(c);
      } else if (c.component.position.y > worldSize.y + 80) {
        c.component.removeFromParent();
        _collectibles.remove(c);
      }
    }
  }

  void _hitObstacle() {
    hearts -= 1;
    gati = (gati - 28).clamp(0, 100);
    player.flashInvincible(1.3);
  }

  void _endRun() {
    if (isGameOver) return;
    isGameOver = true;
    unawaited(SaveSystem.setBestDistanceIfHigher(distance));
    unawaited(SaveSystem.addSparks(sparks));
    onGameOver(distance, sparks);
  }
}
