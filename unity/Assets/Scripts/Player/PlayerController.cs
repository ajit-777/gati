using UnityEngine;

namespace Gati.Player
{
    /// <summary>
    /// Three-lane runner movement: lane switching, jump, slide. World forward
    /// is +Z, lanes sit along X. Purely kinematic (no Rigidbody) so it stays
    /// simple and deterministic — obstacles/collectibles just check state
    /// exposed here (IsJumping/IsSliding/Lane) against their own kind.
    /// </summary>
    public class PlayerController : MonoBehaviour
    {
        [Header("Lanes")]
        public float laneWidth = 2.2f;
        public int laneCount = 3;
        public float laneSwitchSpeed = 12f;

        [Header("Jump")]
        public float jumpSpeed = 9.5f;
        public float gravity = 28f;

        [Header("Slide")]
        public float slideDuration = 0.55f;

        [Header("References")]
        public CapsuleCollider bodyCollider;
        public Transform modelSocket;

        public int Lane { get; private set; }
        public bool IsJumping => _jumpOffset < -0.02f || _jumpVelocity != 0f;
        public bool IsSliding { get; private set; }
        public bool IsInvincible => _invincibleTimer > 0f;
        public float RunCycle { get; private set; }

        float _groundY;
        float _jumpOffset;
        float _jumpVelocity;
        float _slideTimer;
        float _invincibleTimer;
        float _targetX;

        // Swipe input tracking.
        Vector2? _touchStart;

        void Awake()
        {
            _groundY = transform.position.y;
            Lane = laneCount / 2;
            _targetX = LaneToX(Lane);
            var p = transform.position;
            p.x = _targetX;
            transform.position = p;
        }

        void Update()
        {
            ReadInput();

            float stride = IsJumping ? 5.5f : 11f;
            RunCycle += Time.deltaTime * stride;

            // Lane glide.
            _targetX = LaneToX(Lane);
            var pos = transform.position;
            pos.x = Mathf.Lerp(pos.x, _targetX, 1f - Mathf.Exp(-laneSwitchSpeed * Time.deltaTime));

            // Jump physics.
            if (IsJumping || _jumpOffset < 0f)
            {
                _jumpOffset += _jumpVelocity * Time.deltaTime;
                _jumpVelocity -= gravity * Time.deltaTime;
                if (_jumpOffset >= 0f)
                {
                    _jumpOffset = 0f;
                    _jumpVelocity = 0f;
                }
            }

            if (IsSliding)
            {
                _slideTimer -= Time.deltaTime;
                if (_slideTimer <= 0f) IsSliding = false;
            }

            if (_invincibleTimer > 0f) _invincibleTimer -= Time.deltaTime;

            pos.y = _groundY + _jumpOffset;
            transform.position = pos;

            UpdateCollider();
        }

        void UpdateCollider()
        {
            if (bodyCollider == null) return;
            if (IsSliding)
            {
                // Kept a bit under the High obstacle's 1.0m clearance line
                // (see ObstacleSpawner) so a slide has real margin, not a
                // frame-perfect window.
                bodyCollider.height = 0.8f;
                bodyCollider.center = new Vector3(0, 0.4f, 0);
            }
            else
            {
                bodyCollider.height = 1.8f;
                bodyCollider.center = new Vector3(0, 0.9f, 0);
            }
        }

        /// Public so ObstacleSpawner/TerrainStreamer can align props to the
        /// same lane grid the player moves on.
        public float LaneX(int lane) => (lane - (laneCount - 1) / 2f) * laneWidth;

        float LaneToX(int lane) => LaneX(lane);

        void ReadInput()
        {
            if (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.A)) MoveLeft();
            if (Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.D)) MoveRight();
            if (Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.W) || Input.GetKeyDown(KeyCode.Space)) Jump();
            if (Input.GetKeyDown(KeyCode.DownArrow) || Input.GetKeyDown(KeyCode.S)) Slide();

            if (Input.touchCount > 0)
            {
                var t = Input.GetTouch(0);
                if (t.phase == TouchPhase.Began)
                {
                    _touchStart = t.position;
                }
                else if (t.phase == TouchPhase.Ended && _touchStart.HasValue)
                {
                    var delta = t.position - _touchStart.Value;
                    _touchStart = null;
                    const float threshold = 40f;
                    if (delta.magnitude < threshold)
                    {
                        Jump();
                        return;
                    }
                    if (Mathf.Abs(delta.x) > Mathf.Abs(delta.y))
                    {
                        if (delta.x < 0) MoveLeft(); else MoveRight();
                    }
                    else
                    {
                        if (delta.y > 0) Jump(); else Slide();
                    }
                }
            }
        }

        public void MoveLeft() => Lane = Mathf.Max(0, Lane - 1);
        public void MoveRight() => Lane = Mathf.Min(laneCount - 1, Lane + 1);

        public void Jump()
        {
            if (!IsJumping && !IsSliding) _jumpVelocity = jumpSpeed;
        }

        public void Slide()
        {
            if (!IsJumping)
            {
                IsSliding = true;
                _slideTimer = slideDuration;
            }
        }

        public void FlashInvincible(float seconds)
        {
            _invincibleTimer = Mathf.Max(_invincibleTimer, seconds);
        }
    }
}
