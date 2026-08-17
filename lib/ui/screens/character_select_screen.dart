import 'package:flutter/material.dart';
import '../../game/characters/character_data.dart';
import '../../game/systems/save_system.dart';

class CharacterSelectScreen extends StatefulWidget {
  const CharacterSelectScreen({super.key});

  @override
  State<CharacterSelectScreen> createState() => _CharacterSelectScreenState();
}

class _CharacterSelectScreenState extends State<CharacterSelectScreen> {
  late String _selected = SaveSystem.selectedCharacterId;
  late List<String> _unlocked = SaveSystem.unlockedCharacterIds;

  Future<void> _onTapCharacter(CharacterData c) async {
    if (_unlocked.contains(c.id)) {
      await SaveSystem.selectCharacter(c.id);
      setState(() => _selected = c.id);
      return;
    }

    final sparks = SaveSystem.totalSparks;
    if (sparks < c.unlockCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Need ${c.unlockCost - sparks} more Sparks to unlock ${c.name}')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Unlock ${c.name}?'),
        content: Text('Spend ${c.unlockCost} Sparks to unlock ${c.name}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unlock')),
        ],
      ),
    );
    if (confirmed == true) {
      final spent = await SaveSystem.spendSparks(c.unlockCost);
      if (spent) {
        await SaveSystem.unlockCharacter(c.id);
        await SaveSystem.selectCharacter(c.id);
        setState(() {
          _unlocked = SaveSystem.unlockedCharacterIds;
          _selected = c.id;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1030),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Choose your runner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.78,
          ),
          itemCount: CharacterCatalog.all.length,
          itemBuilder: (context, i) {
            final c = CharacterCatalog.all[i];
            final unlocked = _unlocked.contains(c.id);
            final isSelected = _selected == c.id;
            return GestureDetector(
              onTap: () => _onTapCharacter(c),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1B44),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF8A3D) : Colors.white12,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(70, 90),
                            painter: _CharacterPreviewPainter(c, dim: !unlocked),
                          ),
                          if (!unlocked)
                            const Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(Icons.lock, color: Colors.white54, size: 18),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      unlocked ? (isSelected ? 'Selected' : 'Tap to select') : '${c.unlockCost} Sparks',
                      style: TextStyle(
                        color: unlocked ? Colors.white54 : Colors.amberAccent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CharacterPreviewPainter extends CustomPainter {
  _CharacterPreviewPainter(this.c, {required this.dim});
  final CharacterData c;
  final bool dim;

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = dim ? 0.35 : 1.0;
    final skin = Paint()..color = c.skinColor.withValues(alpha: alpha);
    final outfit = Paint()..color = c.outfitPrimary.withValues(alpha: alpha);
    final accent = Paint()..color = c.outfitAccent.withValues(alpha: alpha);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width / 2 - 16, 34, 32, 44), const Radius.circular(10)),
      outfit,
    );
    canvas.drawCircle(Offset(size.width / 2, 24), 15, skin);
    canvas.drawArc(Rect.fromCircle(center: Offset(size.width / 2, 21), radius: 15), 3.14, 3.14, true,
        Paint()..color = const Color(0xFF2A2118).withValues(alpha: alpha));

    switch (c.bodyType) {
      case BodyType.schoolKid:
        canvas.drawRect(Rect.fromLTWH(size.width / 2 - 17, 38, 34, 6), accent);
        break;
      case BodyType.collegeStudent:
        canvas.drawLine(Offset(size.width / 2 - 15, 36), Offset(size.width / 2 + 12, 74),
            Paint()..color = c.outfitAccent.withValues(alpha: alpha)..strokeWidth = 4);
        break;
      case BodyType.deliveryRider:
        canvas.drawRect(Rect.fromLTWH(size.width / 2 - 13, 36, 26, 24), accent);
        break;
      case BodyType.cricketPlayer:
        canvas.drawLine(Offset(size.width / 2 + 15, 30), Offset(size.width / 2 + 28, 70),
            Paint()..color = const Color(0xFFD8B378).withValues(alpha: alpha)..strokeWidth = 5..strokeCap = StrokeCap.round);
        break;
      case BodyType.dancer:
        canvas.drawArc(Rect.fromLTWH(size.width / 2 - 20, 60, 40, 22), 0, 3.14, false, accent);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CharacterPreviewPainter oldDelegate) => false;
}
