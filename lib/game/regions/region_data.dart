import 'package:flutter/material.dart';

/// Which silhouette set the background painter should draw for a region.
enum Landmark {
  mumbaiSkyline,
  goaBeach,
  keralaBackwaters,
  bengaluruTech,
  chennaiTemple,
  hyderabadCharminar,
  jaipurFort,
  delhiGate,
  varanasiGhats,
  northeastHills,
  kashmirValley,
  ladakhPeaks,
}

class RegionData {
  final String id;
  final String name;
  final String tagline;
  final Landmark landmark;

  /// Sky gradient, top to bottom.
  final Color skyTop;
  final Color skyBottom;

  /// Silhouette / midground colors, back to front (parallax layers).
  final List<Color> layerColors;

  final Color groundColor;
  final Color accentColor;

  /// Flavor names used for obstacle labels / collectible names — keeps
  /// every region mechanically identical but thematically distinct.
  final List<String> obstacleFlavors;
  final String collectibleName;
  final String powerUpVehicle;
  final String chaseFlavor;

  /// Cumulative distance (meters) at which this region begins.
  final double unlockDistance;

  const RegionData({
    required this.id,
    required this.name,
    required this.tagline,
    required this.landmark,
    required this.skyTop,
    required this.skyBottom,
    required this.layerColors,
    required this.groundColor,
    required this.accentColor,
    required this.obstacleFlavors,
    required this.collectibleName,
    required this.powerUpVehicle,
    required this.chaseFlavor,
    required this.unlockDistance,
  });
}

