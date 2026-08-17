import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../game/characters/character_data.dart';
import '../../game/gati_game.dart';
import '../../game/regions/region_data.dart';
import '../../game/systems/save_system.dart';
import '../widgets/hud_overlay.dart';
import '../widgets/region_banner.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GatiGame _game;
  double _distance = 0;
  double _gati = 100;
  int _hearts = 3;
  int _sparks = 0;
  RegionData _region = Regions.all.first;
  String? _bannerRegion;
  String? _bannerTagline;
  bool _endedHandled = false;

  @override
  void initState() {
    super.initState();
    final character = CharacterCatalog.byId(SaveSystem.selectedCharacterId);
    _game = GatiGame(
      character: character,
      onHudUpdate: ({required distance, required gati, required hearts, required sparks, required region}) {
        _safeSetState(() {
          _distance = distance;
          _gati = gati;
          _hearts = hearts;
          _sparks = sparks;
          _region = region;
        });
      },
      onRegionChanged: (region) {
        _safeSetState(() {
          _bannerRegion = region.name;
          _bannerTagline = region.tagline;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _safeSetState(() => _bannerRegion = null);
        });
      },
      onGameOver: (distance, sparks) {
        if (_endedHandled || !mounted) return;
        _endedHandled = true;
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => GameOverScreen(
                distanceMeters: distance,
                sparksEarned: sparks,
                regionReached: _region,
              ),
            ),
          );
        });
      },
    );
  }

  /// Flame's [GameWidget] can call back into the game (and thus these
  /// listeners) while it is itself mid-build (e.g. inside its internal
  /// LayoutBuilder during onGameResize/onLoad). setState is illegal there,
  /// so always apply the update on the next frame instead.
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(fn);
    });
  }

  // A single pan gesture, resolved by dominant axis on release. Using
  // separate onVerticalDragEnd/onHorizontalDragEnd recognizers made them
  // fight each other in the gesture arena — neither reliably won, so
  // left/right often did nothing. Tracking one pan avoids that entirely.
  Offset? _panStart;
  Offset _panCurrent = Offset.zero;

  void _onPanStart(DragStartDetails d) {
    _panStart = d.globalPosition;
    _panCurrent = d.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _panCurrent = d.globalPosition;
  }

  void _onPanEnd(DragEndDetails d) {
    final start = _panStart;
    _panStart = null;
    if (start == null) return;
    final delta = _panCurrent - start;
    const threshold = 24.0;
    if (delta.distance < threshold) {
      _game.jump(); // treat as a tap
      return;
    }
    if (delta.dx.abs() > delta.dy.abs()) {
      if (delta.dx < 0) {
        _game.moveLeft();
      } else {
        _game.moveRight();
      }
    } else {
      if (delta.dy < 0) {
        _game.jump();
      } else {
        _game.slide();
      }
    }
  }

  final FocusNode _focusNode = FocusNode();

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.keyA:
        _game.moveLeft();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.keyD:
        _game.moveRight();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
      case LogicalKeyboardKey.keyW:
      case LogicalKeyboardKey.space:
        _game.jump();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
      case LogicalKeyboardKey.keyS:
        _game.slide();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: _game)),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
              ),
            ),
            SafeArea(
              child: HudOverlay(
                distanceMeters: _distance,
                gati: _gati,
                hearts: _hearts,
                sparks: _sparks,
                region: _region,
              ),
            ),
            if (_bannerRegion != null)
              Align(
                alignment: Alignment.center,
                child: RegionBanner(name: _bannerRegion!, tagline: _bannerTagline ?? ''),
              ),
          ],
        ),
      ),
    );
  }
}
