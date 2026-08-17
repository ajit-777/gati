using UnityEngine;
using Gati.Player;
using Gati.Core;

namespace Gati.Gameplay
{
    public enum ObstacleKind { Low, High, Full }

    /// <summary>
    /// A trigger volume shaped so that avoidance is physically real, not
    /// scripted: Low obstacles are short enough for a jump's peak height to
    /// clear, High obstacles float above where a slide's shrunk collider
    /// reaches, and Full obstacles span the whole lane height so only a
    /// lane change avoids them. See ObstacleSpawner for the exact bounds
    /// per kind and the reasoning behind the jump/slide numbers.
    /// </summary>
    [RequireComponent(typeof(Collider))]
    public class Obstacle : MonoBehaviour
    {
        public ObstacleKind kind;
        bool _consumed;

        void OnTriggerEnter(Collider other)
        {
            if (_consumed) return;
            var controller = other.GetComponentInParent<PlayerController>();
            if (controller == null) return;

            _consumed = true;
            if (!controller.IsInvincible)
            {
                GameManager.Instance?.OnObstacleHit();
                controller.FlashInvincible(1.3f);
            }
            gameObject.SetActive(false);
        }
    }
}
