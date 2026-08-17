using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using Gati.Core;
using Gati.Player;
using Gati.World;
using Gati.Gameplay;
using Gati.UI;

namespace Gati.EditorTools
{
    /// <summary>
    /// One-click scene setup: builds a complete, wired, playable Gati scene
    /// from scratch (terrain streamer, player + placeholder character rig,
    /// obstacle spawner, chase camera, light, HUD canvas). Hand-authoring a
    /// .unity YAML scene by hand is fragile without the Editor to verify it
    /// — this runs *inside* the Editor instead, so every reference is wired
    /// by real API calls.
    /// </summary>
    public static class GatiSceneBuilder
    {
        [MenuItem("Gati/Build Sample Scene")]
        public static void BuildScene()
        {
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

            var light = new GameObject("Directional Light").AddComponent<Light>();
            light.type = LightType.Directional;
            light.transform.rotation = Quaternion.Euler(50, -30, 0);
            light.intensity = 1.1f;

            // --- Player -----------------------------------------------------
            var playerGO = new GameObject("Player");
            playerGO.transform.position = new Vector3(0, 0, 0);
            var rb = playerGO.AddComponent<Rigidbody>();
            rb.isKinematic = true;
            rb.useGravity = false;
            var capsule = playerGO.AddComponent<CapsuleCollider>();
            capsule.height = 1.8f;
            capsule.radius = 0.3f;
            capsule.center = new Vector3(0, 0.9f, 0);
            var controller = playerGO.AddComponent<PlayerController>();
            controller.bodyCollider = capsule;

            var socketGO = new GameObject("ModelSocket");
            socketGO.transform.SetParent(playerGO.transform, false);
            controller.modelSocket = socketGO.transform;
            var rig = socketGO.AddComponent<CharacterRig>();
            rig.controller = controller;

            // --- World systems -----------------------------------------------
            var terrain = new GameObject("TerrainStreamer").AddComponent<TerrainStreamer>();
            terrain.player = playerGO.transform;

            var spawner = new GameObject("ObstacleSpawner").AddComponent<ObstacleSpawner>();
            spawner.controller = controller;

            // --- Game manager --------------------------------------------------
            var gmGO = new GameObject("GameManager");
            var gm = gmGO.AddComponent<GameManager>();
            gm.controller = controller;

            // --- Camera -----------------------------------------------------
            var camGO = new GameObject("Main Camera");
            camGO.tag = "MainCamera";
            var cam = camGO.AddComponent<Camera>();
            cam.clearFlags = CameraClearFlags.SolidColor;
            cam.fieldOfView = 62f;
            camGO.AddComponent<AudioListener>();
            var camRig = camGO.AddComponent<CameraRig>();
            camRig.target = playerGO.transform;
            var sky = camGO.AddComponent<SkyController>();
            sky.gameManager = gm;

            // --- Character rig needs a valid character before first Build ----
            rig.Build(gm.character);

            // --- EventSystem (required for uGUI button clicks) ---------------
            var es = new GameObject("EventSystem");
            es.AddComponent<EventSystem>();
            es.AddComponent<StandaloneInputModule>();

            // --- HUD Canvas ---------------------------------------------------
            var hud = BuildHud(gm);

            EditorSceneManager.MarkSceneDirty(scene);
            var scenesDir = "Assets/Scenes";
            if (!AssetDatabase.IsValidFolder(scenesDir))
            {
                AssetDatabase.CreateFolder("Assets", "Scenes");
            }
            EditorSceneManager.SaveScene(scene, scenesDir + "/Main.unity");

            Debug.Log("Gati sample scene built and saved to Assets/Scenes/Main.unity. Press Play to run.");
        }

        static HudController BuildHud(GameManager gm)
        {
            var canvasGO = new GameObject("HudCanvas");
            var canvas = canvasGO.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            var scaler = canvasGO.AddComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1080, 1920);
            canvasGO.AddComponent<GraphicRaycaster>();

            var hudGO = new GameObject("Hud");
            hudGO.transform.SetParent(canvasGO.transform, false);
            var hud = hudGO.AddComponent<HudController>();
            hud.gameManager = gm;

            // Distance (top-left)
            hud.distanceText = MakeText(canvasGO.transform, "DistanceText", "0 m", 56, TextAnchor.UpperLeft,
                new Vector2(0, 1), new Vector2(0, 1), new Vector2(40, -40), new Vector2(400, 70));

            hud.regionText = MakeText(canvasGO.transform, "RegionText", "Mumbai", 34, TextAnchor.UpperLeft,
                new Vector2(0, 1), new Vector2(0, 1), new Vector2(40, -104), new Vector2(400, 50));

            // Sparks (top-right)
            hud.sparksText = MakeText(canvasGO.transform, "SparksText", "0", 40, TextAnchor.UpperRight,
                new Vector2(1, 1), new Vector2(1, 1), new Vector2(-40, -40), new Vector2(200, 60));

            // Hearts (below sparks)
            hud.heartImages = new Image[3];
            for (int i = 0; i < 3; i++)
            {
                var heart = MakeImage(canvasGO.transform, $"Heart{i}", new Color(0.94f, 0.24f, 0.28f),
                    new Vector2(1, 1), new Vector2(1, 1), new Vector2(-40 - i * 44, -100), new Vector2(34, 34));
                hud.heartImages[i] = heart;
            }

