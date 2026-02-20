# DEAD PROFIT — Complete UEFN Build Guide

> **"The park wants your money. The Entity wants your soul."**
>
> A step-by-step guide to building the DEAD PROFIT co-op horror tycoon map in Unreal Editor for Fortnite (UEFN). Written for beginners — every click explained.

---

## 📋 Table of Contents

1. [Prerequisites & Setup](#1-prerequisites--setup) (~30 min)
2. [Create Your UEFN Project](#2-create-your-uefn-project) (~10 min)
3. [Island Template & Settings](#3-island-template--settings) (~15 min)
4. [Terrain & Zone Layout](#4-terrain--zone-layout) (~2-3 hours)
5. [Build Zone: Park Entrance](#5-build-zone-park-entrance) (~45 min)
6. [Build Zone: Central Plaza / Hub](#6-build-zone-central-plaza--hub) (~1 hour)
7. [Build Zone: Kiddie Zone & Game Stalls](#7-build-zone-kiddie-zone--game-stalls) (~45 min)
8. [Build Zone: Food Court](#8-build-zone-food-court) (~30 min)
9. [Build Zone: Rides Area](#9-build-zone-rides-area) (~1.5 hours)
10. [Build Zone: Haunted House](#10-build-zone-haunted-house) (~1.5 hours)
11. [Build Zone: Water Rides](#11-build-zone-water-rides) (~45 min)
12. [Build Zone: Main Stage / Boss Arena](#12-build-zone-main-stage--boss-arena) (~1 hour)
13. [Build Zone: Underground Tunnels](#13-build-zone-underground-tunnels) (~1 hour)
14. [Build Zone: Perimeter Fence](#14-build-zone-perimeter-fence) (~45 min)
15. [Place Global Devices](#15-place-global-devices) (~1.5 hours)
16. [Import Verse Scripts](#16-import-verse-scripts) (~1 hour)
17. [Wire Devices to Verse Scripts](#17-wire-devices-to-verse-scripts) (~2 hours)
18. [Lighting Setup](#18-lighting-setup) (~1 hour)
19. [Audio Setup](#19-audio-setup) (~1 hour)
20. [Testing & Debugging](#20-testing--debugging) (~2-3 hours)
21. [Polish & Publishing](#21-polish--publishing) (~1-2 hours)

**Total estimated time: 20-30 hours** (spread over days/weeks)

---

## 1. Prerequisites & Setup
*⏱️ ~30 minutes*

### What You Need

1. **Epic Games Account** with Fortnite installed
2. **UEFN (Unreal Editor for Fortnite)** — Download from the Epic Games Launcher
   - Go to Epic Games Launcher → Library → UEFN → Install
   - Requires ~20 GB disk space
3. **A computer that can run UEFN** (min: 8GB RAM, dedicated GPU, SSD recommended)
4. **The DEAD PROFIT Verse files** (in the `verse/` folder alongside this guide)

### Install UEFN

1. Open **Epic Games Launcher**
2. Click **Library** in the left sidebar
3. Find **Unreal Editor for Fortnite** (or search for it in the Store)
4. Click **Install**
5. Wait for download and installation to complete
6. Launch UEFN — it will ask you to sign in with your Epic account

> **What you should see:** UEFN opens to a project browser showing template options and your recent projects.

---

## 2. Create Your UEFN Project
*⏱️ ~10 minutes*

1. Open UEFN
2. Click **"Create New Project"** (big blue button)
3. **Choose a template:** Select **"Blank"** template
   - ⚠️ Do NOT use the Tycoon template — we're building custom systems
   - The Blank template gives you an empty island to work with
4. **Name your project:** `DeadProfit`
5. **Choose save location:** Anywhere on your SSD
6. Click **"Create"**

> **What you should see:** UEFN opens with a large empty island. The terrain is flat green/brown. You see the standard UEFN editor with Viewport (center), Outliner (right), Details (right-bottom), Content Browser (bottom).

### First-Time Setup

1. **Save immediately:** Ctrl+S → name your level `DeadProfit_Main`
2. **Enable Verse:** Go to **Edit → Project Settings → Verse** and ensure Verse is enabled
3. **Set player count:** In the Outliner, find **Island Settings** → Details panel → set **Max Players** to `4`

---

## 3. Island Template & Settings
*⏱️ ~15 minutes*

### Island Settings

1. In the **Outliner** (right panel), find and click **"Island Settings"**
2. In the **Details** panel, set:
   - **Island Name:** `DEAD PROFIT`
   - **Island Description:** `Co-op Horror Tycoon — Build an amusement park by day, survive entities by night. 1-4 players.`
   - **Max Players:** `4`
   - **Player Spawn:** Choose a spawn location (we'll place spawn pads later)
   - **Time of Day:** `Day` (our Verse script will control this)
   - **Allow Building:** `Off` (players don't Fortnite-build; they use our tycoon system)
   - **Gravity:** `Normal`

### Team Settings

1. From the Content Browser, search for **"Team Settings and Inventory Device"**
2. Drag it into the level
3. In Details, set:
   - **Team Mode:** `Cooperative` (all players on same team)
   - **Number of Teams:** `1`
   - **Friendly Fire:** `Off`

> **What you should see:** A small device icon in your level. The Outliner shows "TeamSettingsDevice" listed.

---

## 4. Terrain & Zone Layout
*⏱️ ~2-3 hours*

This is the foundation. We'll sculpt the terrain to create distinct zones matching the map layout from the design doc.

### Overview Map (Reference)

```
┌─────────────────────────────────────────────────────┐
│                    PARK ENTRANCE                      │
│                   ┌───────────┐                       │
│                   │  TICKET   │                       │
│                   │  BOOTH    │                       │
│                   └───────────┘                       │
│         ┌─────────────┬─────────────┐                 │
│    KIDDIE ZONE    FOOD COURT    GAME STALLS           │
│         │             │             │                  │
│    FERRIS WHEEL   CENTRAL PLAZA  ROLLER COASTER       │
│                   (Hub/Shop)                           │
│         │             │             │                  │
│    HAUNTED HOUSE  MAIN STAGE    WATER RIDES           │
│    *Entity Spawn* (Boss Arena)                        │
│                                                       │
│         UNDERGROUND TUNNELS (below ground)            │
│                                                       │
│    ═══════════ PERIMETER FENCE ══════════             │
└─────────────────────────────────────────────────────┘
```

### Step 4.1: Sculpt the Terrain

1. Select the **Terrain Tool** from the top toolbar (mountain icon)
2. Choose **"Sculpt"** mode
3. **Create flat zones** for each area:
   - The map should be roughly **200m × 200m** total
   - Use the **Flatten** tool to create level platforms for each zone
   - Each zone needs a flat area of about **30m × 30m** minimum

4. **Terrain sculpting by zone:**

   **Park Entrance (North):**
   - Flat, slightly elevated entrance path (2-3m above base)
   - Wide walkway (10m) leading into the park
   - Slight downhill slope into the park interior

   **Central Plaza (Center):**
   - Large flat circular area (40m diameter)
   - This is the hub — slightly lower than entrance
   - Ensure clear sightlines to all connected zones

   **Kiddie Zone (Northwest):**
   - Flat platform, same level as Central Plaza
   - Connected by a 5m wide path

   **Food Court (North-Center):**
   - Flat area between Entrance and Central Plaza
   - Slightly elevated with steps down to plaza

   **Game Stalls (Northeast):**
   - Flat platform, mirror of Kiddie Zone
   - Connected by path to Central Plaza

   **Rides Area (West & East of Central Plaza):**
   - Two larger flat areas (50m × 30m each)
   - West: Ferris Wheel zone
   - East: Roller Coaster zone
   - Both at same elevation as Central Plaza

   **Haunted House (Southwest):**
   - Slightly lower than surrounding areas (creates ominous feel)
   - Small hill or mound for the house to sit on
   - Surrounded by slightly overgrown terrain

   **Water Rides (Southeast):**
   - Lower terrain with a carved channel for the log flume
   - Use the Sculpt tool to dig a shallow river/channel

   **Main Stage (South-Center):**
   - Large flat area (40m × 30m) for the boss arena
   - Slightly sunken like a natural amphitheater
   - Connected to Central Plaza by main path

   **Underground Tunnels (Below Main Stage):**
   - We'll build this using enclosed prefabs/props, not terrain
   - Mark where the entrance will be (near Haunted House)

> **What you should see:** From a top-down view, you can see distinct flat areas connected by paths. The terrain has gentle slopes between zones but each zone is clearly defined.

### Step 4.2: Paint the Terrain

1. Switch to **Paint** mode in the Terrain Tool
2. Apply materials:
   - **Paths:** Use a cobblestone/concrete texture
   - **Park zones:** Green grass
   - **Haunted House area:** Dark dirt/dead grass
   - **Water Rides area:** Sandy/muddy near the water channel
   - **Perimeter:** Dirt/gravel

### Step 4.3: Place Path Markers

1. Use **Cube** primitives (Modes panel → Place → Basic → Cube) scaled thin and flat
2. Place them along pathways between zones to visualize the flow
3. These are temporary guides — replace with actual path props later

> **Checkpoint:** Your terrain should now look like a rough amusement park layout viewed from above. Save your project (Ctrl+S).

---

## 5. Build Zone: Park Entrance
*⏱️ ~45 minutes*

### Step 5.1: Place the Entrance Arch

1. Open **Content Browser** (bottom panel)
2. Search for `"entrance"` or `"arch"` in the Fortnite content
3. Drag an entrance arch prop to the north edge of your map
4. Position it at the start of the main path
5. Scale if needed (press R to enter scale mode)

> **If no arch prop exists:** Build one using two tall column props + a horizontal beam across the top. Add a sign prop above.

### Step 5.2: Ticket Booth

1. Search Content Browser for `"booth"` or `"shack"`
2. Place a small booth structure just inside the entrance
3. This is decorative — the actual game start is handled by our Verse device

### Step 5.3: Decorations

1. Line the entrance path with:
   - **6 banner props** (search `"banner"` or `"flag"`)
   - **4 balloon clusters** (search `"balloon"`)
   - **6 lampposts** (search `"lamp"` or `"light post"`) — evenly spaced
   - **4 park benches** (search `"bench"`) — 2 per side of path
   - **4 trash cans** (search `"trash"` or `"bin"`) — ⚠️ Some of these will be Mimic spawn points!

2. Place **3 directional sign props** at the path split:
   - "→ RIDES" pointing right
   - "← KIDDIE ZONE" pointing left
   - "↓ FOOD COURT" pointing forward

### Step 5.4: Player Spawns

1. Search Content Browser for **"Player Spawn Pad"**
2. Drag 3 spawn pads just inside the entrance
3. Space them 3m apart so players don't spawn on top of each other
4. In Details for each: set **Team** to `Team 1`

### Step 5.5: Fence

1. Search for `"fence"` props
2. Line both sides of the entrance path to channel players inward
3. 10 fence segments should suffice

> **What you should see:** A welcoming park entrance with an arch, ticket booth, decorations lining a path that splits into three directions. Three spawn pads visible on the ground.

---

## 6. Build Zone: Central Plaza / Hub
*⏱️ ~1 hour*

This is the most important zone — it's where players shop, regroup, and see the overall park status.

### Step 6.1: Center Fountain

1. Search `"fountain"` in Content Browser
2. Place one fountain prop at the exact center of the plaza
3. This is the visual landmark players navigate by

### Step 6.2: Survival Shop

1. Place a **market stall** or **wooden shack** prop on the west side of the plaza
2. This is the Survival Shop where players buy nighttime tools
3. Place **4 Button Devices** in a row in front of the shop:
   - Button 1: "Buy Barricade (30 Tickets)"
   - Button 2: "Buy Noise Maker (20 Tickets)"
   - Button 3: "Buy Emergency Flare (75 Tickets)"
   - Button 4: "Buy Battery Refill (15 Tickets)"
4. For each Button Device, in the Details panel:
   - Set **Interaction Text** to the appropriate label
   - Set **Visible During Phase** to `All` (we'll control availability via Verse)

### Step 6.3: Shop Price Billboard

1. Search for **"Billboard Device"** in Content Browser
2. Place one billboard next to the Survival Shop
3. This will display prices — connected to UIManager Verse device later

### Step 6.4: Economy Stats Billboard

1. Place a second **Billboard Device** on the east side of the plaza
2. This shows team economy stats (total earned/spent)

### Step 6.5: Decorations

1. **8 lampposts** around the plaza perimeter (evenly spaced)
2. **6 park benches** for ambiance
3. **4 barrel props** near buildings (hiding spots for Mimics)
4. **6 crate props** scattered as decoration
5. **Vendor cart props** (2) near the shop area

### Step 6.6: Map Indicator

1. Search for **"Map Indicator Device"**
2. Place one at the center of the plaza
3. In Details: set the icon and label to "Central Plaza / Shop"
4. Set **Enabled At Game Start** to `True`

### Step 6.7: Zone Barriers

1. Place **2 Barrier Devices** at the paths leading to:
   - Haunted House area (Tier 3 — unlocked Night 3)
   - Underground Tunnels entrance (unlocked Night 4)
2. In Details for each: set **Enabled At Game Start** to `True` (blocks path initially)
3. Our Progression Verse script will disable these at the right times

> **What you should see:** A circular plaza with a fountain in the center, a shop stall with 4 interaction buttons, billboards, lampposts around the edge, and paths leading out to all other zones. Two paths are blocked by blue barrier walls.

---

## 7. Build Zone: Kiddie Zone & Game Stalls
*⏱️ ~45 minutes*

### Kiddie Zone (Northwest)

1. Place a **colorful tent prop** or canopy as the zone centerpiece
2. Place a **carousel/merry-go-round prop** (this is the Kiddie Train attraction visual)
   - Initially hidden using a **Prop Mover Device** — set to start position OFF
3. Place **2 Button Devices** for build/upgrade interactions
4. Place **2 Billboard Devices** for attraction status
5. Place **2 Prop Mover Devices** (one per attraction) — these reveal the attraction when built
6. Decorate with balloon animals, small fences, colorful props
7. Place **4 small lampposts**
8. Place **1 Guard Spawner Device** at the edge — Wanderer spawn point

### Game Stalls (Northeast)

1. Build 2 carnival booths from booth/counter props
2. Add target props and prize display props
3. Place **1 Button Device** for the Balloon Dart Booth
4. Place **1 Billboard Device** for status
5. Place **1 Prop Mover Device** to reveal the built booth
6. Add string lights and carnival signs

> **What you should see:** Two charming mini-zones. Kiddie Zone has a tent/carousel area with colorful decorations. Game Stalls has carnival booths with prizes hanging. Both have "build here" buttons visible.

---

## 8. Build Zone: Food Court
*⏱️ ~30 minutes*

1. Place a **food truck prop** as the main visual
2. Place **3 vendor cart props** (cotton candy, hot dogs, drinks)
3. Place **4 picnic tables** with **4 patio umbrellas** over them
4. Place **3 trash cans** (Mimic hiding spots!)
5. Add menu board props and string lights
6. Place **2 Button Devices** (Cotton Candy Stand, Food Court)
7. Place **2 Billboard Devices** for status
8. Place **2 Prop Mover Devices**
9. Place a **Healing Device** or **Campfire Device** — active during Day for player healing
10. Add an ice cream sign for flair

> **What you should see:** A cozy outdoor food court with colorful carts, picnic tables with umbrellas, and a warm atmosphere. Healing device glows in the center.

---

## 9. Build Zone: Rides Area
*⏱️ ~1.5 hours*

This is the big one — the main income-generating zone.

### Ferris Wheel (West)

1. **Build the Ferris Wheel** from props:
   - Use circular/ring structures or large prop pieces
   - Alternatively, search for any large wheel/circular prop
   - If no wheel prop exists, use a tall scaffolding structure with gondola props
2. Place it on the western flat zone, make it TALL (visible from everywhere)
3. Add **metal railing props** (6) for queue lines
4. Add **queue line rope props** (4)
5. Place **1 Button Device** for build/upgrade
6. Place **1 Billboard Device** for status
7. Place **1 Prop Mover Device** to reveal when built

### Roller Coaster (East)

1. **Build the Roller Coaster** from track segments:
   - Search for roller coaster or rail/track props
   - Alternatively, use metal railing props arranged in a looping path
   - Build a lift hill (elevated ramp) and a couple of curves
2. Place on the eastern flat zone
3. Add the same queue line props
4. Add **neon sign props** ("DEATH COASTER" or similar)
5. Place devices: **1 Button, 1 Billboard, 1 Prop Mover**

### Bumper Cars (Between the two)

1. Create a flat arena using floor props
2. Place **4 bumper car props** (or small vehicle props)
3. Surround with metal railings
4. Place devices: **1 Button, 1 Billboard, 1 Prop Mover**

### Entity Spawn Points (Rides Area)

1. Place **2 Guard Spawner Devices** at the edges of the Rides Area
   - One near the Ferris Wheel
   - One near the Roller Coaster
2. Place **1 Creature Spawner Device** for the Conductor entity
3. Place **1 Damage Volume Device** near rides — this is the "possessed ride" damage zone
4. Place **2 Trigger Devices** for Conductor detection zones

> **What you should see:** Two impressive ride structures dominating the horizon. Metal railings form queue lines. A bumper car arena sits between them. Guard spawner icons visible at edges.

---

## 10. Build Zone: Haunted House
*⏱️ ~1.5 hours*

The creepiest zone — primary entity spawn AND highest-income attraction.

### Step 10.1: Main Structure

1. Search for **haunted house**, **abandoned house**, or **spooky** prefabs
2. Place the main structure on the slightly lower/mounded terrain in the southwest
3. If no prefab exists, build from scratch:
   - Use wooden wall/floor props to create a 2-story building
   - Break some windows (use broken window props)
   - Add a porch with sagging steps

### Step 10.2: Interior

1. Go inside the structure and add:
   - **Cobweb props** (8) in corners and doorways
   - **Dusty furniture** (chairs, tables) scattered around
   - **Candelabra props** (4) for dim light sources
   - **Old painting props** (3) — these contain lore
   - **Coffin props** (2) — jumpscare sources
   - **Ripped curtain props** (4) — block sightlines, add tension
   - **Old clock prop** (1) — lore item
   - **Ghost portrait props** (2) — creepy decoration

### Step 10.3: Entity Spawners

1. Place **3 Guard Spawner Devices** inside/around the Haunted House:
   - 1 inside (Wanderer spawn)
   - 2 around the exterior (Mimic spawns)
2. These are the PRIMARY entity spawn points

### Step 10.4: Jumpscare Triggers

1. Place **4 Trigger Devices** in the hallways/doorways
2. Wire them to **Audio Player Devices** with scare stinger sounds
3. Place **VFX Spawner Devices** (2) for ghost effects

### Step 10.5: Hiding Spots

1. Place **2 sets** of hiding spots (locker/wardrobe props):
   - Each needs: 1 large prop (locker), 1 **Button Device** (interact to enter/exit), 1 **Trigger Device** (detection zone)
   - Place inside rooms with doors that can be closed

### Step 10.6: Lighting

1. Place **4 Light Devices** inside:
   - Set to dim, warm color (candle orange)
   - These will be controlled for blackout events
2. The exterior should be darker than other zones

### Step 10.7: Attraction Build Point

1. Place **1 Button Device** outside the entrance for building/upgrading the attraction
2. Place **1 Billboard Device** for status
3. Place **1 Prop Mover Device** — controls the "Haunted House Ride" reveal

> **What you should see:** A creepy, deteriorating building on a small mound. Inside is dark with cobwebs, broken furniture, and dim candles. Multiple trigger zones and spawners are placed but invisible to players.

---

## 11. Build Zone: Water Rides
*⏱️ ~45 minutes*

1. **Carve a water channel** using terrain tools or prop pieces
2. Place **2 log boat props** in the channel
3. Add a **waterfall VFX** at the splash zone
4. Place **2 wooden bridges** crossing the channel
5. Add **tropical plants** (6) and **rock props** (8) along the banks
6. Add **wooden signs** ("Raging Rapids")
7. Place devices: **1 Button, 1 Billboard, 1 Prop Mover**
8. Place **1 Guard Spawner Device** at the edge

> **What you should see:** A winding water channel with log boats, lush plants, and a small waterfall. Bridges cross over the water.

---

## 12. Build Zone: Main Stage / Boss Arena
*⏱️ ~1 hour*

### Step 12.1: The Stage

1. Place a **large platform prop** as the stage (10m × 8m, elevated 1.5m)
2. Add **speaker stack props** (4) at the corners
3. Add **spotlight props** (4) — wire to **Light Devices** for controllable lighting
4. Place **curtain props** (2) as backdrop
5. Add **audience seating** (bleachers or rows of chairs) in front

### Step 12.2: Boss Arena Setup

1. This area doubles as the Night 5 boss arena
2. Place **1 Guard Spawner Device** behind the stage — The Owner spawn point
3. Place **3 Teleporter Devices** around the arena — Owner teleport destinations
4. Place **2 Damage Volume Devices** — Boss attack zones
5. Place **2 Trigger Devices** — Arena boundary triggers
6. Place **1 VFX Spawner Device** — Corruption effect
7. Place **banner props** (4) with "MALMOUTH FUNLAND" text

### Step 12.3: Attraction

1. Place devices: **1 Button, 1 Billboard, 1 Prop Mover** for the Main Stage attraction

> **What you should see:** An impressive concert-style stage with speakers and spotlights, facing an audience area. Behind the stage, invisible boss-fight devices are placed.

---

## 13. Build Zone: Underground Tunnels
*⏱️ ~1 hour*

### Step 13.1: Entrance

1. Find the tunnel entrance location (near Haunted House, south side)
2. Place a **staircase prop** leading down
3. Place a **Barrier Device** at the entrance — enabled at start, disabled Night 4
4. Place a **Prop Mover Device** to reveal/animate the entrance opening

### Step 13.2: Tunnel Construction

1. Use **concrete tunnel** or **sewer pipe** props to build enclosed corridors
2. Create a layout:
   - Main corridor (straight, 30m)
   - Left branch (15m) — leads to lore room
   - Right branch (15m) — leads to loot room
   - Dead end with emergency hiding spot
3. Keep corridors narrow (3m wide, 3m tall) for claustrophobia

### Step 13.3: Atmosphere

1. Place **rusty pipe props** (6) on walls
2. Add **dripping water VFX** (3) from ceiling
3. Place **emergency light props** (4) with **Light Devices** — red, dim
4. Add **broken electrical panel props** (2)

### Step 13.4: Lore Items

1. Place **filing cabinet props** (2), **newspaper clipping props** (4), **old photo props** (3)
2. Place **3 Trigger Devices** near lore items — trigger lore pickup events
3. Place **2 Item Granter Devices** in the loot room — rare blueprints and special tools

### Step 13.5: Secret Area Defenses

1. Place **1 Guard Spawner Device** — entities can follow players down here
2. Place **1 Hiding Spot** (Button + Trigger) — emergency shelter
3. Place **Audio Player Devices** (2) — tunnel ambience, dripping water

> **What you should see:** A dark, claustrophobic underground tunnel system with red emergency lighting, rusty pipes, and scattered documents/photos. A barrier blocks the entrance staircase.

---

## 14. Build Zone: Perimeter Fence
*⏱️ ~45 minutes*

### Step 14.1: Build the Fence

1. Use **chain link fence props** to encircle the entire park
2. You'll need **20+ fence segments** depending on your map size
3. Add **barbed wire props** along the top

### Step 14.2: Breach Points (×4)

1. Create **4 gaps** in the fence at North, South, East, West
2. At each gap, place:
   - **Broken fence segment props** (looks like something broke through)
   - **Warning sign props** ("DANGER" / "KEEP OUT")
   - **Sandbag props** for fortification ambiance
   - **1 Barrier Device** — barricade slot (player-placed)
   - **1 Guard Spawner Device** — Hollow Kid breach spawn
   - **1 Trigger Device** — breach detection
   - **1 Button Device** — barricade placement point
3. Add **floodlight props** at each breach point (wire to Light Devices)

### Step 14.3: Audio

1. Place **2 Audio Player Devices** near breach points
2. Set to fence rattling / breach alarm sounds

> **What you should see:** A chain link fence surrounding the entire park with barbed wire on top. Four obvious breach points have broken fencing, warning signs, and sandbags. Barrier devices glow blue at each breach.

---

## 15. Place Global Devices
*⏱️ ~1.5 hours*

These devices aren't tied to a specific zone. Place them in a hidden area (under the map or behind a wall players can't access).

### Step 15.1: Timer Devices (8-10)

Search for **"Timer Device"** in the Content Browser. Place and configure:

| Timer | Duration | Repeat? | Purpose |
|---|---|---|---|
| DayTimer | 180s | No | Day phase |
| DuskTimer | 30s | No | Dusk phase |
| NightTimer | 120s | No | Night phase |
| DawnTimer | 15s | No | Dawn phase |
| IncomeTimer | 10s | Yes | Park income ticks |
| AITickTimer | 1s | Yes | Entity AI processing |
| BatteryDrainTimer | 1s | Yes | Flashlight battery |
| ProximityCheckTimer | 0.5s | Yes | Entity proximity |
| NoiseMakerDurationTimer | 8s | No | Noise maker lifetime |
| FlareDurationTimer | 5s | No | Flare lifetime |

For each: drag from Content Browser, place, and set **Duration** and **Repeat** in Details.

### Step 15.2: HUD Message Devices (12-15)

Search for **"HUD Message Device"**. Place one for each HUD element:

1. CurrencyHUD
2. PhaseTimerHUD
3. ParkRatingHUD
4. AnnouncementHUD
5. ProximityWarningHUD
6. ToolBarHUD
7. NightProgressHUD
8. MinimapHUD
9. LobbyHUD
10. FlashlightBatteryHUD
11. UnlockHUD
12. GameStateHUD

For each, set the **Position** in Details to the appropriate screen location (top-left, center, bottom, etc.).

### Step 15.3: Audio Player Devices (25-30)

Place one **Audio Player Device** for each sound listed in the ASSETS-LIST.md. For each:
1. In Details, set the **Audio** to the appropriate sound
2. Set **Play Mode** (Once, Loop)
3. Set **Volume** and **Attenuation** (how far the sound carries)

> **Naming tip:** Rename each device in the Outliner! Right-click → Rename. Name them `Audio_DayAmbience`, `Audio_NightAmbience`, etc. This makes wiring to Verse MUCH easier.

### Step 15.4: Remaining Global Devices

Place the following (1 each unless noted):
- **Elimination Manager Device** — tracks player deaths
- **Score Manager Device** — tracks scores
- **Lobby Timer Device** — 10s countdown for game start
- **Lobby→Game Teleporter** — at lobby spawn
- **Game→Lobby Teleporter** — for post-game
- **Start Button Device** — in lobby for manual start
- **Reset Button Device** — hidden (for testing only)

> **What you should see:** A cluttered area of device icons off to the side of your map. Each is named clearly in the Outliner.

---

## 16. Import Verse Scripts
*⏱️ ~1 hour*

### Step 16.1: Open the Verse Explorer

1. In UEFN, go to **Verse → Verse Explorer** (top menu)
2. You'll see your project's Verse source folder

### Step 16.2: Create the Verse Files

1. In the Verse Explorer, **right-click** your project folder
2. Select **"New Verse File"**
3. Create each file (one at a time):

| File to Create | Device Class Name |
|---|---|
| `day_night_cycle.verse` | `day_night_cycle_device` |
| `park_manager.verse` | `park_manager_device` |
| `entity_ai.verse` | `entity_ai_device` |
| `survival_tools.verse` | `survival_tools_device` |
| `economy.verse` | `economy_device` |
| `progression.verse` | `progression_device` |
| `ui_manager.verse` | `ui_manager_device` |
| `main_game.verse` | `main_game_device` |

4. For each file:
   - Open the corresponding `.verse` file from the `verse/` folder in this project
   - Copy the ENTIRE contents
   - Paste into the UEFN Verse editor
   - Save (Ctrl+S)

### Step 16.3: Build the Verse Code

1. Go to **Verse → Build Verse Code** (or press Ctrl+Shift+B)
2. Watch the Build Output panel at the bottom
3. **If errors appear:**
   - Read the error message carefully — it tells you the line number
   - Common issues:
     - Missing `using` statements at the top
     - Typos in device type names
     - Indentation errors (Verse is indentation-sensitive!)
   - Fix errors and rebuild
4. **Successful build:** You'll see "Build Succeeded" in green

### Step 16.4: Place Verse Devices in the Level

After a successful build, your custom devices appear in the Content Browser:

1. Search for `"main_game_device"` in Content Browser
2. Drag it into the level (place it in the hidden device area)
3. Repeat for all 8 Verse devices
4. You should now see 8 custom device icons in your level

> **What you should see:** The Verse Explorer shows 8 .verse files. The Content Browser shows 8 corresponding device classes. 8 device instances are placed in your level.

---

## 17. Wire Devices to Verse Scripts
*⏱️ ~2 hours*

This is the most critical step. Each Verse device has `@editable` properties that must be wired to the physical devices in your level.

### How to Wire

1. **Select** a Verse device in the level (click it in Viewport or Outliner)
2. Look at the **Details panel** on the right
3. You'll see all the `@editable` properties listed with dropdowns
4. For each property, click the **dropdown** and select the corresponding device from your level
5. If you named your devices clearly (Step 15.3 tip), this is easy

### Wire: main_game_device

Select `main_game_device` in the Outliner. In Details, wire:

| Property | Wire To |
|---|---|
| DayNightCycle | `day_night_cycle_device` instance |
| ParkManager | `park_manager_device` instance |
| EntityAI | `entity_ai_device` instance |
| SurvivalTools | `survival_tools_device` instance |
| Economy | `economy_device` instance |
| Progression | `progression_device` instance |
| UIManager | `ui_manager_device` instance |
| LobbyTimer | Timer device (10s, named "LobbyTimer") |
| LobbyToGameTeleporter | Lobby→Game teleporter |
| GameToLobbyTeleporter | Game→Lobby teleporter |
| StartButton | Start button in lobby |
| ResetButton | Reset button (hidden) |
| IntroMusic | Audio: Intro music |
| VictoryMusic | Audio: Victory music |
| GameOverMusic | Audio: Game over music |
| LobbyHUD | HUD: Lobby display |

### Wire: day_night_cycle_device

| Property | Wire To |
|---|---|
| DayTimer | Timer: 180s (Day) |
| DuskTimer | Timer: 30s (Dusk) |
| NightTimer | Timer: 120s (Night) |
| DawnTimer | Timer: 15s (Dawn) |
| SunLight | Main directional light ("Sun") |
| MoonLight | Moon light device |
| AmbientLights | Array: All 20+ park lamppost lights |
| NightFog | Fog device |
| DayAmbience | Audio: Day park ambience |
| DuskSiren | Audio: Warning siren |
| NightAmbience | Audio: Night ambience |
| DawnSound | Audio: Dawn relief |
| PhaseHUD | HUD: Phase display |
| CountdownHUD | HUD: Countdown timer |
| EntitySpawners | Array: All creature spawner devices |

### Wire: park_manager_device

| Property | Wire To |
|---|---|
| AttractionButtons | Array: All 10 attraction build buttons (in order matching templates) |
| AttractionPropMovers | Array: All 10 prop movers (matching order) |
| AttractionDisplays | Array: All 10 attraction billboards (matching order) |
| IncomeTimer | Timer: 10s repeating (Income) |
| ParkStatsHUD | HUD: Park rating |
| IncomeSound | Audio: Cha-ching |
| BuildSound | Audio: Construction |
| DamageSound | Audio: Damage |
| RepairButtons | Array: Repair buttons (can reuse build buttons) |

### Wire: entity_ai_device

| Property | Wire To |
|---|---|
| WandererSpawners | Array: Guard spawners at Haunted House, Kiddie Zone, etc. |
| MimicSpawners | Array: Guard spawners near trash cans/benches |
| ConductorSpawners | Array: Guard spawner in Rides Area |
| HollowKidSpawners | Array: Guard spawners at perimeter breach points |
| OwnerSpawner | Guard spawner behind Main Stage |
| WandererWaypoints | Array: Prop manipulators along patrol routes |
| HollowKidWaypoints | Array: Prop manipulators along breach rush routes |
| OwnerTeleportPoints | Array: Teleporter devices around boss arena |
| AITickTimer | Timer: 1s repeating |
| DetectionTriggers | Array: All trigger devices near spawners |
| DamageDevices | Array: Damage volume devices |
| (All audio properties) | Corresponding audio player devices |
| (All VFX properties) | Corresponding VFX spawner devices |

### Wire: survival_tools_device

Wire all tool-related buttons, lights, audio, timers, barriers, and triggers as listed in the `@editable` properties. Match each to the device you placed.

### Wire: economy_device

| Property | Wire To |
|---|---|
| CurrencyHUD | HUD: Currency display |
| EarnSound | Audio: Cha-ching |
| SpendSound | Audio: Cash register |
| InsufficientFundsSound | Audio: Error buzz |
| EconomyStatsDisplay | Billboard: Economy stats |

### Wire: progression_device

| Property | Wire To |
|---|---|
| ProgressionHUD | HUD: Progression display |
| UnlockHUD | HUD: Unlock notifications |
| NightAnnouncementHUD | HUD: Night announcement |
| SecretAreaBarrier | Barrier at tunnel entrance |
| SecretEntranceRevealer | Prop mover at tunnel entrance |
| Tier3ZoneBarriers | Array: Barriers blocking Tier 3 zones |
| ParkLights | Array: All controllable park lights |
| (Audio properties) | Unlock jingle, night announcement, victory, game over sounds |
| (Blackout audio) | Blackout and restore sounds |

### Wire: ui_manager_device

Wire all 12+ HUD Message Devices, Map Indicator Devices, Billboard Devices, and Audio Players as listed in the `@editable` properties.

> **⚠️ CRITICAL:** The order of arrays matters! The first element in `AttractionButtons` must correspond to the first attraction template in `park_manager.verse` (Balloon Dart Booth). Double-check the order.

> **What you should see:** Every `@editable` property in every Verse device's Details panel has a device wired to it (no empty/null references).

---

## 18. Lighting Setup
*⏱️ ~1 hour*

### Step 18.1: Sun (Directional Light)

1. Find the **Directional Light** in your level (or add one: Place → Lights → Directional Light)
2. This is the "sun"
3. Settings:
   - **Intensity:** 5.0 (bright daytime)
   - **Color:** Warm white (RGB: 255, 244, 229)
   - **Rotation:** Angle it to cast natural afternoon shadows
4. Wire this to `DayNightCycle.SunLight`

### Step 18.2: Moon Light

1. Add a second **Directional Light**
2. Settings:
   - **Intensity:** 0.5 (dim)
   - **Color:** Cool blue (RGB: 100, 120, 180)
   - **Rotation:** Opposite of sun
   - **Enabled:** False (starts disabled — DayNightCycle turns it on at night)
3. Wire to `DayNightCycle.MoonLight`

### Step 18.3: Park Lights (Lampposts)

1. For each lamppost prop, add a **Point Light** or **Light Device** nearby
2. Settings:
   - **Intensity:** 2.0
   - **Color:** Warm yellow (RGB: 255, 200, 100)
   - **Attenuation Radius:** 500-800 (depending on spacing)
3. Add all of these to the `DayNightCycle.AmbientLights` array and `Progression.ParkLights` array

### Step 18.4: Haunted House Interior

1. Use dim **Point Lights** with orange/red color
2. Keep intensity low (0.5-1.0)
3. Add these to the controllable lights arrays

### Step 18.5: Underground Tunnels

1. Use **Point Lights** with red color (emergency lighting)
2. Very low intensity (0.3)

### Step 18.6: Fog

1. Place a **Fog Device** (or use Exponential Height Fog in UEFN)
2. Settings:
   - Start disabled (DayNightCycle enables during Night)
   - **Density:** Medium-high for creepy atmosphere
   - **Color:** Dark gray/blue

> **What you should see:** In play mode, daytime is bright and cheerful with warm lighting. Toggle to night mode: the sun disappears, a dim blue moon light takes over, most lampposts go dark, and fog rolls in.

---

## 19. Audio Setup
*⏱️ ~1 hour*

### Sound Design Priority

Audio is **80% of the horror atmosphere**. Get this right.

### Day Phase Sounds
- **DayAmbience:** Loop — cheerful park music, crowd chatter, ride sounds, birds
- **IncomeSound:** One-shot — cash register "cha-ching"
- **BuildSound:** One-shot — construction hammering/sawing

### Dusk Phase Sounds
- **DuskSiren:** One-shot — air raid siren or emergency alert
- The light flicker should have an electrical buzz sound

### Night Phase Sounds
- **NightAmbience:** Loop — wind, distant creaks, faint whispers, occasional footsteps
- **WandererAudio:** Loop — heavy footsteps, groaning
- **MimicRevealAudio:** One-shot — sudden loud crash + screech
- **ConductorAudio:** Loop — grinding metal, electrical sparks
- **HollowKidAudio:** Loop — children's laughter (distorted), rapid footsteps
- **OwnerAudio:** Loop — deep bass rumble, distorted carnival music
- **ProximityHeartbeat:** Loop — heartbeat that speeds up
- **StunSound:** One-shot — bright flash/electric zap

### Dawn Phase Sounds
- **DawnSound:** One-shot — birds chirping, triumphant orchestral sting

### UI Sounds
- **PurchaseSound:** One-shot — coin clink
- **InsufficientFundsSound:** One-shot — error buzz
- **UnlockSound:** One-shot — achievement jingle
- **TimerTickSound:** One-shot — clock tick (urgent)

### How to Set Up Audio

1. For each Audio Player Device, open Details
2. Set the **Audio Clip** — use UEFN's built-in sound library or import custom sounds
3. Set **Volume** (0.0 to 1.0) — ambient sounds should be 0.3-0.5, scares should be 0.8-1.0
4. Set **Play Mode** — "Once" for stingers, "Loop" for ambience
5. Set **Spatialization** — "2D" for HUD/global sounds, "3D" for world-positioned sounds

> **Tip:** For horror sounds, search UEFN's audio library for "horror", "scary", "ambient", "tension". Layer multiple quiet sounds for depth rather than one loud sound.

---

## 20. Testing & Debugging
*⏱️ ~2-3 hours*

### Step 20.1: First Launch

1. Press **the Play button** (green ▶️) in UEFN's toolbar
2. Select **"Launch Session"** → your Fortnite client will open
3. You'll load into your map

### Step 20.2: Testing Checklist

#### Phase 1: Lobby & Start
- [ ] Player spawns in lobby
- [ ] Lobby HUD shows "Waiting for players"
- [ ] Start button works (force-starts game)
- [ ] Player teleports to park entrance
- [ ] Intro announcement shows

#### Phase 2: Day Phase
- [ ] Day timer starts counting down
- [ ] Phase HUD shows "☀️ DAY"
- [ ] Currency display shows starting Tickets (100)
- [ ] Can interact with build buttons
- [ ] Building an attraction: deducts Tickets
- [ ] Prop mover reveals the attraction visual
- [ ] Billboard updates with attraction status
- [ ] Income timer ticks and adds Tickets
- [ ] Park rating updates as you build
- [ ] Shop buttons work (buy survival tools)

#### Phase 3: Dusk Phase
- [ ] Dusk siren plays
- [ ] Lights flicker
- [ ] Phase HUD changes to "🌅 DUSK"
- [ ] Income generation stops

#### Phase 4: Night Phase
- [ ] Fog rolls in, lighting changes to night
- [ ] Entity spawners activate
- [ ] Guard AI entities appear and move
- [ ] Phase HUD shows "🌙 NIGHT 1"
- [ ] Tool bar HUD appears (flashlight, barricades, etc.)
- [ ] Flashlight toggle works (light on/off, battery drains)
- [ ] Barricade placement works (barrier enables)
- [ ] Proximity warning triggers when near entities
- [ ] Entities damage attractions (check billboard updates)

#### Phase 5: Dawn Phase
- [ ] Phase HUD shows "🌄 DAWN"
- [ ] Entities despawn
- [ ] Fog clears, lights return
- [ ] Night survival bonus Tickets granted
- [ ] Score screen displays

#### Phase 6: Progression (Nights 2-5)
- [ ] Night 2: Mimics spawn
- [ ] Night 3: Conductor spawns, power outage occurs, Tier 3 unlocks
- [ ] Night 4: Hollow Kids spawn, secret tunnels unlock
- [ ] Night 5: The Owner spawns
- [ ] Game over if all players die
- [ ] Victory if Night 5 survived

### Step 20.3: Common Issues & Fixes

| Issue | Likely Cause | Fix |
|---|---|---|
| Verse compilation errors | Syntax error in .verse file | Check Build Output for line numbers |
| Device not responding | Not wired in Details panel | Select Verse device, check @editable properties |
| Timer not firing | Wrong duration or not set to repeat | Check timer device Details |
| Entities don't spawn | Spawner not wired or not enabled | Check EntitySpawners array in DayNightCycle |
| HUD not showing | HUD device not wired or not Show()-ed | Check UIManager wiring |
| Lights not changing | Light devices not in AmbientLights array | Re-wire the array |
| No income generating | IncomeTimer not wired or not started | Check ParkManager wiring |
| Barriers won't disable | Wrong barrier device wired to Progression | Double-check barrier references |

### Step 20.4: Verse Debugging

1. Add `Print()` statements in your Verse code (already included)
2. Open the **Output Log** in UEFN (Window → Output Log)
3. Filter for "Print" to see your debug messages
4. Each system logs its state changes — use these to trace issues

---

## 21. Polish & Publishing
*⏱️ ~1-2 hours*

### Step 21.1: Visual Polish

1. **Add foliage:** Trees and bushes around the park perimeter
2. **Ground scatter:** Small rocks, leaves, trash near fence areas
3. **Skybox:** Set an appropriate sky — bright for day, moody for night
4. **Post-processing:** Add slight vignetting for night phase
5. **Color grading:** Desaturate slightly during Dusk and Night

### Step 21.2: Balance Pass

Test and adjust these values:
- Starting Tickets (100 might be too much or too little)
- Attraction costs vs. income rates
- Night duration (too long = boring, too short = not scary)
- Entity damage values
- Battery drain rate
- Tool costs

### Step 21.3: Create Thumbnail & Description

1. Take a dramatic screenshot of your park at night with fog
2. Use it as the island thumbnail
3. Write a compelling description:

> **DEAD PROFIT** — 1-4 Players Co-op
> 
> Build an abandoned amusement park by day. Survive the entities by night.
> 
> ☀️ DAY: Build rides, earn Tickets, upgrade attractions
> 🌙 NIGHT: Entities attack! Use flashlights, barricades, and flares to survive
> 
> 5 Nights. Each harder than the last. Can you survive The Owner on Night 5?
> 
> "The park wants your money. The Entity wants your soul."

### Step 21.4: Publish

1. Go to **File → Publish to Fortnite**
2. Fill in all required fields (title, description, tags, thumbnail)
3. Set **Max Players** to 4
4. Add tags: `Horror`, `Tycoon`, `Co-op`, `PvE`, `Survival`
5. Submit for review
6. Wait for approval (usually 24-48 hours)

### Step 21.5: Share & Promote

1. Get your **Island Code** after publishing
2. Share on social media with the hashtag **#DeadProfit**
3. Create a short trailer showing day/night gameplay loop
4. Post clips of jumpscare moments and clutch survivals

---

## 🎉 Congratulations!

You've built DEAD PROFIT — a complete co-op horror tycoon in Fortnite Creative.

### Post-Launch Roadmap (from design doc)

- **Update 1 (Week 2):** New entity type + new attraction
- **Update 2 (Month 1):** "Nightmare Mode" — harder, randomized layout
- **Update 3 (Month 2):** Water Park expansion zone
- **Seasonal:** Holiday events (Halloween = Krampus Night, etc.)

### Files Reference

| File | Purpose |
|---|---|
| `verse/main-game.verse` | Master game controller |
| `verse/day-night-cycle.verse` | Phase management & lighting |
| `verse/park-manager.verse` | Attraction building & income |
| `verse/entity-ai.verse` | Entity spawning & behavior |
| `verse/survival-tools.verse` | Player tools & shop |
| `verse/economy.verse` | Currency system |
| `verse/progression.verse` | 5-night difficulty scaling |
| `verse/ui-manager.verse` | HUD management |
| `ASSETS-LIST.md` | Every prop & device needed |
| `BUILD-GUIDE.md` | This guide |

Good luck, and remember: **The park wants your money. The Entity wants your soul.** 🎪💀
