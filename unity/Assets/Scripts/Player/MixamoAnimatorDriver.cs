using UnityEngine;

namespace Gati.Player
{
    /// <summary>
    /// Drives a Mixamo character's Animator (Idle/Run/Jump) from
    /// PlayerController's state. There's no Mixamo slide clip in the
    /// standard free set, so sliding is faked by tilting/lowering this
    /// transform on top of whatever the Animator is doing — the same
    /// trick the primitive CharacterRig placeholder used.
    /// </summary>
    [RequireComponent(typeof(Animator))]
    public class MixamoAnimatorDriver : MonoBehaviour
    {
        public PlayerController controller;
        Animator _animator;
        bool _wasJumping;

        void Awake() => _animator = GetComponent<Animator>();

        void Update()
        {
            if (controller == null || _animator == null) return;

            _animator.SetFloat("Speed", controller.IsSliding ? 0f : 1f);

            if (controller.IsJumping && !_wasJumping)
            {
                _animator.SetTrigger("Jump");
            }
            _wasJumping = controller.IsJumping;

            if (controller.IsSliding)
            {
                transform.localRotation = Quaternion.Euler(60f, 0, 0);
                transform.localPosition = new Vector3(0, -0.5f, 0);
            }
            else
            {
                transform.localRotation = Quaternion.identity;
                transform.localPosition = Vector3.zero;
            }
        }
    }
}
