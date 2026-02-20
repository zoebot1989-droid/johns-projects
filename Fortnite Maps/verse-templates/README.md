# 🎮 Verse Templates for Fortnite UEFN

Reusable, heavily-commented Verse code templates for building Fortnite maps in UEFN. Copy-paste ready with minimal modification.

---

## 📁 Templates

### 1. `tycoon-core.verse` — Tycoon Progression System
A complete tycoon framework with:
- **Currency system** — earn via button press or passive income timer
- **Tiered upgrades** — 5 configurable tiers with costs and unlock logic
- **Player progress tracking** — per-player currency, tier, and lifetime stats
- **Save/load stubs** — ready for UEFN persistence API integration

**Key classes:** `tycoon_core_device`, `player_progress`, `upgrade_tier`

**To customize:**
- Edit the `UpgradeTiers` array to define your progression
- Wire `EarnButton` and `UpgradeButton` to button_devices in your map
- Add unlock logic in `OnTierUnlocked()` (enable props, disable barriers, etc.)

---

### 2. `horror-mechanics.verse` — Horror Game Essentials
Four interconnected horror systems:

| System | Class | What it does |
|--------|-------|-------------|
| Flashlight | `flashlight_device` | Toggle on/off, battery drains over time, low-battery warning |
| Jumpscares | `jumpscare_device` | Trigger zone → audio + VFX + creature popup, cooldown support |
| Ambient Sound | `ambient_sound_controller` | Layered audio: base drone + tension layer + random one-shots |
| Darkness | `darkness_system` | Blackout events, gradual light extinction, fog control |

**To customize:**
- Place `trigger_device` volumes where you want jumpscares
- Wire `audio_player_device` references for all sound effects
- Adjust `DrainPerTick` on flashlight for difficulty tuning
- Call `ActivateTension()` / `TriggerBlackout()` from other systems

---

### 3. `leaderboard.verse` — Score & Time Tracking
- **Score tracking** — add/set/get points per player, plus kills & deaths
- **Time-based leaderboard** — start/stop timers, track best completion times
- **Sorted rankings** — automatic sorting by score (desc) or time (asc)
- **Display** — billboard devices for top ranks, personal HUD for each player

**Key methods:**
```
AddScore(Player, Points)    # Award points
StartTimer(Player)          # Begin time tracking
StopTimer(Player)           # End & record best time
GetRankings()               # Get sorted score leaderboard
GetTimeRankings()           # Get sorted time leaderboard
ResetAllScores()            # Clear between rounds
```

---

### 4. `game-manager.verse` — Round Management
Full game state machine:

```
LOBBY → COUNTDOWN → PLAYING → ROUND_END → LOBBY (or GAME_OVER)
```

- **Lobby phase** — waits for minimum players, auto-starts when ready
- **Countdown** — configurable countdown with audio beeps
- **Round timer** — automatic end or call `EndRound()` manually
- **Team assignment** — round-robin distribution across N teams
- **Multi-round support** — configurable max rounds with results between

**To customize:**
- Set `MinPlayersToStart`, `MaxRounds`, `NumberOfTeams`
- Add game logic in `StartRound()` and `EndRound()` comment blocks
- Wire teleporters for lobby ↔ arena transitions

---

### 5. `pickup-system.verse` — Item Collection & Inventory
Two-part system:

**`pickup_item_device`** — Place one per collectible in your map:
- Trigger zone collection with VFX and sound feedback
- Optional respawn timer
- Supports different item types (collectible, consumable, key item, currency)

**`pickup_manager_device`** — One per map, tracks everything:
- Per-player inventory (item → quantity)
- Completion tracking (X/Y items collected)
- Inventory queries: `HasItem()`, `GetItemCount()`, `UseItem()`
- Completion event when all items found

---

## 🚀 How to Use in UEFN

### Step 1: Create the Verse File
1. In UEFN, go to **Verse Explorer** (View → Verse Explorer)
2. Right-click your project → **Add new Verse file**
3. Copy-paste the template code into the new file
4. Save and **Build Verse Code** (Ctrl+Shift+B)

### Step 2: Place the Device
1. After successful build, your new device appears in the **Content Browser**
2. Drag it into your level
3. Select it and look at the **Details** panel

### Step 3: Wire Up References
1. In Details, you'll see all `@editable` properties
2. Click the dropdown for each and select the corresponding device in your map
3. Example: For `EarnButton`, select a `button_device` you've already placed

### Step 4: Configure
1. Adjust numeric values (`EarnAmount`, `MaxBattery`, etc.) in Details
2. Test in-editor with **Launch Session**

### Step 5: Combine Systems
These templates are designed to work together:
- `game-manager` starts a round → `leaderboard` begins tracking
- `pickup-system` awards points → calls `leaderboard.AddScore()`
- `horror-mechanics` blackout → triggered by `game-manager` round events
- `tycoon-core` currency → earned from `pickup-system` collections

---

## ✏️ Customization Tips

- **Search for `# ADD YOUR ... LOGIC HERE`** — these are the main extension points
- **All `@editable` properties** are configurable from the UEFN editor without code changes
- **Print() statements** help with debugging — remove them for production
- **Class inheritance** — extend any device class for specialized behavior
- **Event-driven** — subscribe to events rather than polling; it's the Verse way

## 📚 Resources

- [Epic's Verse Language Reference](https://dev.epicgames.com/documentation/en-us/uefn/verse-language-reference)
- [UEFN Verse API Reference](https://dev.epicgames.com/documentation/en-us/uefn/verse-api)
- [Verse Cookbook (Examples)](https://dev.epicgames.com/documentation/en-us/uefn/verse-cookbook-in-unreal-editor-for-fortnite)
- [UEFN Learning Path](https://dev.epicgames.com/community/fortnite/getting-started/uefn)

---

*Templates created for learning and rapid prototyping. Adapt freely for your maps!*
