using System.Collections.Generic;
using UnityEngine;
using Gati.Data;

namespace Gati.World
{
    /// <summary>
    /// Streams 20m ground chunks ahead of the player and recycles them
    /// behind, each built from primitives (planes/cubes/cylinders/cones)
    /// and colored/shaped from the current <see cref="RegionData"/> — real
    /// 3D geometry the player runs through, no imported meshes required.
    /// </summary>
    public class TerrainStreamer : MonoBehaviour
    {
        public Transform player;
        public float chunkLength = 20f;
        public float roadWidth = 7.5f;
        public int lookaheadChunks = 4;
        public int trailingChunks = 2;

        readonly List<GameObject> _chunks = new List<GameObject>();
        readonly Dictionary<string, Material> _materialCache = new Dictionary<string, Material>();
        float _nextSpawnZ;

        void Start()
        {
            _nextSpawnZ = 0f;
            for (int i = 0; i < lookaheadChunks; i++) SpawnChunk();
        }

        void Update()
        {
            if (player == null) return;
            float playerZ = player.position.z;

            while (_nextSpawnZ < playerZ + chunkLength * lookaheadChunks) SpawnChunk();

            for (int i = _chunks.Count - 1; i >= 0; i--)
            {
                var chunk = _chunks[i];
                if (chunk.transform.position.z + chunkLength < playerZ - chunkLength * trailingChunks)
                {
                    Destroy(chunk);
                    _chunks.RemoveAt(i);
                }
            }
        }

        void SpawnChunk()
        {
            float z = _nextSpawnZ;
            _nextSpawnZ += chunkLength;
            var region = Regions.ForDistance(z);

            var chunk = new GameObject($"Chunk_{region.Id}_{z:0}");
            chunk.transform.position = new Vector3(0, 0, z);
            _chunks.Add(chunk);

            var groundMat = GetMaterial($"ground_{region.Id}", region.SnowGround ? Color.white : region.GroundColor);
            var ground = GameObject.CreatePrimitive(PrimitiveType.Cube);
            ground.name = "Ground";
            ground.transform.SetParent(chunk.transform, false);
            ground.transform.localPosition = new Vector3(0, -0.5f, chunkLength / 2f);
            ground.transform.localScale = new Vector3(roadWidth + 4f, 1f, chunkLength);
            ground.GetComponent<Renderer>().sharedMaterial = groundMat;

            var roadMat = GetMaterial("road", new Color(0.16f, 0.16f, 0.17f));
            var road = GameObject.CreatePrimitive(PrimitiveType.Cube);
            road.name = "Road";
            Destroy(road.GetComponent<Collider>());
            road.transform.SetParent(chunk.transform, false);
            road.transform.localPosition = new Vector3(0, 0.001f, chunkLength / 2f);
            road.transform.localScale = new Vector3(roadWidth, 0.05f, chunkLength);
            road.GetComponent<Renderer>().sharedMaterial = roadMat;

            SpawnProps(chunk.transform, region);
        }

        void SpawnProps(Transform parent, RegionData region)
        {
            var accentMat = GetMaterial($"accent_{region.Id}", region.AccentColor);
            var structMat = GetMaterial($"struct_{region.Id}", region.SnowGround ? new Color(0.85f, 0.87f, 0.9f) : DarkenFor(region));

            for (int side = -1; side <= 1; side += 2)
            {
                float x = side * (roadWidth / 2f + 2.5f + Random.Range(0f, 3f));
                float z = Random.Range(2f, chunkLength - 2f);
                SpawnLandmarkProp(parent, region, new Vector3(x, 0, z), structMat, accentMat);
            }
        }

