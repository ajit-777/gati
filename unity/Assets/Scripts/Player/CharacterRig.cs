using UnityEngine;
using Gati.Data;

namespace Gati.Player
{
    /// <summary>
    /// Placeholder low-poly 3D runner built entirely from primitives
    /// (capsules/cubes), with a real hip/knee/shoulder/elbow forward-
    /// kinematic run cycle driven by <see cref="PlayerController"/>.
    ///
    /// This exists so the game is playable in true 3D immediately, with no
    /// external assets. To upgrade to a life-like character: import a
    /// rigged humanoid (Mixamo export or Asset Store purchase) as a child
    /// prefab of PlayerController.modelSocket, disable/remove this
    /// component's GameObject, and drive its Animator's "Jump"/"Slide"
    /// triggers and a blend-tree "Speed" float from PlayerController's
    /// IsJumping/IsSliding/RunCycle instead. See unity/SETUP.md.
    /// </summary>
    public class CharacterRig : MonoBehaviour
    {
        public PlayerController controller;
        CharacterData _data;

        Transform _hips, _head, _torso;
        Transform _lThigh, _lShin, _rThigh, _rShin;
        Transform _lUpperArm, _lForearm, _rUpperArm, _rForearm;

        const float ThighLen = 0.42f;
        const float ShinLen = 0.4f;
        const float UpperArmLen = 0.3f;
        const float ForearmLen = 0.28f;

        public void Build(CharacterData data)
        {
            _data = data;
            // Build() is normally called at edit time from GatiSceneBuilder,
            // where Destroy() doesn't actually work (it silently no-ops
            // outside Play mode) — use DestroyImmediate there instead.
            foreach (Transform child in transform)
            {
                if (Application.isPlaying) Destroy(child.gameObject);
                else DestroyImmediate(child.gameObject);
            }

            var skin = CreateMaterial(data.SkinColor);
            var outfit = CreateMaterial(data.OutfitPrimary);
            var accent = CreateMaterial(data.OutfitAccent);

            _hips = new GameObject("Hips").transform;
            _hips.SetParent(transform, false);
            _hips.localPosition = new Vector3(0, 0.86f, 0);

            _torso = MakePart(PrimitiveType.Cube, _hips, new Vector3(0, 0.28f, 0), new Vector3(0.34f, 0.42f, 0.2f), outfit);

            _head = MakePart(PrimitiveType.Sphere, _torso, new Vector3(0, 0.42f, 0.01f), new Vector3(0.26f, 0.26f, 0.26f), skin);
            MakePart(PrimitiveType.Cube, _head, new Vector3(0, 0.5f, 0), new Vector3(0.9f, 0.35f, 0.9f), accent);

            (_lThigh, _lShin) = MakeLeg(_hips, -0.12f, skin);
            (_rThigh, _rShin) = MakeLeg(_hips, 0.12f, skin);

            (_lUpperArm, _lForearm) = MakeArm(_torso, -0.22f, skin, accent, data.BodyType);
            (_rUpperArm, _rForearm) = MakeArm(_torso, 0.22f, skin, accent, data.BodyType);

            BuildAccessory(data, accent);
        }

        (Transform thigh, Transform shin) MakeLeg(Transform hips, float xOffset, Material skin)
        {
            var thigh = new GameObject("Thigh").transform;
            thigh.SetParent(hips, false);
            thigh.localPosition = new Vector3(xOffset, 0, 0);
            MakeLimbMesh(thigh, ThighLen, 0.09f, skin);

            var shin = new GameObject("Shin").transform;
            shin.SetParent(thigh, false);
            shin.localPosition = new Vector3(0, -ThighLen, 0);
            MakeLimbMesh(shin, ShinLen, 0.07f, skin);
            return (thigh, shin);
        }

        (Transform upper, Transform fore) MakeArm(Transform torso, float xOffset, Material skin, Material accent, BodyType body)
        {
            var upper = new GameObject("UpperArm").transform;
            upper.SetParent(torso, false);
            upper.localPosition = new Vector3(xOffset, 0.18f, 0);
            MakeLimbMesh(upper, UpperArmLen, 0.07f, skin);

            var fore = new GameObject("Forearm").transform;
            fore.SetParent(upper, false);
            fore.localPosition = new Vector3(0, -UpperArmLen, 0);
            MakeLimbMesh(fore, ForearmLen, 0.06f, skin);
            return (upper, fore);
        }

        void MakeLimbMesh(Transform bone, float length, float radius, Material mat)
        {
            var visual = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            visual.name = bone.name + "Visual";
            Destroy(visual.GetComponent<Collider>());
            visual.transform.SetParent(bone, false);
            visual.transform.localPosition = new Vector3(0, -length / 2f, 0);
            visual.transform.localScale = new Vector3(radius * 2f, length / 2f, radius * 2f);
            visual.GetComponent<Renderer>().sharedMaterial = mat;
        }

