using System.Collections.Generic;
using UnityEngine;
using Gati.Data;
using Gati.Player;

namespace Gati.Gameplay
{
    /// <summary>
    /// Spawns obstacle/collectible waves ahead of the player along Z and
    /// recycles them once passed. Obstacle avoidance is purely physical
    /// (see Obstacle.cs) — this class only decides which lanes are blocked,
    /// with which kind, and always leaves at least one lane open.
    /// </summary>
    public class ObstacleSpawner : MonoBehaviour
    {
        public PlayerController controller;

        [Header("Pacing (meters)")]
        public float baseSpacing = 16f;
        public float minSpacing = 9f;
        public float difficultyDistance = 9000f;
        public float despawnBehind = 20f;

        readonly List<GameObject> _active = new List<GameObject>();
        readonly Dictionary<string, Material> _materialCache = new Dictionary<string, Material>();
        float _nextWaveZ = 12f;
        float _nextPowerUpZ = 160f;

        void Update()
        {
            if (controller == null) return;
            float playerZ = controller.transform.position.z;
            float lookahead = playerZ + baseSpacing * 3f;

            while (_nextWaveZ < lookahead)
            {
                SpawnWave(_nextWaveZ);
                float t = Mathf.Clamp01(_nextWaveZ / difficultyDistance);
                _nextWaveZ += Mathf.Lerp(baseSpacing, minSpacing, t);
            }

            if (_nextPowerUpZ < lookahead)
            {
                SpawnPowerUp(_nextPowerUpZ);
                _nextPowerUpZ += Random.Range(140f, 220f);
            }

            for (int i = _active.Count - 1; i >= 0; i--)
            {
                var go = _active[i];
                if (go == null) { _active.RemoveAt(i); continue; }
                if (go.transform.position.z < playerZ - despawnBehind)
                {
                    Destroy(go);
                    _active.RemoveAt(i);
                }
            }
        }

        void SpawnWave(float z)
        {
            int laneCount = controller.laneCount;
            var blocked = new HashSet<int>();
            int obstacleLanes = 1 + Random.Range(0, laneCount - 1); // leave >=1 lane open
            var lanes = new List<int>();
            for (int i = 0; i < laneCount; i++) lanes.Add(i);
            Shuffle(lanes);
            for (int i = 0; i < obstacleLanes; i++) blocked.Add(lanes[i]);

            var region = Regions.ForDistance(z);
            var accentMat = GetMaterial($"obs_{region.Id}", region.AccentColor);

            foreach (var lane in blocked)
            {
                var kind = Random.value < 0.4f ? ObstacleKind.Low : Random.value < 0.5f ? ObstacleKind.High : ObstacleKind.Full;
                SpawnObstacle(controller.LaneX(lane), z, kind, accentMat);
            }

            var open = lanes.FindAll(l => !blocked.Contains(l));
            if (open.Count > 0 && Random.value < 0.8f)
            {
                int lane = open[Random.Range(0, open.Count)];
                for (int i = 0; i < 3; i++)
                {
                    SpawnCollectible(controller.LaneX(lane), z + i * 1.4f, region);
                }
            }
        }

        void SpawnObstacle(float x, float z, ObstacleKind kind, Material mat)
        {
            Vector3 size; float y;
            switch (kind)
            {
                case ObstacleKind.Low: size = new Vector3(1.6f, 0.9f, 0.6f); y = 0.45f; break;
                case ObstacleKind.High: size = new Vector3(1.6f, 1.0f, 0.4f); y = 1.5f; break;
                default: size = new Vector3(1.6f, 2.0f, 0.6f); y = 1.0f; break;
            }

            var go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            go.name = $"Obstacle_{kind}";
            go.transform.position = new Vector3(x, y, z);
            go.transform.localScale = size;
            go.GetComponent<Renderer>().sharedMaterial = mat;

            var col = go.GetComponent<BoxCollider>();
            col.isTrigger = true;

            var obstacle = go.AddComponent<Obstacle>();
            obstacle.kind = kind;

            _active.Add(go);
        }

        void SpawnCollectible(float x, float z, RegionData region)
        {
            var mat = GetMaterial($"spark_{region.Id}", region.AccentColor);
            var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            go.name = "Spark";
            go.transform.position = new Vector3(x, 1.0f, z);
            go.transform.localScale = Vector3.one * 0.32f;
            go.GetComponent<Renderer>().sharedMaterial = mat;
            go.GetComponent<SphereCollider>().isTrigger = true;
            go.AddComponent<Collectible>();
            _active.Add(go);
        }

        void SpawnPowerUp(float z)
        {
            int lane = Random.Range(0, controller.laneCount);
            var mat = GetMaterial("powerup", new Color(1f, 0.84f, 0.2f));
            var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            go.name = "PowerUp";
            go.transform.position = new Vector3(controller.LaneX(lane), 1.1f, z);
            go.transform.localScale = Vector3.one * 0.55f;
            go.GetComponent<Renderer>().sharedMaterial = mat;
            go.GetComponent<SphereCollider>().isTrigger = true;
            var c = go.AddComponent<Collectible>();
            c.isPowerUp = true;
            _active.Add(go);
        }

        Material GetMaterial(string key, Color color)
        {
            if (_materialCache.TryGetValue(key, out var mat)) return mat;
            Shader shader = Shader.Find("Universal Render Pipeline/Lit")
                             ?? Shader.Find("Standard")
                             ?? Shader.Find("Sprites/Default");
            mat = new Material(shader) { color = color };
            _materialCache[key] = mat;
            return mat;
        }

        static void Shuffle(List<int> list)
        {
            for (int i = list.Count - 1; i > 0; i--)
            {
                int j = Random.Range(0, i + 1);
                (list[i], list[j]) = (list[j], list[i]);
            }
        }
    }
}
