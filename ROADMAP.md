# Ricochet Core — Project Roadmap

Plan from current MVP to production-ready mobile release.

Current state: ✅ MVP playable — ball physics, orbit core, blocks, aim+shoot, combos, random levels.

---

## Phase 1 — Feel & Juice
**Goal:** Make the existing MVP feel satisfying. Nail the orbit gameplay before adding anything.

- [x] Sound effects (ball launch, wall bounce, block hit, block destroy, orbit enter, combo trigger, level complete)
- [x] Background ambient music (looping low-fi sci-fi track)
- [x] Haptic feedback on block hits and combos (`HapticFeedback`)
- [x] Particle effects on block destruction (debris shards flying out)
- [x] Improved ball trail (smoother fade, color shift when in orbit)
- [x] Block spawn animation (fade-in + slight scale on level start)
- [x] Level complete transition (brief flash)
- [x] Tweak orbit physics until it feels *intentional* — this is the make-or-break feel test
- [x] Add slow-mo or time-dilation when ball enters orbit (optional, evaluate if it adds or distracts)

**Exit criteria:** Friends/testers play for 10+ minutes without prompting.

---

## Phase 2 — Game State & Persistence
**Goal:** Player progress survives between sessions.

- [x] `shared_preferences` integration for save data
- [x] Persist: high score, total levels cleared, total blocks destroyed, total ricochets, max combo
- [x] Pause functionality (tap pause button → overlay)
- [x] Game over screen when ball stops with no level progress (or remove if not needed)
- [x] Restart level / restart game flow
- [x] Settings screen (sound on/off, music on/off, haptics on/off)

---

## Phase 3 — Gameplay Variety
**Goal:** Keep the core orbit mechanic central, but add variety to prevent stagnation.

### Block types
- [x] **Explosive blocks** — destroy adjacent blocks on death
- [x] **Reinforced blocks** — show armor, take damage only above certain speed
- [x] **Moving blocks** — drift horizontally on a track
- [x] **Indestructible blocks** — obstacles, must be navigated around

### Orbit variants
- [x] **Multiple orbit cores** per level (start at level 5+)
- [x] **Repulsor cores** — push ball away instead of attract (visual: red glow vs cyan)
- [x] **Moving cores** — slow drift, harder to plan around (later levels)

### Power-ups (block drops)
- [x] **Multi-ball** — splits into 2 on next bounce
- [x] **Heavy ball** — bigger, ignores wall damping for 5 seconds
- [x] **Piercing ball** — passes through blocks for one shot

**Design rule:** No more than 1 power-up active at a time. Keep mechanics readable.

---

## Phase 4 — Progression & Meta
**Goal:** Reasons to come back.

- [x] Currency system (coins drop from destroyed blocks, more for high-HP)
- [x] Cosmetics shop:
  - [x] Ball skins (different colors, glow patterns)
  - [x] Trail effects (sparkle, electric, comet)
  - [x] Orbit core skins
- [x] Achievement system (e.g. "Clear level 10", "x20 combo", "Survive 100 ricochets")
- [x] Daily challenge (fixed seed level with leaderboard target)
- [x] Difficulty modes: Normal / Hard / Endless

---

## Phase 5 — Onboarding & UX
**Goal:** A new player understands the game in 30 seconds.

- [x] Main menu screen (Play / Shop / Settings / Stats)
- [x] First-launch tutorial:
  - Step 1: Aim and shoot (forced shot)
  - Step 2: Hit orbit core zone (forced setup)
  - Step 3: Combo (forced setup)
- [x] Tutorial dismissible after first clear
- [x] In-game hint system (subtle text on first encounter with new block type)

---

## Phase 6 — Performance & Polish
**Goal:** Smooth 60fps on mid-tier Android. Tight, professional feel.

- [ ] Profile with Flutter DevTools — verify no frame drops at high combo counts
- [x] Object pooling for particles and trail points (avoid GC pauses)
- [x] Audio loading optimization (preload all SFX, lazy-load music)
- [ ] Memory profiling at level 50+
- [ ] Battery usage check (30-min play session)
- [x] App icon (placeholder shipped via `flutter_launcher_icons`; swap `assets/branding/icon.png` for the final Figma artwork and rerun `dart run flutter_launcher_icons`)
- [x] Splash screen (`flutter_native_splash` configured with the same placeholder; rerun `dart run flutter_native_splash:create` after artwork swap)
- [ ] Test on: iPhone SE (small), iPhone 15 Pro (notch), Pixel 6 (Android mid), older Samsung

---

## Phase 7 — Release Preparation
**Goal:** Ready to ship to app stores.

- [ ] App Store Connect setup (bundle ID, certificates, provisioning)
- [ ] Google Play Console setup
- [ ] Store listing copy (description, keywords, what's new)
- [ ] Screenshots (5-8 per platform, all required sizes)
- [ ] Privacy policy URL (hosted somewhere)
- [ ] Age rating questionnaire
- [ ] App preview video (15-30s gameplay)
- [ ] TestFlight / Play Internal Testing build
- [ ] Crash reporting (Sentry or Firebase Crashlytics)

---

## Sequencing Notes

- Phase 1 is the most important — **if the orbit doesn't feel good, no later phase saves the game**.
- Phases 2 and 3 can be done in parallel (different files / systems).
- Phase 4 only makes sense if Phase 1 produces something players want to repeat.
- Skip Phase 7 monetization stuff until there's evidence of retention.

## Architecture stays the same

Keep current modular structure (`core/ entities/ physics/ rendering/ ui/`). Add as needed:
- `lib/game/audio/` for SFX/music
- `lib/game/save/` for persistence
- `lib/game/effects/` for particles
- `lib/screens/` for menu / shop / settings widgets

No ECS, no Box2D, no over-abstraction. Stay code-first.