        void SpawnLandmarkProp(Transform parent, RegionData region, Vector3 localPos, Material structMat, Material accentMat)
        {
            GameObject root = new GameObject("Prop");
            root.transform.SetParent(parent, false);
            root.transform.localPosition = localPos;

            switch (region.Landmark)
            {
                case PropKind.MumbaiSkyline:
                case PropKind.BengaluruTech:
                    float h = Random.Range(4f, 11f);
                    // Windows are parented to `root` (unscaled), not the tower
                    // box itself — a Unity primitive's transform carries its
                    // own scale, so children of a scaled primitive inherit
                    // that scale/shear. Positioning against the unscaled root
                    // avoids that entirely.
                    Box(root.transform, Vector3.up * h / 2f, new Vector3(3f, h, 3f), structMat);
                    for (float y = 1f; y < h - 0.5f; y += 1.4f)
                        Box(root.transform, new Vector3(0, y, 1.51f), new Vector3(2.6f, 0.5f, 0.05f), accentMat);
                    break;
                case PropKind.GoaPalms:
                    Cylinder(root.transform, Vector3.up * 2f, new Vector3(0.25f, 2f, 0.25f), structMat);
                    for (int i = 0; i < 5; i++)
                    {
                        float a = i * 72f;
                        var frond = Box(root.transform, new Vector3(0, 4f, 0), new Vector3(1.6f, 0.08f, 0.3f), accentMat);
                        frond.localRotation = Quaternion.Euler(20f, a, 0);
                    }
                    break;
                case PropKind.KeralaBackwaters:
                    Cylinder(root.transform, Vector3.up * 1.8f, new Vector3(0.15f, 1.8f, 0.15f), structMat);
                    Sphere(root.transform, Vector3.up * 3.4f, Vector3.one * 1.4f, accentMat);
                    break;
                case PropKind.ChennaiTemple:
                    float baseY = 0f;
                    for (int tier = 0; tier < 4; tier++)
                    {
                        float s = 2.6f - tier * 0.5f;
                        var t = Box(root.transform, new Vector3(0, baseY + s / 2f, 0), new Vector3(s, s, s), tier % 2 == 0 ? structMat : accentMat);
                        baseY += s * 0.7f;
                    }
                    break;
                case PropKind.HyderabadCharminar:
                    Box(root.transform, new Vector3(-0.9f, 3f, 0), new Vector3(0.6f, 6f, 0.6f), structMat);
                    Box(root.transform, new Vector3(0.9f, 3f, 0), new Vector3(0.6f, 6f, 0.6f), structMat);
                    Sphere(root.transform, new Vector3(0, 6.2f, 0), new Vector3(2.2f, 1.2f, 2.2f), accentMat);
                    break;
                case PropKind.JaipurFort:
                    Box(root.transform, Vector3.up * 2f, new Vector3(3.5f, 4f, 3f), structMat);
                    for (int i = -1; i <= 1; i++)
                        Cylinder(root.transform, new Vector3(i * 1.5f, 4.3f, 0), new Vector3(0.5f, 0.7f, 0.5f), accentMat);
                    break;
                case PropKind.DelhiGate:
                    Box(root.transform, new Vector3(-1.1f, 3f, 0), new Vector3(0.8f, 6f, 0.8f), structMat);
                    Box(root.transform, new Vector3(1.1f, 3f, 0), new Vector3(0.8f, 6f, 0.8f), structMat);
                    Box(root.transform, new Vector3(0, 6.3f, 0), new Vector3(3.2f, 0.8f, 0.8f), structMat);
                    break;
                case PropKind.VaranasiGhats:
                    for (int s = 0; s < 5; s++)
                        Box(root.transform, new Vector3(0, s * 0.5f + 0.25f, 0), new Vector3(3f - s * 0.2f, 0.5f, 2f), structMat);
                    break;
                case PropKind.NortheastHills:
                    Cone(root.transform, Vector3.up * 3f, new Vector3(3.5f, 3f, 3.5f), structMat);
                    break;
                case PropKind.KashmirValley:
                    Cone(root.transform, Vector3.up * 5f, new Vector3(4f, 5f, 4f), structMat);
                    Cone(root.transform, Vector3.up * 5.9f, new Vector3(2f, 2f, 2f), GetMaterial("snowcap", Color.white));
                    break;
                case PropKind.LadakhPeaks:
                    Cone(root.transform, Vector3.up * 7f, new Vector3(5f, 7f, 5f), structMat);
                    Cone(root.transform, Vector3.up * 7.5f, new Vector3(2.5f, 2.5f, 2.5f), GetMaterial("snowcap", Color.white));
                    break;
            }
        }