        /// Creates an unscaled anchor at <paramref name="localPos"/> with the
        /// actual primitive as a scaled child underneath it, and returns the
        /// anchor. A Unity primitive's own transform carries its mesh scale;
        /// parenting further children directly to it inherits that scale
        /// (and shears them under rotation). Returning the unscaled anchor
        /// instead means every further attachment point in this rig — torso
        /// holding the head, torso holding the arms, etc. — stays safe.
        Transform MakePart(PrimitiveType type, Transform parent, Vector3 localPos, Vector3 scale, Material mat)
        {
            var anchor = new GameObject(type + "Anchor").transform;
            anchor.SetParent(parent, false);
            anchor.localPosition = localPos;

            var visual = GameObject.CreatePrimitive(type);
            Destroy(visual.GetComponent<Collider>());
            visual.transform.SetParent(anchor, false);
            visual.transform.localScale = scale;
            visual.GetComponent<Renderer>().sharedMaterial = mat;

            return anchor;
        }

        void BuildAccessory(CharacterData data, Material accent)
        {
            switch (data.BodyType)
            {
                case BodyType.SchoolKid:
                    MakePart(PrimitiveType.Cube, _torso, new Vector3(0, 0.05f, -0.14f), new Vector3(0.9f, 0.7f, 0.3f), accent);
                    break;
                case BodyType.DeliveryRider:
                    MakePart(PrimitiveType.Cube, _torso, new Vector3(0, 0.15f, -0.16f), new Vector3(0.9f, 0.8f, 0.4f), accent);
                    break;
                case BodyType.CricketPlayer:
                    var bat = MakePart(PrimitiveType.Cube, _rUpperArm, new Vector3(0.15f, -0.5f, 0), new Vector3(0.5f, 2.2f, 0.15f), accent);
                    bat.localRotation = Quaternion.Euler(0, 0, 20);
                    break;
                case BodyType.Dancer:
                    MakePart(PrimitiveType.Cylinder, _hips, new Vector3(0, -0.15f, 0), new Vector3(1.3f, 0.12f, 1.3f), accent);
                    break;
                case BodyType.CollegeStudent:
                    MakePart(PrimitiveType.Cube, _torso, new Vector3(0.2f, 0f, -0.15f), new Vector3(0.35f, 0.6f, 0.2f), accent);
                    break;
            }
        }

        void Update()
        {
            if (controller == null || _hips == null) return;
            float t = controller.RunCycle;
            bool grounded = !controller.IsJumping;

            if (controller.IsSliding)
            {
                AnimateSlide();
                return;
            }

            float lean = grounded ? 6f : -4f;
            transform.localRotation = Quaternion.Euler(lean, 0, 0);

            float bob = grounded ? Mathf.Abs(Mathf.Sin(t * 2f)) * 0.05f : 0f;
            _hips.localPosition = new Vector3(0, 0.86f + bob, 0);

            AnimateLeg(_lThigh, _lShin, t + Mathf.PI, grounded);
            AnimateLeg(_rThigh, _rShin, t, grounded);
            AnimateArm(_lUpperArm, _lForearm, t + Mathf.PI);
            AnimateArm(_rUpperArm, _rForearm, t);
        }

        void AnimateLeg(Transform thigh, Transform shin, float phase, bool grounded)
        {
            float thighAngle = (grounded ? Mathf.Sin(phase) : 0.4f) * 55f;
            float recovery = grounded ? Mathf.Max(0f, -Mathf.Sin(phase)) : 0.5f;
            float shinBend = recovery * 75f;

            thigh.localRotation = Quaternion.Euler(thighAngle, 0, 0);
            shin.localRotation = Quaternion.Euler(-shinBend, 0, 0);
        }

        void AnimateArm(Transform upper, Transform fore, float phase)
        {
            float upperAngle = Mathf.Sin(phase) * 50f;
            float elbowBend = 30f + Mathf.Max(0f, Mathf.Sin(phase)) * 30f;
            upper.localRotation = Quaternion.Euler(upperAngle, 0, 0);
            fore.localRotation = Quaternion.Euler(-elbowBend, 0, 0);
        }

        void AnimateSlide()
        {
            transform.localRotation = Quaternion.Euler(70f, 0, 0);
            _lThigh.localRotation = Quaternion.Euler(-20f, 0, 0);
            _rThigh.localRotation = Quaternion.Euler(-20f, 0, 0);
            _lShin.localRotation = Quaternion.Euler(-40f, 0, 0);
            _rShin.localRotation = Quaternion.Euler(-40f, 0, 0);
        }

        static Material CreateMaterial(Color color)
        {
            Shader shader = Shader.Find("Universal Render Pipeline/Lit")
                             ?? Shader.Find("Standard")
                             ?? Shader.Find("Sprites/Default");
            var mat = new Material(shader) { color = color };
            return mat;
        }
    }
}
