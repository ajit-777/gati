using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Gati.Data
{
    public enum BodyType { SchoolKid, CollegeStudent, DeliveryRider, CricketPlayer, Dancer }

    public class CharacterData
    {
        public string Id;
        public string DisplayName;
        public string Description;
        public BodyType BodyType;
        public Color SkinColor;
        public Color OutfitPrimary;
        public Color OutfitAccent;

        /// Sparks (coins) needed to unlock. 0 = unlocked from the start.
        public int UnlockCost;

        public float MagnetRadiusBonus;
        public float GatiRegenBonus;
    }

    public static class CharacterCatalog
    {
        public static readonly List<CharacterData> All = new List<CharacterData>
        {
            new CharacterData
            {
                Id = "school_kid", DisplayName = "Aarav",
                Description = "School kid racing to beat the first bell. Quick on his feet.",
                BodyType = BodyType.SchoolKid,
                SkinColor = new Color32(0xC9, 0x8A, 0x5A, 255),
                OutfitPrimary = new Color32(0x2C, 0x4E, 0x8A, 255),
                OutfitAccent = new Color32(0xE8, 0xE8, 0xE8, 255),
                UnlockCost = 0, GatiRegenBonus = 0.15f,
            },
            new CharacterData
            {
                Id = "college_student", DisplayName = "Meera",
                Description = "College student with a tote bag full of notes and a bus to catch.",
                BodyType = BodyType.CollegeStudent,
                SkinColor = new Color32(0xA9, 0x70, 0x4A, 255),
                OutfitPrimary = new Color32(0x6B, 0x3F, 0xA0, 255),
                OutfitAccent = new Color32(0xFF, 0xD1, 0x66, 255),
                UnlockCost = 500, MagnetRadiusBonus = 0.2f,
            },
            new CharacterData
            {
                Id = "delivery_rider", DisplayName = "Imran",
                Description = "Delivery rider, orange box on his back, ten minutes on the clock.",
                BodyType = BodyType.DeliveryRider,
                SkinColor = new Color32(0x8A, 0x5A, 0x3B, 255),
                OutfitPrimary = new Color32(0xE8, 0x62, 0x2D, 255),
                OutfitAccent = new Color32(0x1A, 0x1A, 0x1A, 255),
                UnlockCost = 1200, GatiRegenBonus = 0.25f,
            },
            new CharacterData
            {
                Id = "cricket_player", DisplayName = "Rohan",
                Description = "Gully cricket star, bat slung over his shoulder, always sprinting a quick single.",
                BodyType = BodyType.CricketPlayer,
                SkinColor = new Color32(0xB5, 0x7A, 0x4E, 255),
                OutfitPrimary = new Color32(0x1B, 0x7A, 0x3D, 255),
                OutfitAccent = new Color32(0xFF, 0xFF, 0xFF, 255),
                UnlockCost = 2000, MagnetRadiusBonus = 0.35f,
            },
            new CharacterData
            {
                Id = "dancer", DisplayName = "Priya",
                Description = "Classical dancer, anklets jingling, chasing the stage before the curtain rises.",
                BodyType = BodyType.Dancer,
                SkinColor = new Color32(0xCB, 0x8F, 0x5E, 255),
                OutfitPrimary = new Color32(0xC2, 0x2B, 0x5C, 255),
                OutfitAccent = new Color32(0xF6, 0xC4, 0x53, 255),
                UnlockCost = 3000, GatiRegenBonus = 0.2f, MagnetRadiusBonus = 0.2f,
            },
        };

        public static CharacterData ById(string id) =>
            All.FirstOrDefault(c => c.Id == id) ?? All[0];
    }
}