        Transform Box(Transform parent, Vector3 localPos, Vector3 scale, Material mat, float worldY = float.NaN)
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            Destroy(go.GetComponent<Collider>());
            go.transform.SetParent(parent, false);
            go.transform.localPosition = localPos;
            go.transform.localScale = scale;
            go.GetComponent<Renderer>().sharedMaterial = mat;
            return go.transform;
        }

        Transform Cylinder(Transform parent, Vector3 localPos, Vector3 scale, Material mat)
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
            Destroy(go.GetComponent<Collider>());
            go.transform.SetParent(parent, false);
            go.transform.localPosition = localPos;
            go.transform.localScale = scale;
            go.GetComponent<Renderer>().sharedMaterial = mat;
            return go.transform;
        }

        Transform Sphere(Transform parent, Vector3 localPos, Vector3 scale, Material mat)
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            Destroy(go.GetComponent<Collider>());
            go.transform.SetParent(parent, false);
            go.transform.localPosition = localPos;
            go.transform.localScale = scale;
            go.GetComponent<Renderer>().sharedMaterial = mat;
            return go.transform;
        }

        Transform Cone(Transform parent, Vector3 localPos, Vector3 scale, Material mat)
        {
            // Unity has no built-in cone primitive; approximate with a
            // squashed, low-subdivision cylinder scaled to a point isn't
            // possible via primitive alone, so use a simple pyramid mesh.
            var go = new GameObject("Cone");
            go.transform.SetParent(parent, false);
            go.transform.localPosition = localPos;
            go.transform.localScale = scale;
            var mf = go.AddComponent<MeshFilter>();
            var mr = go.AddComponent<MeshRenderer>();
            mf.sharedMesh = ConeMeshCache.Get();
            mr.sharedMaterial = mat;
            return go.transform;
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

        static Color DarkenFor(RegionData region) => region.GroundColor * 0.7f;
    }

    /// <summary>Lazily builds and caches a simple 8-sided cone mesh shared by all mountain props.</summary>
    static class ConeMeshCache
    {
        static Mesh _mesh;

        public static Mesh Get()
        {
            if (_mesh != null) return _mesh;

            const int sides = 8;
            var vertices = new Vector3[sides + 2];
            var triangles = new int[sides * 6];
            vertices[0] = new Vector3(0, 1f, 0); // apex
            vertices[sides + 1] = new Vector3(0, 0, 0); // base center

            for (int i = 0; i < sides; i++)
            {
                float a = i * Mathf.PI * 2f / sides;
                vertices[i + 1] = new Vector3(Mathf.Cos(a) * 0.5f, 0, Mathf.Sin(a) * 0.5f);
            }

            int ti = 0;
            for (int i = 0; i < sides; i++)
            {
                int next = (i % sides) + 1;
                int cur = i + 1;
                int nextIdx = next == sides ? 1 : cur + 1;

                // Side triangle (apex, cur, next).
                triangles[ti++] = 0;
                triangles[ti++] = cur;
                triangles[ti++] = nextIdx;

                // Base triangle.
                triangles[ti++] = sides + 1;
                triangles[ti++] = nextIdx;
                triangles[ti++] = cur;
            }

            _mesh = new Mesh { vertices = vertices, triangles = triangles };
            _mesh.RecalculateNormals();
            _mesh.RecalculateBounds();
            return _mesh;
        }
    }
}
