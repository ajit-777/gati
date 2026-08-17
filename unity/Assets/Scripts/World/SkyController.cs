using UnityEngine;
using Gati.Core;

namespace Gati.World
{
    /// <summary>Tints the camera's clear color toward the current region's horizon color.</summary>
    [RequireComponent(typeof(Camera))]
    public class SkyController : MonoBehaviour
    {
        public GameManager gameManager;
        Camera _cam;

        void Awake() => _cam = GetComponent<Camera>();

        void Update()
        {
            if (gameManager == null || gameManager.currentRegion == null) return;
            _cam.backgroundColor = Color.Lerp(_cam.backgroundColor, gameManager.currentRegion.SkyBottom, 1f - Mathf.Exp(-2f * Time.deltaTime));
        }
    }
}
