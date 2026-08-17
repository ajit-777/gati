using UnityEngine;

namespace Gati.World
{
    /// <summary>Third-person chase camera: trails behind and above the player, looking slightly ahead.</summary>
    public class CameraRig : MonoBehaviour
    {
        public Transform target;
        public Vector3 offset = new Vector3(0, 3.2f, -6.5f);
        public float followSpeed = 8f;
        public float lookAheadZ = 4f;

        void LateUpdate()
        {
            if (target == null) return;
            var desired = target.position + offset;
            transform.position = Vector3.Lerp(transform.position, desired, 1f - Mathf.Exp(-followSpeed * Time.deltaTime));
            var lookAt = target.position + Vector3.forward * lookAheadZ + Vector3.up * 1f;
            transform.LookAt(lookAt);
        }
    }
}
