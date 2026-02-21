# Dead Profit — UEFN Automation Guide

## Reality Check: What Can and Can't Be Automated

### ❌ What UEFN Does NOT Support
- **No Python scripting** — UEFN strips Unreal's Python editor plugin entirely
- **No CLI/command-line building** — UEFN is GUI-only, no headless builds
- **No programmatic .umap/.uasset generation** — binary formats, no external tooling
- **No Editor Utility Widgets or Blueprints** — UEFN removes these UE5 features
- **No third-party plugins** — UEFN has a locked plugin ecosystem

### ✅ What CAN Be Automated (via Verse at Runtime)
- **Prop spawning** — `SpawnProp()` places props at runtime from `creative_prop_asset` references
- **Dynamic lighting** — Control `customizable_light_device` color, intensity, on/off
- **VFX/particles** — Toggle `vfx_spawner_device` for fog, sparks, etc.
- **Audio** — Trigger `audio_player_device` per zone
- **Game logic** — Tycoon mechanics, enemy spawning, day/night cycle, scoring

### ⚠️ What Needs Manual Work in the UEFN Editor
1. **Terrain sculpting** — Paint the ground, create hills/paths
2. **Initial device placement** — Drop the Verse devices + reference props into the level
3. **Asset discovery** — Browse content browser, find props you like
4. **Prop gallery references** — You must place at least one of each prop type so Verse can reference it
5. **Lighting setup** — Place `customizable_light_device` actors that Verse will control
6. **VFX device placement** — Place `vfx_spawner_device` actors for fog/particles
7. **Audio device placement** — Place `audio_player_device` actors
8. **Island settings** — Configure island size, game mode, player count

---

## How the Automation Works

### Architecture
```
park-config.json  ──→  park_layout_generator.verse  ──→  Spawns props at runtime
                  ──→  lighting_controller.verse     ──→  Controls lights dynamically
                  ──→  atmosphere_manager.verse       ──→  Fog, particles, sounds
                  ──→  prop_placer.verse              ──→  Scatter decorations
```

Since Verse can't read JSON files at runtime, the config data is **hardcoded as Verse data structures** inside the scripts. The JSON files serve as your **planning documents** — edit the JSON, then update the corresponding Verse arrays.

### Step-by-Step Workflow

#### Phase 1: Island Setup (Manual, ~30 min)
1. Create a new UEFN project → Blank island (large)
2. Set island to 16-player, no build, custom game mode
3. Sculpt basic terrain: flat areas for zones, paths between them
4. Paint terrain with grass/concrete/dirt materials

#### Phase 2: Place Reference Props (Manual, ~1-2 hours)
1. Open Content Browser → search for props from `ASSETS-CHECKLIST.md`
2. For each prop type you want to spawn at runtime, place ONE instance in the level
3. These become your `creative_prop_asset` references in Verse
4. Group them in a hidden "reference shelf" area off the playable map

#### Phase 3: Place Devices (Manual, ~1 hour)
1. Place `customizable_light_device` × 50-100 around the map (Verse controls them)
2. Place `vfx_spawner_device` × 20-30 for fog/particle zones
3. Place `audio_player_device` × 10-15 for ambient sound zones
4. Place `item_spawner_device` for tycoon pickups
5. Place `trigger_device` for zone boundaries

#### Phase 4: Add Verse Scripts (Automated, ~15 min setup)
1. In UEFN, create a new Verse device for each `.verse` file
2. Copy-paste the code from the `verse/` folder
3. Wire up device references in the Details panel (drag props/devices onto the Verse device's exposed properties)
4. Compile (Ctrl+Shift+B)

#### Phase 5: Test and Tweak
1. Launch session (Ctrl+L)
2. Props spawn automatically in configured positions
3. Lights cycle with day/night
4. Fog and particles activate per zone
5. Adjust positions in the Verse data arrays, recompile, retest

---

## File Overview

| File | Purpose |
|------|---------|
| `verse/park_layout_generator.verse` | Main orchestrator — spawns zone markers and boundary props |
| `verse/prop_placer.verse` | Generic prop spawning system with position arrays |
| `verse/ride_builder.verse` | Interactive ride structures with moving parts |
| `verse/lighting_controller.verse` | Day/night lighting system with horror flicker effects |
| `verse/atmosphere_manager.verse` | Fog, particles, ambient sound per zone |
| `verse/terrain_decorator.verse` | Scatter small detail props (debris, leaves, cracks) |
| `config/park-config.json` | Master layout blueprint (planning reference) |
| `config/entity-spawn-config.json` | Enemy/NPC spawn configuration |
| `config/atmosphere-config.json` | Per-zone atmosphere settings |
| `ASSETS-CHECKLIST.md` | Shopping list of every prop/asset needed |
| `CREATIVE-GUIDE.md` | Visual direction guide for non-artists |

---

## Tips for Non-Artists

1. **Symmetry is your friend** — Mirror one side of a zone to the other
2. **Clutter = realism** — More scattered props = more believable
3. **Follow the guide** — `CREATIVE-GUIDE.md` has exact colors, spacing, patterns
4. **Copy reference images** — Don't invent, replicate what looks good
5. **Let Verse do the work** — The scripts handle repetitive placement; you just position the anchor points

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Props don't spawn | Check `creative_prop_asset` references are wired in Details panel |
| Compile errors | Ensure indentation uses spaces (Verse is whitespace-sensitive) |
| Props spawn underground | Adjust Z coordinates in position arrays (+100 = 1 meter up) |
| Too many props, lag | Reduce array sizes in prop_placer; UEFN has ~50k prop limit |
| Lights don't change | Verify `customizable_light_device` references are connected |
