# Gati — Unity 3D setup

This is the 3D pivot of Gati (the Flutter/Flame 2D prototype lives in
`../lib` at the repo root, kept as a working reference). Everything here —
terrain, obstacles, camera, HUD, game loop — is written and wired already.
The one piece I can't produce myself is a life-like rigged 3D character;
you'll need to bring that in (free options below), everything else just
needs the Editor.

## 1. Install the Editor (one-time)

1. Open **Unity Hub** (already installed via Homebrew).
2. Sign in with a free Unity ID (Installs → this is the step that needs your
   own login — I can't do it for you).
3. Installs tab → **Install Editor** → pick a **2022.3 LTS** version
   (the project targets `2022.3.50f1`; a nearby LTS patch is fine, Hub will
   offer to retarget the project automatically).
4. During install, check **iOS Build Support** and **Android Build Support**
   modules.

## 2. Open the project

Hub → **Add** → select `unity/` (this folder, the one containing `Assets/`).
Open it. Unity will import and generate `Library/` — first import takes a
few minutes.

## 3. Build the sample scene (one click)

Menu bar → **Gati → Build Sample Scene**.

This runs `Assets/Editor/GatiSceneBuilder.cs`, which constructs and saves
`Assets/Scenes/Main.unity` from scratch: terrain streamer, player +
placeholder character, obstacle spawner, chase camera, light, and the HUD
canvas — fully wired, nothing left to connect by hand.

Press **Play**. Controls: arrow keys / WASD, or swipe on a touch device —
left/right to change lanes, up/space to jump, down to slide.

## 4. What you'll see right now

Real 3D: a chase camera behind a runner, moving through procedurally
generated terrain (buildings, palms, temples, forts, snow peaks — one style
per region, see `Assets/Scripts/World/TerrainStreamer.cs`) built from
primitives. The character itself is also primitives — capsules for limbs,
with a real jointed run/jump/slide animation
(`Assets/Scripts/Player/CharacterRig.cs`) — good enough to judge the
gameplay feel, not life-like.

## 5. Swapping in a real character

The placeholder lives on `Player → ModelSocket`, which has a `CharacterRig`
component building all the primitive body parts. To replace it:

**Option A — Mixamo (free, fastest)**
1. Go to mixamo.com, sign in with a free Adobe account (your account —
   I can't do this step).
2. Pick any humanoid character, and download it once with a **T-pose** (no
   animation) as FBX.
3. Download **Run**, **Jump**, and **Idle** animations for the *same*
   character (so the skeleton matches) — "In Place" checked for Run.
4. Import all the FBX files into `Assets/Models/`.
5. On the character model's Rig import settings, set **Animation Type** to
   **Humanoid** and Apply.
6. Drag the character prefab as a child of `Player → ModelSocket` in the
   scene, at local position `(0,0,0)`.
7. Disable (or delete) the `CharacterRig` component's GameObject so the
   placeholder stops drawing.
8. Add an `Animator` to the imported character with an Animator Controller
   that has a `Speed` float (blend Idle↔Run) and `Jump`/`Slide` triggers.
9. Write a small script (a few lines) that reads
   `PlayerController.IsJumping` / `IsSliding` / `RunCycle` and drives those
   Animator parameters — happy to write this once you've got the character
   imported and can tell me its Animator parameter names.

**Option B — Unity Asset Store**
Buy a rigged humanoid character with a run cycle (search "runner
character" or "casual character pack"). Same steps 6–9 above once it's
imported.

## 6. Region art beyond primitives (optional, later)

`TerrainStreamer.cs` currently builds every region's landmarks
(Charminar, forts, ghats, snow peaks, ...) out of cubes/cylinders/cones.
If you want photoreal buildings/terrain later, the natural upgrade path is
swapping the primitive calls in `SpawnLandmarkProp()` for prefab
instantiation — same streaming/recycling logic, just fed real meshes
instead of primitives.

## 7. Building to device/simulator

**iOS**: File → Build Settings → iOS → Switch Platform → Build (produces an
Xcode project you open and run/archive from Xcode, same as any Unity iOS
build — this part I can drive from the CLI once you've done steps 1–3).

**Android**: File → Build Settings → Android → Switch Platform → Build.

## Known scope cuts (by design, for now)

- No character-select / home menu scene yet — the game boots straight into
  a run using whichever character `SaveSystem.SelectedCharacterId` last
  had (defaults to the first character). Easy to add once you've picked a
  real character model.
- No sound.
- Obstacle avoidance is real physics (jump height vs. obstacle height,
  slide collider vs. overhead beam height) — not scripted — so it should
  feel fair, but the exact clearance numbers in `ObstacleSpawner.cs` and
  `PlayerController.cs` may want tuning once you're playing it with a real
  character model's proportions.
