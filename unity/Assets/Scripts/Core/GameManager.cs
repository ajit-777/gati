using System;
using UnityEngine;
using Gati.Data;
using Gati.Player;

namespace Gati.Core
{
    /// <summary>
    /// Drives the run: moves the player forward along Z (distance in meters
    /// == Z position, matching RegionData.UnlockDistance), advances the
    /// Gati meter and speed, and fires region-change/game-over events for
    /// the HUD to pick up. A singleton so Obstacle/Collectible triggers can
    /// report back without needing a scene reference wired in the Inspector.
    /// </summary>
    public class GameManager : MonoBehaviour
    {
        public static GameManager Instance { get; private set; }

        public PlayerController controller;

        public CharacterData character;
        public float distance;
        public float baseSpeed = 6f;
        public float speed;
        public float gati = 100f;
        public int hearts = 3;
        public int sparks;
        public RegionData currentRegion;
        public bool isGameOver;

        float _speedBoostTimer;

        public event Action<RegionData> OnRegionChanged;
        public event Action OnGameOver;
        public event Action OnHudChanged;

        void Awake()
        {
            Instance = this;
            character = CharacterCatalog.ById(SaveSystem.SelectedCharacterId);
            currentRegion = Regions.All[0];
        }

        void Update()
        {
            if (isGameOver || controller == null) return;

            distance += speed * Time.deltaTime;
            gati = Mathf.Clamp(gati + (4.5f + character.GatiRegenBonus * 10f) * Time.deltaTime, 0f, 100f);

            baseSpeed = 6f + Mathf.Min(distance, 12000f) * 0.0007f;
            speed = _speedBoostTimer > 0f ? baseSpeed * 1.6f : baseSpeed;
            if (_speedBoostTimer > 0f) _speedBoostTimer -= Time.deltaTime;

            var p = controller.transform.position;
            p.z += speed * Time.deltaTime;
            controller.transform.position = p;

            var region = Regions.ForDistance(distance);
            if (region.Id != currentRegion.Id)
            {
                currentRegion = region;
                OnRegionChanged?.Invoke(region);
            }

            OnHudChanged?.Invoke();

            if (gati <= 0f || hearts <= 0) EndRun();
        }

        public void OnObstacleHit()
        {
            hearts -= 1;
            gati = Mathf.Clamp(gati - 28f, 0f, 100f);
        }

        public void OnSparkCollected()
        {
            sparks += 1;
            gati = Mathf.Clamp(gati + 8f, 0f, 100f);
        }

        public void OnPowerUpCollected()
        {
            sparks += 5;
            _speedBoostTimer = 3.5f;
        }

        void EndRun()
        {
            if (isGameOver) return;
            isGameOver = true;
            SaveSystem.SetBestDistanceIfHigher(distance);
            SaveSystem.AddSparks(sparks);
            OnGameOver?.Invoke();
        }
    }
}
