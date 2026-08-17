# Gati (गति) — a run across India

An endless runner whose progression is a journey through India: Mumbai →
Goa → Kerala → Bengaluru → Chennai → Hyderabad → Jaipur → Delhi →
Varanasi → Northeast India → Kashmir → Ladakh. Five Indian character
archetypes (school kid, college student, delivery rider, cricket player,
dancer), region-flavored obstacles/collectibles/power-ups, and a "Gati"
momentum meter as the game's own spin on the chase mechanic — lose it (not
just your hearts) and the region's chase (a monsoon wave, dust storm,
avalanche...) catches you.

This repo has two versions, in order of how the project evolved:

## `unity/` — 3D (current)

Real 3D: a chase camera behind the runner, moving through procedurally
generated terrain per region, built entirely from primitives (no external
art assets). See [`unity/SETUP.md`](unity/SETUP.md) to get it running —
it needs the Unity Editor (free) and, for a life-like character instead of
the current placeholder, a rigged model you bring in yourself (Mixamo is
free; instructions in SETUP.md).

## `lib/` — 2D Flutter/Flame prototype (earlier version)

The original single-codebase (iOS + Android) prototype, built with Flutter
and the Flame game engine, procedurally drawn (no external art assets).
Fully playable: `flutter pub get && flutter run`.
