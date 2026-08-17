using System.Collections.Generic;
using UnityEngine;

namespace Gati.Data
{
    /// <summary>
    /// One stop on the journey across India. Plain data — no MonoBehaviour —
    /// so it can be used from gameplay code, terrain generation and UI alike.
    /// </summary>
    public class RegionData
    {
        public string Id;
        public string DisplayName;
        public string Tagline;
        public PropKind Landmark;

        public Color SkyTop;
        public Color SkyBottom;
        public Color GroundColor;
        public Color AccentColor;
        public bool SnowGround;

        public string[] ObstacleFlavors;
        public string CollectibleName;
        public string PowerUpVehicle;
        public string ChaseFlavor;

        /// Cumulative distance (meters) at which this region begins.
        public float UnlockDistance;
    }

    /// <summary>
    /// The journey, west coast -> south -> deccan -> north -> Himalaya finale.
    /// Mirrors lib/game/regions/region_data.dart from the original Flutter
    /// prototype so the two versions stay conceptually in sync.
    /// </summary>
    public static class Regions
    {
        public static readonly List<RegionData> All = new List<RegionData>
        {
            new RegionData
            {
                Id = "mumbai", DisplayName = "Mumbai",
                Tagline = "Catch the local before it leaves without you",
                Landmark = PropKind.MumbaiSkyline,
                SkyTop = new Color32(0x3B, 0x56, 0x70, 255), SkyBottom = new Color32(0xE8, 0xA9, 0x7D, 255),
                GroundColor = new Color32(0x2E, 0x2E, 0x33, 255), AccentColor = new Color32(0xFF, 0xC8, 0x57, 255),
                ObstacleFlavors = new[] { "Local train barrier", "Auto-rickshaw", "Vada pav cart", "Monsoon puddle" },
                CollectibleName = "Vada Pav", PowerUpVehicle = "Auto-rickshaw Dash",
                ChaseFlavor = "the last local pulling out of the platform", UnlockDistance = 0,
            },
            new RegionData
            {
                Id = "goa", DisplayName = "Goa",
                Tagline = "Sun, sand and a scooter with no brakes",
                Landmark = PropKind.GoaPalms,
                SkyTop = new Color32(0x4F, 0xA6, 0xD8, 255), SkyBottom = new Color32(0xFF, 0xE2, 0x9A, 255),
                GroundColor = new Color32(0xE8, 0xC4, 0x8A, 255), AccentColor = new Color32(0xFF, 0x6F, 0x59, 255),
                ObstacleFlavors = new[] { "Beach shack", "Sun lounger", "Parked scooter", "Coconut stand" },
                CollectibleName = "Cashew Feni Shell", PowerUpVehicle = "Scooter Sprint",
                ChaseFlavor = "the incoming high tide", UnlockDistance = 900,
            },
            new RegionData
            {
                Id = "kerala", DisplayName = "Kerala",
                Tagline = "Backwaters, houseboats and a thousand palms",
                Landmark = PropKind.KeralaBackwaters,
                SkyTop = new Color32(0x5F, 0xA8, 0x8C, 255), SkyBottom = new Color32(0xDC, 0xEF, 0xC7, 255),
                GroundColor = new Color32(0x3B, 0x6B, 0x4F, 255), AccentColor = new Color32(0xE8, 0xB9, 0x3E, 255),
                ObstacleFlavors = new[] { "Houseboat mast", "Coconut tree fall", "Fishing net", "Canal gate" },
                CollectibleName = "Banana Leaf Coin", PowerUpVehicle = "Shikara Glide",
                ChaseFlavor = "the rising backwater current", UnlockDistance = 1800,
            },
            new RegionData
            {
                Id = "bengaluru", DisplayName = "Bengaluru",
                Tagline = "Namma metro, endless traffic, and deadlines",
                Landmark = PropKind.BengaluruTech,
                SkyTop = new Color32(0x6B, 0x7A, 0x99, 255), SkyBottom = new Color32(0xC9, 0xD3, 0xE0, 255),
                GroundColor = new Color32(0x33, 0x36, 0x3D, 255), AccentColor = new Color32(0x3E, 0xD6, 0xB5, 255),
                ObstacleFlavors = new[] { "Traffic barricade", "Food delivery bike", "Glass tower scaffold", "Metro pillar" },
                CollectibleName = "Filter Coffee Token", PowerUpVehicle = "Metro Dash",
                ChaseFlavor = "a gridlock wave swallowing the road behind you", UnlockDistance = 2700,
            },
            new RegionData
            {
                Id = "chennai", DisplayName = "Chennai",
                Tagline = "Marina winds and temple gopurams",
                Landmark = PropKind.ChennaiTemple,
                SkyTop = new Color32(0x3E, 0x7C, 0xA6, 255), SkyBottom = new Color32(0xF7, 0xDC, 0xA0, 255),
                GroundColor = new Color32(0xD8, 0xC7, 0x9A, 255), AccentColor = new Color32(0xE0, 0x53, 0x3D, 255),
                ObstacleFlavors = new[] { "Temple cart", "Beach kite string", "Bus stop queue", "Fishing boat" },
                CollectibleName = "Filter Kaapi Tumbler", PowerUpVehicle = "Cycle-rickshaw Rush",
                ChaseFlavor = "a cyclone gust rolling off the Marina", UnlockDistance = 3600,
            },
            new RegionData
            {
                Id = "hyderabad", DisplayName = "Hyderabad",
                Tagline = "Bazaars, biryani steam and Irani chai",
                Landmark = PropKind.HyderabadCharminar,
                SkyTop = new Color32(0xB0, 0x56, 0x8F, 255), SkyBottom = new Color32(0xF3, 0xB5, 0x62, 255),
                GroundColor = new Color32(0x4A, 0x3A, 0x2E, 255), AccentColor = new Color32(0xF6, 0xC4, 0x53, 255),
                ObstacleFlavors = new[] { "Bazaar stall", "Biryani handi cart", "Pearl shop crate", "Metro pillar" },
                CollectibleName = "Osmania Biscuit", PowerUpVehicle = "Metro Dash",
                ChaseFlavor = "the bazaar crowd closing in behind you", UnlockDistance = 4500,
            },
            new RegionData
            {
                Id = "jaipur", DisplayName = "Jaipur",
                Tagline = "Forts, camels and a rising dust storm",
                Landmark = PropKind.JaipurFort,
                SkyTop = new Color32(0xD9, 0x8A, 0x4A, 255), SkyBottom = new Color32(0xF6, 0xD9, 0xA0, 255),
                GroundColor = new Color32(0xC9, 0x8F, 0x4E, 255), AccentColor = new Color32(0xE8, 0x54, 0x6B, 255),
                ObstacleFlavors = new[] { "Camel cart", "Market stall", "Fort gate barrier", "Puppet stand" },
                CollectibleName = "Lac Bangle", PowerUpVehicle = "Camel Dash",
                ChaseFlavor = "a wall of desert dust (the loo)", UnlockDistance = 5400,
            },
            new RegionData
            {
                Id = "delhi", DisplayName = "Delhi",
                Tagline = "Metro lines, India Gate and Chandni Chowk lanes",
                Landmark = PropKind.DelhiGate,
                SkyTop = new Color32(0x7A, 0x8A, 0xA6, 255), SkyBottom = new Color32(0xE7, 0xD9, 0xC4, 255),
                GroundColor = new Color32(0x47, 0x47, 0x47, 255), AccentColor = new Color32(0xDA, 0x6A, 0x2E, 255),
                ObstacleFlavors = new[] { "Metro barrier", "Street food cart", "Cycle rickshaw", "Wedding baraat" },
                CollectibleName = "Parantha Token", PowerUpVehicle = "Metro Dash",
                ChaseFlavor = "rush-hour traffic surging behind you", UnlockDistance = 6300,
            },
            new RegionData
            {
                Id = "varanasi", DisplayName = "Varanasi",
                Tagline = "Ghats, narrow lanes and the evening aarti",
                Landmark = PropKind.VaranasiGhats,
                SkyTop = new Color32(0xB6, 0x78, 0x4F, 255), SkyBottom = new Color32(0xF4, 0xD9, 0xA6, 255),
                GroundColor = new Color32(0x8C, 0x72, 0x59, 255), AccentColor = new Color32(0xFF, 0x9E, 0x3D, 255),
                ObstacleFlavors = new[] { "Ghat steps", "Boat mooring rope", "Diya seller", "Narrow lane cow" },
                CollectibleName = "Brass Diya", PowerUpVehicle = "Boat Glide",
                ChaseFlavor = "the Ganga aarti flame wave", UnlockDistance = 7200,
            },
            new RegionData
            {
                Id = "northeast", DisplayName = "Northeast India",
                Tagline = "Living root bridges, tea gardens and misty hills",
                Landmark = PropKind.NortheastHills,
                SkyTop = new Color32(0x4E, 0x7A, 0x6B, 255), SkyBottom = new Color32(0xBF, 0xDC, 0xC8, 255),
                GroundColor = new Color32(0x3D, 0x5C, 0x46, 255), AccentColor = new Color32(0x9F, 0xD8, 0xC0, 255),
                ObstacleFlavors = new[] { "Root bridge gap", "Tea garden basket", "Bamboo scaffold", "River crossing" },
                CollectibleName = "Tea Leaf Basket", PowerUpVehicle = "Cable Crossing",
                ChaseFlavor = "monsoon mist rolling down the valley", UnlockDistance = 8100,
            },
            new RegionData
            {
                Id = "kashmir", DisplayName = "Kashmir",
                Tagline = "Snow, mountains and a shikara on the lake",
                Landmark = PropKind.KashmirValley,
                SkyTop = new Color32(0x8F, 0xB6, 0xD9, 255), SkyBottom = new Color32(0xEA, 0xF3, 0xFA, 255),
                GroundColor = new Color32(0xEF, 0xF4, 0xF8, 255), AccentColor = new Color32(0xE0, 0x55, 0x3F, 255),
                SnowGround = true,
                ObstacleFlavors = new[] { "Snow drift", "Houseboat plank", "Shikara oar", "Chinar branch" },
                CollectibleName = "Kahwa Cup", PowerUpVehicle = "Shikara Glide",
                ChaseFlavor = "an avalanche rumbling down the slope", UnlockDistance = 9000,
            },
            new RegionData
            {
                Id = "ladakh", DisplayName = "Ladakh",
                Tagline = "The roof of the journey — high passes and prayer flags",
                Landmark = PropKind.LadakhPeaks,
                SkyTop = new Color32(0x1E, 0x3A, 0x5F, 255), SkyBottom = new Color32(0x8F, 0xB8, 0xD6, 255),
                GroundColor = new Color32(0xB7, 0x9E, 0x7E, 255), AccentColor = new Color32(0xE8, 0x4C, 0x3D, 255),
                SnowGround = true,
                ObstacleFlavors = new[] { "Prayer flag pole", "Mountain boulder", "Frozen stream", "Monastery step" },
                CollectibleName = "Prayer Flag", PowerUpVehicle = "Yak Dash",
                ChaseFlavor = "a mountain blizzard closing the pass", UnlockDistance = 9900,
            },
        };

        public static RegionData ForDistance(float meters)
        {
            RegionData current = All[0];
            foreach (var r in All)
            {
                if (meters >= r.UnlockDistance) current = r;
            }
            return current;
        }
    }
}