            // Gati meter bar — stretches horizontally across the top, so it's
            // built directly with anchor-stretch offsets rather than via
            // MakeImage's anchoredPosition/sizeDelta helper (those two
            // addressing modes don't mix cleanly on a stretched rect).
            var barBgGO = new GameObject("GatiBarBg");
            barBgGO.transform.SetParent(canvasGO.transform, false);
            var barBg = barBgGO.AddComponent<Image>();
            barBg.color = new Color(0, 0, 0, 0.4f);
            var barBgRt = barBgGO.GetComponent<RectTransform>();
            barBgRt.anchorMin = new Vector2(0, 1);
            barBgRt.anchorMax = new Vector2(1, 1);
            barBgRt.pivot = new Vector2(0.5f, 1f);
            barBgRt.offsetMin = new Vector2(40, -172);
            barBgRt.offsetMax = new Vector2(-40, -150);

            var barFillGO = new GameObject("GatiBarFill");
            barFillGO.transform.SetParent(barBg.transform, false);
            var fillImg = barFillGO.AddComponent<Image>();
            fillImg.color = new Color(1f, 0.62f, 0.2f);
            fillImg.type = Image.Type.Filled;
            fillImg.fillMethod = Image.FillMethod.Horizontal;
            fillImg.fillAmount = 1f;
            var frt = barFillGO.GetComponent<RectTransform>();
            frt.anchorMin = Vector2.zero;
            frt.anchorMax = Vector2.one;
            frt.offsetMin = Vector2.zero;
            frt.offsetMax = Vector2.zero;
            hud.gatiFill = fillImg;

            // Region entry banner (center)
            var bannerGO = new GameObject("RegionBanner");
            bannerGO.transform.SetParent(canvasGO.transform, false);
            var bannerBg = bannerGO.AddComponent<Image>();
            bannerBg.color = new Color(0, 0, 0, 0.55f);
            var bannerRt = bannerGO.GetComponent<RectTransform>();
            bannerRt.anchorMin = new Vector2(0.5f, 0.5f);
            bannerRt.anchorMax = new Vector2(0.5f, 0.5f);
            bannerRt.sizeDelta = new Vector2(700, 220);
            bannerRt.anchoredPosition = Vector2.zero;
            hud.bannerRoot = bannerGO;
            hud.bannerNameText = MakeText(bannerGO.transform, "BannerName", "Region", 54, TextAnchor.MiddleCenter,
                new Vector2(0, 0.5f), new Vector2(1, 1), new Vector2(0, -10), new Vector2(0, 100));
            hud.bannerTaglineText = MakeText(bannerGO.transform, "BannerTagline", "tagline", 28, TextAnchor.MiddleCenter,
                new Vector2(0, 0), new Vector2(1, 0.5f), new Vector2(0, 10), new Vector2(0, 80));

            // Game over panel
            var overGO = new GameObject("GameOverPanel");
            overGO.transform.SetParent(canvasGO.transform, false);
            var overBg = overGO.AddComponent<Image>();
            overBg.color = new Color(0.06f, 0.04f, 0.1f, 0.92f);
            var overRt = overGO.GetComponent<RectTransform>();
            overRt.anchorMin = Vector2.zero;
            overRt.anchorMax = Vector2.one;
            overRt.offsetMin = Vector2.zero;
            overRt.offsetMax = Vector2.zero;
            hud.gameOverRoot = overGO;

            hud.gameOverStatsText = MakeText(overGO.transform, "StatsText", "Run ended", 36, TextAnchor.MiddleCenter,
                new Vector2(0.1f, 0.4f), new Vector2(0.9f, 0.75f), Vector2.zero, Vector2.zero);

            var btnGO = new GameObject("RestartButton");
            btnGO.transform.SetParent(overGO.transform, false);
            var btnImg = btnGO.AddComponent<Image>();
            btnImg.color = new Color(1f, 0.54f, 0.24f);
            var btnRt = btnGO.GetComponent<RectTransform>();
            btnRt.anchorMin = new Vector2(0.5f, 0.3f);
            btnRt.anchorMax = new Vector2(0.5f, 0.3f);
            btnRt.sizeDelta = new Vector2(360, 90);
            var btn = btnGO.AddComponent<Button>();
            btn.onClick.AddListener(hud.RestartRun);
            MakeText(btnGO.transform, "Label", "RUN AGAIN", 32, TextAnchor.MiddleCenter,
                Vector2.zero, Vector2.one, Vector2.zero, Vector2.zero).color = Color.black;

            return hud;
        }

        static Text MakeText(Transform parent, string name, string content, int fontSize, TextAnchor anchor,
            Vector2 anchorMin, Vector2 anchorMax, Vector2 anchoredPos, Vector2 sizeDelta)
        {
            var go = new GameObject(name);
            go.transform.SetParent(parent, false);
            var text = go.AddComponent<Text>();
            text.text = content;
            text.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            text.fontSize = fontSize;
            text.alignment = anchor;
            text.color = Color.white;
            text.horizontalOverflow = HorizontalWrapMode.Overflow;
            text.verticalOverflow = VerticalWrapMode.Overflow;

            var rt = go.GetComponent<RectTransform>();
            rt.anchorMin = anchorMin;
            rt.anchorMax = anchorMax;
            rt.anchoredPosition = anchoredPos;
            rt.sizeDelta = sizeDelta;
            return text;
        }

        static Image MakeImage(Transform parent, string name, Color color,
            Vector2 anchorMin, Vector2 anchorMax, Vector2 anchoredPos, Vector2 sizeDelta)
        {
            var go = new GameObject(name);
            go.transform.SetParent(parent, false);
            var img = go.AddComponent<Image>();
            img.color = color;

            var rt = go.GetComponent<RectTransform>();
            rt.anchorMin = anchorMin;
            rt.anchorMax = anchorMax;
            rt.anchoredPosition = anchoredPos;
            rt.sizeDelta = sizeDelta;
            return img;
        }
    }
}
