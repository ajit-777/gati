using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Gati.Core
{
    /// <summary>Thin wrapper around PlayerPrefs for persistent game state.</summary>
    public static class SaveSystem
    {
        const string KeyBestDistance = "gati.best_distance";
        const string KeyTotalSparks = "gati.total_sparks";
        const string KeyUnlocked = "gati.unlocked_characters";
        const string KeySelected = "gati.selected_character";

        public static float BestDistance => PlayerPrefs.GetFloat(KeyBestDistance, 0f);

        public static void SetBestDistanceIfHigher(float meters)
        {
            if (meters > BestDistance)
            {
                PlayerPrefs.SetFloat(KeyBestDistance, meters);
                PlayerPrefs.Save();
            }
        }

        public static int TotalSparks => PlayerPrefs.GetInt(KeyTotalSparks, 0);

        public static void AddSparks(int amount)
        {
            PlayerPrefs.SetInt(KeyTotalSparks, TotalSparks + amount);
            PlayerPrefs.Save();
        }

        public static bool SpendSparks(int amount)
        {
            if (TotalSparks < amount) return false;
            PlayerPrefs.SetInt(KeyTotalSparks, TotalSparks - amount);
            PlayerPrefs.Save();
            return true;
        }

        public static List<string> UnlockedCharacterIds
        {
            get
            {
                var raw = PlayerPrefs.GetString(KeyUnlocked, "school_kid");
                return raw.Split(',').Where(s => s.Length > 0).ToList();
            }
        }

        public static void UnlockCharacter(string id)
        {
            var set = new HashSet<string>(UnlockedCharacterIds) { id };
            PlayerPrefs.SetString(KeyUnlocked, string.Join(",", set));
            PlayerPrefs.Save();
        }

        public static string SelectedCharacterId => PlayerPrefs.GetString(KeySelected, "school_kid");

        public static void SelectCharacter(string id)
        {
            PlayerPrefs.SetString(KeySelected, id);
            PlayerPrefs.Save();
        }
    }
}
