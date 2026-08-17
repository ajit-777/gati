using UnityEngine;
using Gati.Player;
using Gati.Core;

namespace Gati.Gameplay
{
    /// <summary>A "Spark" — region-flavored currency pickup. Bobs and spins in place.</summary>
    [RequireComponent(typeof(Collider))]
    public class Collectible : MonoBehaviour
    {
        public bool isPowerUp;
        float _t;
        Vector3 _basePos;
        bool _consumed;

        void Start() => _basePos = transform.localPosition;

        void Update()
        {
            _t += Time.deltaTime * 4f;
            transform.Rotate(Vector3.up, 90f * Time.deltaTime, Space.Self);
            var p = _basePos;
            p.y += Mathf.Sin(_t) * 0.08f;
            transform.localPosition = p;
        }

        void OnTriggerEnter(Collider other)
        {
            if (_consumed) return;
            var controller = other.GetComponentInParent<PlayerController>();
            if (controller == null) return;

            _consumed = true;
            if (isPowerUp)
            {
                GameManager.Instance?.OnPowerUpCollected();
                controller.FlashInvincible(3.5f);
            }
            else
            {
                GameManager.Instance?.OnSparkCollected();
            }
            gameObject.SetActive(false);
        }
    }
}
