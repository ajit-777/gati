using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using Gati.Core;
using Gati.Data;

namespace Gati.UI
{
    /// <summary>
    /// Drives the in-game HUD (uGUI) from GameManager's events: distance,
    /// hearts, sparks, the Gati meter bar, a region-entry banner, and the
    /// game-over panel. All references are assigned by GatiSceneBuilder.
    /// </summary>
    public class HudController : MonoBehaviour
    {
        public GameManager gameManager;

        [Header("HUD")]
        public Text distanceText;
        public Text regionText;
        public Text sparksText;
        public Image[] heartImages;
        public Image gatiFill;

        [Header("Region banner")]
        public GameObject bannerRoot;
        public Text bannerNameText;
        public Text bannerTaglineText;
        float _bannerTimer;

        [Header("Game over")]
        public GameObject gameOverRoot;
        public Text gameOverStatsText;

        void OnEnable()
        {
            if (gameManager == null) return;
            gameManager.OnHudChanged += HandleHudChanged;
            gameManager.OnRegionChanged += HandleRegionChanged;
            gameManager.OnGameOver += HandleGameOver;
        }

        void OnDisable()
        {
            if (gameManager == null) return;
            gameManager.OnHudChanged -= HandleHudChanged;
            gameManager.OnRegionChanged -= HandleRegionChanged;
            gameManager.OnGameOver -= HandleGameOver;
        }

        void Start()
        {
            if (bannerRoot != null) bannerRoot.SetActive(false);
            if (gameOverRoot != null) gameOverRoot.SetActive(false);
        }

        void Update()
        {
            if (_bannerTimer > 0f)
            {
                _bannerTimer -= Time.deltaTime;
                if (_bannerTimer <= 0f && bannerRoot != null) bannerRoot.SetActive(false);
            }
        }

        void HandleHudChanged()
        {
            if (distanceText != null) distanceText.text = $"{gameManager.distance:0} m";
            if (regionText != null) regionText.text = gameManager.currentRegion.DisplayName;
            if (sparksText != null) sparksText.text = gameManager.sparks.ToString();
            if (gatiFill != null) gatiFill.fillAmount = gameManager.gati / 100f;

            if (heartImages != null)
            {
                for (int i = 0; i < heartImages.Length; i++)
                {
                    if (heartImages[i] == null) continue;
                    heartImages[i].color = i < gameManager.hearts ? new Color(0.94f, 0.24f, 0.28f) : new Color(1, 1, 1, 0.25f);
                }
            }
        }

        void HandleRegionChanged(RegionData region)
        {
            if (bannerRoot == null) return;
            bannerRoot.SetActive(true);
            if (bannerNameText != null) bannerNameText.text = region.DisplayName;
            if (bannerTaglineText != null) bannerTaglineText.text = region.Tagline;
            _bannerTimer = 3f;
        }

        void HandleGameOver()
        {
            if (gameOverRoot == null) return;
            gameOverRoot.SetActive(true);
            if (gameOverStatsText != null)
            {
                float km = gameManager.distance / 1000f;
                gameOverStatsText.text =
                    $"Caught by {gameManager.currentRegion.ChaseFlavor} in {gameManager.currentRegion.DisplayName}\n\n" +
                    $"Distance: {km:0.00} km\n" +
                    $"Sparks earned: {gameManager.sparks}\n" +
                    $"Total Sparks: {SaveSystem.TotalSparks}\n" +
                    $"Best: {(SaveSystem.BestDistance / 1000f):0.00} km";
            }
        }

        public void RestartRun()
        {
            SceneManager.LoadScene(SceneManager.GetActiveScene().name);
        }
    }
}
