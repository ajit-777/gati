import 'package:flutter/material.dart';

/// Body-shape archetype, drawn procedurally by PlayerComponent.
enum BodyType { schoolKid, collegeStudent, deliveryRider, cricketPlayer, dancer }

class CharacterData {
  final String id;
  final String name;
  final String description;
  final BodyType bodyType;
  final Color skinColor;
  final Color outfitPrimary;
  final Color outfitAccent;

  /// Sparks (coins) needed to unlock. 0 = unlocked from the start.
  final int unlockCost;

  /// Small gameplay flavor bonuses — kept subtle so no character feels
  /// mandatory, just a light nudge toward a playstyle.
  final double magnetRadiusBonus;
  final double gatiRegenBonus;

  const CharacterData({
    required this.id,
    required this.name,
    required this.description,
    required this.bodyType,
    required this.skinColor,
    required this.outfitPrimary,
    required this.outfitAccent,
    required this.unlockCost,
    this.magnetRadiusBonus = 0,
    this.gatiRegenBonus = 0,
  });
}

class CharacterCatalog {
  static const List<CharacterData> all = [
    CharacterData(
      id: 'school_kid',
      name: 'Aarav',
      description: 'School kid racing to beat the first bell. Quick on his feet.',
      bodyType: BodyType.schoolKid,
      skinColor: Color(0xFFC98A5A),
      outfitPrimary: Color(0xFF2C4E8A),
      outfitAccent: Color(0xFFE8E8E8),
      unlockCost: 0,
      gatiRegenBonus: 0.15,
    ),
    CharacterData(
      id: 'college_student',
      name: 'Meera',
      description: 'College student with a tote bag full of notes and a bus to catch.',
      bodyType: BodyType.collegeStudent,
      skinColor: Color(0xFFA9704A),
      outfitPrimary: Color(0xFF6B3FA0),
      outfitAccent: Color(0xFFFFD166),
      unlockCost: 500,
      magnetRadiusBonus: 0.2,
    ),
    CharacterData(
      id: 'delivery_rider',
      name: 'Imran',
      description: 'Delivery rider, orange box on his back, ten minutes on the clock.',
      bodyType: BodyType.deliveryRider,
      skinColor: Color(0xFF8A5A3B),
      outfitPrimary: Color(0xFFE8622D),
      outfitAccent: Color(0xFF1A1A1A),
      unlockCost: 1200,
      gatiRegenBonus: 0.25,
    ),
    CharacterData(
      id: 'cricket_player',
      name: 'Rohan',
      description: 'Gully cricket star, bat slung over his shoulder, always sprinting a quick single.',
      bodyType: BodyType.cricketPlayer,
      skinColor: Color(0xFFB57A4E),
      outfitPrimary: Color(0xFF1B7A3D),
      outfitAccent: Color(0xFFFFFFFF),
      unlockCost: 2000,
      magnetRadiusBonus: 0.35,
    ),
    CharacterData(
      id: 'dancer',
      name: 'Priya',
      description: 'Classical dancer, anklets jingling, chasing the stage before the curtain rises.',
      bodyType: BodyType.dancer,
      skinColor: Color(0xFFCB8F5E),
      outfitPrimary: Color(0xFFC22B5C),
      outfitAccent: Color(0xFFF6C453),
      unlockCost: 3000,
      gatiRegenBonus: 0.2,
      magnetRadiusBonus: 0.2,
    ),
  ];

  static CharacterData byId(String id) => all.firstWhere((c) => c.id == id, orElse: () => all.first);
}