/// The journey: west coast -> south -> deccan -> north -> Himalaya finale.
class Regions {
  static const List<RegionData> all = [
    RegionData(
      id: 'mumbai',
      name: 'Mumbai',
      tagline: 'Catch the local before it leaves without you',
      landmark: Landmark.mumbaiSkyline,
      skyTop: Color(0xFF3B5670),
      skyBottom: Color(0xFFE8A97D),
      layerColors: [Color(0xFF24384A), Color(0xFF35506A), Color(0xFF4A6B88)],
      groundColor: Color(0xFF2E2E33),
      accentColor: Color(0xFFFFC857),
      obstacleFlavors: ['Local train barrier', 'Auto-rickshaw', 'Vada pav cart', 'Monsoon puddle'],
      collectibleName: 'Vada Pav',
      powerUpVehicle: 'Auto-rickshaw Dash',
      chaseFlavor: 'the last local pulling out of the platform',
      unlockDistance: 0,
    ),
    RegionData(
      id: 'goa',
      name: 'Goa',
      tagline: 'Sun, sand and a scooter with no brakes',
      landmark: Landmark.goaBeach,
      skyTop: Color(0xFF4FA6D8),
      skyBottom: Color(0xFFFFE29A),
      layerColors: [Color(0xFF1E6E8C), Color(0xFF2E93AE), Color(0xFFF2C879)],
      groundColor: Color(0xFFE8C48A),
      accentColor: Color(0xFFFF6F59),
      obstacleFlavors: ['Beach shack', 'Sun lounger', 'Parked scooter', 'Coconut stand'],
      collectibleName: 'Cashew Feni Shell',
      powerUpVehicle: 'Scooter Sprint',
      chaseFlavor: 'the incoming high tide',
      unlockDistance: 900,
    ),
    RegionData(
      id: 'kerala',
      name: 'Kerala',
      tagline: 'Backwaters, houseboats and a thousand palms',
      landmark: Landmark.keralaBackwaters,
      skyTop: Color(0xFF5FA88C),
      skyBottom: Color(0xFFDCEFC7),
      layerColors: [Color(0xFF1F5C4A), Color(0xFF2E7D5F), Color(0xFF4FA37B)],
      groundColor: Color(0xFF3B6B4F),
      accentColor: Color(0xFFE8B93E),
      obstacleFlavors: ['Houseboat mast', 'Coconut tree fall', 'Fishing net', 'Canal gate'],
      collectibleName: 'Banana Leaf Coin',
      powerUpVehicle: 'Shikara Glide',
      chaseFlavor: 'the rising backwater current',
      unlockDistance: 1800,
    ),
    RegionData(
      id: 'bengaluru',
      name: 'Bengaluru',
      tagline: 'Namma metro, endless traffic, and deadlines',
      landmark: Landmark.bengaluruTech,
      skyTop: Color(0xFF6B7A99),
      skyBottom: Color(0xFFC9D3E0),
      layerColors: [Color(0xFF2B3350), Color(0xFF3D4A72), Color(0xFF576E9E)],
      groundColor: Color(0xFF33363D),
      accentColor: Color(0xFF3ED6B5),
      obstacleFlavors: ['Traffic barricade', 'Food delivery bike', 'Glass tower scaffold', 'Metro pillar'],
      collectibleName: 'Filter Coffee Token',
      powerUpVehicle: 'Metro Dash',
      chaseFlavor: 'a gridlock wave swallowing the road behind you',
      unlockDistance: 2700,
    ),
    RegionData(
      id: 'chennai',
      name: 'Chennai',
      tagline: 'Marina winds and temple gopurams',
      landmark: Landmark.chennaiTemple,
      skyTop: Color(0xFF3E7CA6),
      skyBottom: Color(0xFFF7DCA0),
      layerColors: [Color(0xFF224C63), Color(0xFF2F6B87), Color(0xFF6FA8C4)],
      groundColor: Color(0xFFD8C79A),
      accentColor: Color(0xFFE0533D),
      obstacleFlavors: ['Temple cart', 'Beach kite string', 'Bus stop queue', 'Fishing boat'],
      collectibleName: 'Filter Kaapi Tumbler',
      powerUpVehicle: 'Cycle-rickshaw Rush',
      chaseFlavor: 'a cyclone gust rolling off the Marina',
      unlockDistance: 3600,
    ),
    RegionData(
      id: 'hyderabad',
      name: 'Hyderabad',
      tagline: 'Bazaars, biryani steam and Irani chai',
      landmark: Landmark.hyderabadCharminar,
      skyTop: Color(0xFFB0568F),
      skyBottom: Color(0xFFF3B562),
      layerColors: [Color(0xFF5B2A4C), Color(0xFF7C3B63), Color(0xFFAE5D82)],
      groundColor: Color(0xFF4A3A2E),
      accentColor: Color(0xFFF6C453),
      obstacleFlavors: ['Bazaar stall', 'Biryani handi cart', 'Pearl shop crate', 'Metro pillar'],
      collectibleName: 'Osmania Biscuit',
      powerUpVehicle: 'Metro Dash',
      chaseFlavor: 'the bazaar crowd closing in behind you',
      unlockDistance: 4500,
    ),
    RegionData(
      id: 'jaipur',
      name: 'Jaipur',
      tagline: 'Forts, camels and a rising dust storm',
      landmark: Landmark.jaipurFort,
      skyTop: Color(0xFFD98A4A),
      skyBottom: Color(0xFFF6D9A0),
      layerColors: [Color(0xFF7A4A2D), Color(0xFFA5643A), Color(0xFFD08B4F)],
      groundColor: Color(0xFFC98F4E),
      accentColor: Color(0xFFE8546B),
      obstacleFlavors: ['Camel cart', 'Market stall', 'Fort gate barrier', 'Puppet stand'],
      collectibleName: 'Lac Bangle',
      powerUpVehicle: 'Camel Dash',
      chaseFlavor: 'a wall of desert dust (the loo)',
      unlockDistance: 5400,
    ),
    RegionData(
      id: 'delhi',
      name: 'Delhi',
      tagline: 'Metro lines, India Gate and Chandni Chowk lanes',
      landmark: Landmark.delhiGate,
      skyTop: Color(0xFF7A8AA6),
      skyBottom: Color(0xFFE7D9C4),
      layerColors: [Color(0xFF3A4257), Color(0xFF52607F), Color(0xFF8593AC)],
      groundColor: Color(0xFF474747),
      accentColor: Color(0xFFDA6A2E),
      obstacleFlavors: ['Metro barrier', 'Street food cart', 'Cycle rickshaw', 'Wedding baraat'],
      collectibleName: 'Parantha Token',
      powerUpVehicle: 'Metro Dash',
      chaseFlavor: 'rush-hour traffic surging behind you',
      unlockDistance: 6300,
    ),
    RegionData(
      id: 'varanasi',
      name: 'Varanasi',
      tagline: 'Ghats, narrow lanes and the evening aarti',
      landmark: Landmark.varanasiGhats,
      skyTop: Color(0xFFB6784F),
      skyBottom: Color(0xFFF4D9A6),
      layerColors: [Color(0xFF5C3A2E), Color(0xFF7C4F3B), Color(0xFFA9744F)],
      groundColor: Color(0xFF8C7259),
      accentColor: Color(0xFFFF9E3D),
      obstacleFlavors: ['Ghat steps', 'Boat mooring rope', 'Diya seller', 'Narrow lane cow'],
      collectibleName: 'Brass Diya',
      powerUpVehicle: 'Boat Glide',
      chaseFlavor: 'the Ganga aarti flame wave',
      unlockDistance: 7200,
    ),
    RegionData(
      id: 'northeast',
      name: 'Northeast India',
      tagline: 'Living root bridges, tea gardens and misty hills',
      landmark: Landmark.northeastHills,
      skyTop: Color(0xFF4E7A6B),
      skyBottom: Color(0xFFBFDCC8),
      layerColors: [Color(0xFF264439), Color(0xFF356554), Color(0xFF4E8B72)],
      groundColor: Color(0xFF3D5C46),
      accentColor: Color(0xFF9FD8C0),
      obstacleFlavors: ['Root bridge gap', 'Tea garden basket', 'Bamboo scaffold', 'River crossing'],
      collectibleName: 'Tea Leaf Basket',
      powerUpVehicle: 'Cable Crossing',
      chaseFlavor: 'monsoon mist rolling down the valley',
      unlockDistance: 8100,
    ),
    RegionData(
      id: 'kashmir',
      name: 'Kashmir',
      tagline: 'Snow, mountains and a shikara on the lake',
      landmark: Landmark.kashmirValley,
      skyTop: Color(0xFF8FB6D9),
      skyBottom: Color(0xFFEAF3FA),
      layerColors: [Color(0xFF4B6D8C), Color(0xFF6E93B4), Color(0xFFAFCBE0)],
      groundColor: Color(0xFFEFF4F8),
      accentColor: Color(0xFFE0553F),
      obstacleFlavors: ['Snow drift', 'Houseboat plank', 'Shikara oar', 'Chinar branch'],
      collectibleName: 'Kahwa Cup',
      powerUpVehicle: 'Shikara Glide',
      chaseFlavor: 'an avalanche rumbling down the slope',
      unlockDistance: 9000,
    ),
    RegionData(
      id: 'ladakh',
      name: 'Ladakh',
      tagline: 'The roof of the journey — high passes and prayer flags',
      landmark: Landmark.ladakhPeaks,
      skyTop: Color(0xFF1E3A5F),
      skyBottom: Color(0xFF8FB8D6),
      layerColors: [Color(0xFF2C3E52), Color(0xFF3F5871), Color(0xFF6C8AA3)],
      groundColor: Color(0xFFB79E7E),
      accentColor: Color(0xFFE84C3D),
      obstacleFlavors: ['Prayer flag pole', 'Mountain boulder', 'Frozen stream', 'Monastery step'],
      collectibleName: 'Prayer Flag',
      powerUpVehicle: 'Yak Dash',
      chaseFlavor: 'a mountain blizzard closing the pass',
      unlockDistance: 9900,
    ),
  ];

  static RegionData forDistance(double meters) {
    RegionData current = all.first;
    for (final r in all) {
      if (meters >= r.unlockDistance) current = r;
    }
    return current;
  }

  static int indexForDistance(double meters) {
    int idx = 0;
    for (int i = 0; i < all.length; i++) {
      if (meters >= all[i].unlockDistance) idx = i;
    }
    return idx;
  }
}
