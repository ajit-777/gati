using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;

namespace Gati.EditorTools
{
    /// <summary>Paths to the Mixamo files SETUP.md asks the user to place under Assets/Models.</summary>
    public static class MixamoPaths
    {
        public const string Character = "Assets/Models/character.fbx";
        public const string Idle = "Assets/Models/Ch02_nonPBR@Idle.fbx";
        public const string Running = "Assets/Models/Ch02_nonPBR@Running.fbx";
        public const string Jump = "Assets/Models/Ch02_nonPBR@Jump.fbx";
        public const string Controller = "Assets/Animation/RunnerController.controller";
    }

    /// <summary>
    /// Forces every FBX under Assets/Models to import as a Humanoid rig.
    /// Mixamo's skeleton naming is standardized, so "Create From This
    /// Model" retargets correctly on each file independently — the
    /// character file and the animation-only files don't need to
    /// cross-reference a shared Avatar for this to work.
    /// </summary>
    public class MixamoModelPostprocessor : AssetPostprocessor
    {
        void OnPreprocessModel()
        {
            var path = assetPath.Replace('\\', '/');
            if (!path.StartsWith("Assets/Models/")) return;

            var importer = (ModelImporter)assetImporter;
            importer.animationType = ModelImporterAnimationType.Human;
            importer.avatarSetup = ModelImporterAvatarSetup.CreateFromThisModel;
        }
    }

    /// <summary>
    /// One-click setup for the Mixamo files once they're sitting in
    /// Assets/Models (see unity/SETUP.md): forces a reimport so the
    /// Humanoid rig postprocessor above actually applies (it only runs
    /// during import, and these files may already have been auto-imported
    /// with default settings before this script existed), then builds a
    /// simple Idle/Run/Jump Animator Controller from the three clips.
    /// </summary>
    public static class MixamoSetup
    {
        [MenuItem("Gati/Setup Mixamo Character")]
        public static void Run()
        {
            string[] modelPaths = { MixamoPaths.Character, MixamoPaths.Idle, MixamoPaths.Running, MixamoPaths.Jump };
            bool anyMissing = false;
            foreach (var p in modelPaths)
            {
                if (AssetDatabase.LoadAssetAtPath<GameObject>(p) == null)
                {
                    Debug.LogError($"Gati: expected Mixamo file not found at {p} — check the filename matches exactly.");
                    anyMissing = true;
                    continue;
                }
                AssetDatabase.ImportAsset(p, ImportAssetOptions.ForceUpdate);
            }
            if (anyMissing) return;

            var idleClip = FindClip(MixamoPaths.Idle);
            var runClip = FindClip(MixamoPaths.Running);
            var jumpClip = FindClip(MixamoPaths.Jump);
            if (idleClip == null || runClip == null || jumpClip == null)
            {
                Debug.LogError("Gati: could not find an AnimationClip inside one of the Mixamo FBX files — check they imported without errors.");
                return;
            }

            if (!AssetDatabase.IsValidFolder("Assets/Animation"))
                AssetDatabase.CreateFolder("Assets", "Animation");

            if (AssetDatabase.LoadAssetAtPath<AnimatorController>(MixamoPaths.Controller) != null)
                AssetDatabase.DeleteAsset(MixamoPaths.Controller);

            var controller = AnimatorController.CreateAnimatorControllerAtPath(MixamoPaths.Controller);
            controller.AddParameter("Speed", AnimatorControllerParameterType.Float);
            controller.AddParameter("Jump", AnimatorControllerParameterType.Trigger);

            var rootSM = controller.layers[0].stateMachine;

            var idleState = rootSM.AddState("Idle");
            idleState.motion = idleClip;

            var runState = rootSM.AddState("Run");
            runState.motion = runClip;

            var jumpState = rootSM.AddState("Jump");
            jumpState.motion = jumpClip;

            rootSM.defaultState = idleState;

            var idleToRun = idleState.AddTransition(runState);
            idleToRun.hasExitTime = false;
            idleToRun.duration = 0.15f;
            idleToRun.AddCondition(AnimatorConditionMode.Greater, 0.1f, "Speed");

            var runToIdle = runState.AddTransition(idleState);
            runToIdle.hasExitTime = false;
            runToIdle.duration = 0.15f;
            runToIdle.AddCondition(AnimatorConditionMode.Less, 0.1f, "Speed");

            var anyToJump = rootSM.AddAnyStateTransition(jumpState);
            anyToJump.hasExitTime = false;
            anyToJump.duration = 0.05f;
            anyToJump.AddCondition(AnimatorConditionMode.If, 0, "Jump");

            var jumpToRun = jumpState.AddTransition(runState);
            jumpToRun.hasExitTime = true;
            jumpToRun.exitTime = 0.85f;
            jumpToRun.duration = 0.1f;

            AssetDatabase.SaveAssets();
            Debug.Log($"Gati: built {MixamoPaths.Controller}. Now run Gati > Build Sample Scene to use it.");
        }

        static AnimationClip FindClip(string path)
        {
            foreach (var asset in AssetDatabase.LoadAllAssetsAtPath(path))
            {
                if (asset is AnimationClip clip && !clip.name.Contains("__preview__"))
                    return clip;
            }
            return null;
        }
    }
}
