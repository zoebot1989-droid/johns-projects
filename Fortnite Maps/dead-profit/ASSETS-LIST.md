# DEAD PROFIT — Complete Assets List

> Every Fortnite Creative device, prop, and prefab needed to build the map.
> Names match UEFN's Content Browser. Organized by zone.

---

## 📋 Table of Contents

1. [Global Devices (Used Everywhere)](#global-devices)
2. [Park Entrance Zone](#park-entrance-zone)
3. [Central Plaza / Hub](#central-plaza--hub)
4. [Kiddie Zone](#kiddie-zone)
5. [Food Court](#food-court)
6. [Game Stalls](#game-stalls)
7. [Rides Area (Ferris Wheel & Roller Coaster)](#rides-area)
8. [Haunted House](#haunted-house)
9. [Water Rides](#water-rides)
10. [Main Stage / Boss Arena](#main-stage--boss-arena)
11. [Underground Tunnels (Secret Area)](#underground-tunnels)
12. [Perimeter Fence](#perimeter-fence)
13. [Verse Script Devices](#verse-script-devices)

---

## Global Devices

These devices are placed once (or a few times) and control the entire map.

| Device Name | Qty | Purpose |
|---|---|---|
| `Timer Device` | 8 | Day timer, Dusk timer, Night timer, Dawn timer, Income timer, AI tick timer, Battery drain timer, Proximity check timer |
| `HUD Message Device` | 12 | Currency, Phase/Timer, Park Rating, Announcement, Proximity Warning, Tool Bar, Night Progress, Minimap, Lobby, Flashlight Battery, Unlock notifications, Score |
| `Billboard Device` | 15 | 10× attraction status displays, Shop priceboard, Score board, Economy stats, 2× spare |
| `Audio Player Device` | 25 | Day ambience, Night ambience, Dusk siren, Dawn sound, Income cha-ching, Build sound, Damage sound, Flashlight click, Low battery warning, Barricade place/break, Noise maker, Hiding enter/exit, Flare sound, Purchase sound, Intro music, Victory music, Game over music, Entity audio ×5, Stun sound, Heartbeat slow/fast, Timer tick, Blackout/restore, Unlock jingle, Night announcement |
| `Teleporter Device` | 4 | Lobby→Game, Game→Lobby, 2× Owner teleport destinations |
| `Button Device` | 18 | 10× attraction build buttons, 4× shop buy buttons, Start button, Reset button, Flashlight toggle, Barricade place, Noise maker deploy, Flare deploy |
| `Fog Device` | 1 | Night fog atmosphere |
| `Light Device` | 30+ | Sun light (1), Moon light (1), Ambient park lights (20+), Flare light (1), Flashlight light (1), Controllable lights for blackout (6+) |
| `Map Indicator Device` | 10 | Plaza marker, Entity spawn markers (4), Hiding spot markers (4), Secret area marker |
| `VFX Spawner Device` | 4 | Stun VFX, Corruption VFX, Mimic reveal VFX, Flare VFX |
| `Damage Volume Device` | 4 | Entity attack zones |
| `Cinematic Sequence Device` | 1 | Optional intro cutscene |
| `Player Spawn Pad Device` | 4 | 1 in lobby, 3 at park entrance |
| `Elimination Manager Device` | 1 | Track player deaths |
| `Team Settings Device` | 1 | Set to co-op / same team |
| `Island Settings Device` | 1 | Map name, description, max players (4) |
| `Score Manager Device` | 1 | Track scores |
| `Conditional Button Device` | 4 | Repair buttons (one per major zone) |

---

## Park Entrance Zone

> The first area players see. Ticket booth, welcome arch, initial path splitting into zones.

| Asset | Qty | Notes |
|---|---|---|
| **Prefabs** | | |
| `Amusement Park Entrance Gallery` | 1 | Main entrance arch — Content Browser > Prefabs > Galleries |
| `Ticket Booth Prop` | 1 | Or build from `Wooden Shack Prop` + `Sign Prop` |
| **Props** | | |
| `Carnival Banner Prop` | 6 | Line the entrance path |
| `Balloon Cluster Prop` | 4 | Festive decoration |
| `Trash Can Prop` | 4 | Some are Mimic spawn points! |
| `Park Bench Prop` | 4 | Some are Mimic spawn points! |
| `Lamppost Prop` (or `Street Light Prop`) | 6 | Connected to `Light Device` for day/night |
| `Directional Sign Prop` | 3 | Point to zones: Rides, Food, Games |
| `Fence Segment Prop` | 10 | Channel players toward entrance |
| `Welcome Mat Prop` | 1 | At the very entrance |
| **Devices** | | |
| `Player Spawn Pad Device` | 3 | Spawn players here after teleport from lobby |
| `Trigger Device` | 2 | Tutorial trigger zones |

---

## Central Plaza / Hub

> The heart of the park. Shop/armory, main gathering point, economy stats billboard.

| Asset | Qty | Notes |
|---|---|---|
| **Prefabs** | | |
| `Wooden Shack Prop` or `Market Stall Prefab` | 2 | Survival shop + upgrade shop |
| **Props** | | |
| `Fountain Prop` | 1 | Center of plaza |
| `Vendor Cart Prop` | 2 | Weapon/tool vendors |
| `Crate Prop` (various sizes) | 6 | Decoration, some hide lore items |
| `Lamppost Prop` | 8 | Ring the plaza |
| `Park Bench Prop` | 6 | Seating |
| `Barrel Prop` | 4 | Decoration / hiding spots |
| `Poster Board Prop` or `Billboard Prop` | 3 | Show prices, lore, map |
| `Cobblestone Floor Prop` or terrain paint | — | Ground texture |
| **Devices** | | |
| `Button Device` | 4 | Buy Barricade, Buy Noise Maker, Buy Flare, Buy Battery |
| `Billboard Device` | 2 | Shop prices, Economy stats |
| `Item Granter Device` | 4 | Grant tools on purchase |
| `Barrier Device` | 2 | Block off zones until unlocked |
| `Map Indicator Device` | 1 | Plaza marker (always visible) |

---

## Kiddie Zone

> Tier 1 attraction area. Cheap rides, easy to build, low income.

| Asset | Qty | Notes |
|---|---|---|
| **Props** | | |
| `Carousel Prop` or `Merry-Go-Round Prop` | 1 | Kiddie Train attraction visual |
| `Teacup Ride Prop` | 1 | Optional decoration |
| `Balloon Animal Prop` | 4 | Decoration |
| `Colorful Tent Prop` | 1 | Covers the ride area |
| `Fence Segment Prop` (low, decorative) | 8 | Zone boundary |
| `Lamppost Prop` (small/decorative) | 4 | |
| **Devices** | | |
| `Button Device` | 2 | Build/upgrade Kiddie Train, build/upgrade second attraction |
| `Prop Mover Device` | 2 | Reveal built attractions |
| `Billboard Device` | 2 | Attraction status |
| `Guard Spawner Device` | 1 | Wanderer spawn point nearby |

---

## Food Court

> Healing zone and Tier 1 income. Food stands, seating, colorful.

| Asset | Qty | Notes |
|---|---|---|
| **Props** | | |
| `Food Truck Prop` | 1 | Main food court visual |
| `Vendor Cart Prop` | 3 | Cotton candy, hot dogs, drinks |
| `Picnic Table Prop` | 4 | Seating area |
| `Umbrella Prop` (patio) | 4 | Over tables |
| `Menu Board Prop` | 2 | Food descriptions |
| `Trash Can Prop` | 3 | Mimic hiding spots |
| `String Lights Prop` | 4 | Festive atmosphere |
| `Ice Cream Sign Prop` | 1 | |
| **Devices** | | |
| `Button Device` | 2 | Build/upgrade Cotton Candy Stand, Food Court |
| `Prop Mover Device` | 2 | Reveal built attractions |
| `Billboard Device` | 2 | Attraction status |
| `Healing Device` or `Campfire Device` | 1 | Healing zone during day |

---

## Game Stalls

> Tier 1 income. Carnival game booths.

| Asset | Qty | Notes |
|---|---|---|
| **Props** | | |
| `Carnival Booth Prop` | 2 | Balloon dart booth visual |
| `Target Prop` | 4 | Game decoration |
| `Prize Display Prop` (stuffed animals) | 3 | Hanging prizes |
| `Counter Prop` | 2 | Booth counter |
| `Carnival Sign Prop` | 2 | |
| `String Lights Prop` | 3 | Decoration |
| **Devices** | | |
| `Button Device` | 1 | Build/upgrade Balloon Dart Booth |
| `Prop Mover Device` | 1 | Reveal built attraction |
| `Billboard Device` | 1 | Attraction status |

---

## Rides Area

> Tier 2 attractions. Ferris Wheel, Roller Coaster, Bumper Cars. Main income zone.

| Asset | Qty | Notes |
|---|---|---|
| **Prefabs** | | |
| `Roller Coaster Gallery` | 1 | Content Browser > Prefabs > Galleries (or build from pieces) |
| **Props** | | |
| `Ferris Wheel Prop` | 1 | Large centerpiece (may need to build from circular structures) |
| `Roller Coaster Track Prop` | 8+ | Build the coaster from segments |
| `Bumper Car Prop` | 4 | In the bumper car arena |
| `Bumper Car Arena Floor Prop` | 1 | Flat arena surface |
| `Metal Railing Prop` | 12 | Queue lines and safety rails |
| `Queue Line Rope Prop` | 8 | Visitor queue decoration |
| `Lamppost Prop` (tall) | 6 | Area lighting |
| `Neon Sign Prop` | 3 | Ride names |
| `Metal Scaffolding Prop` | 4 | Ride structure support |
| **Devices** | | |
| `Button Device` | 3 | Build/upgrade Ferris Wheel, Roller Coaster, Bumper Cars |
| `Prop Mover Device` | 3 | Reveal built attractions |
| `Billboard Device` | 3 | Attraction status |
| `Guard Spawner Device` | 2 | Entity spawn points near rides |
| `Damage Volume Device` | 1 | Conductor "possessed ride" damage zone |
| `Creature Spawner Device` | 1 | Conductor spawn |
| `Trigger Device` | 2 | Conductor detection zones |

---

## Haunted House

> Tier 3 attraction AND primary entity spawn point. Most dangerous zone but highest income.

| Asset | Qty | Notes |
|---|---|---|
| **Prefabs** | | |
| `Haunted House Gallery` or `Abandoned House Prefab` | 1 | Main structure |
| **Props** | | |
| `Cobweb Prop` | 8 | Atmosphere |
| `Broken Window Prop` | 4 | |
| `Old Painting Prop` | 3 | Lore items |
| `Candelabra Prop` | 4 | Dim lighting |
| `Coffin Prop` | 2 | Decoration / jumpscare source |
| `Creaky Door Prop` | 3 | Audio triggers |
| `Dusty Furniture Props` (chairs, tables) | 6 | Interior decoration |
| `Ripped Curtain Prop` | 4 | Obscure vision |
| `Old Clock Prop` | 1 | Lore item |
| `Ghost Portrait Prop` | 2 | Changes during night? |
| **Devices** | | |
| `Button Device` | 1 | Build/upgrade Haunted House Ride |
| `Prop Mover Device` | 1 | Reveal built attraction |
| `Billboard Device` | 1 | Attraction status |
| `Guard Spawner Device` | 3 | Primary Wanderer spawn, Mimic spawns |
| `Trigger Device` | 4 | Jumpscare triggers, entity detection |
| `Audio Player Device` | 3 | Creepy ambient, jumpscare stingers |
| `VFX Spawner Device` | 2 | Ghost effects, fog |
| `Light Device` | 4 | Flickering candles, controllable for blackout |
| `Hiding Spot` (`Button Device` + `Trigger Device`) | 2 | Lockers/wardrobes player can hide in |

---

## Water Rides

> Tier 3 attraction area. Log Flume and splash zone.

| Asset | Qty | Notes |
|---|---|---|
| **Props** | | |
| `Water Channel Prop` or terrain water | — | Log flume water channel |
| `Log Boat Prop` | 2 | Ride vehicles |
| `Waterfall Prop` or `Water VFX` | 1 | Splash zone |
| `Wooden Bridge Prop` | 2 | Over the water channel |
| `Tropical Plant Props` | 6 | Decoration |
| `Rock Prop` (various) | 8 | Channel borders |
| `Wooden Sign Prop` | 2 | "Raging Rapids" etc. |
| **Devices** | | |
| `Button Device` | 1 | Build/upgrade Log Flume |
| `Prop Mover Device` | 1 | |
| `Billboard Device` | 1 | |
| `Guard Spawner Device` | 1 | Entity spawn point |

---

## Main Stage / Boss Arena

> Night 5 boss fight arena. During Day, it's the Main Stage attraction.

| Asset | Qty | Notes |
|---|---|---|
| **Props** | | |
| `Concert Stage Prop` or `Platform Prop` (large) | 1 | The stage |
| `Speaker Stack Prop` | 4 | Stage equipment |
| `Spotlight Prop` | 4 | Stage lighting (controllable) |
| `Audience Seating Prop` (bleachers/chairs) | 2 | |
| `Curtain Prop` (large) | 2 | Stage backdrop |
| `Banner Prop` | 4 | "Malmouth Funland" banners |
| `Smoke Machine Prop` or `Fog VFX` | 1 | Boss arena atmosphere |
| **Devices** | | |
| `Button Device` | 1 | Build/upgrade Main Stage |
| `Prop Mover Device` | 1 | |
| `Billboard Device` | 1 | |
| `Guard Spawner Device` | 1 | The Owner (boss) spawn |
| `Teleporter Device` | 3 | Owner teleport destinations |
| `Damage Volume Device` | 2 | Boss attack zones |
| `Trigger Device` | 2 | Boss arena boundary |
| `VFX Spawner Device` | 1 | Corruption effect |
| `Light Device` | 4 | Spotlights (controllable) |

---

## Underground Tunnels

> Secret area unlocked at Night 4. Contains lore items and rare loot.

| Asset | Qty | Notes |
|---|---|---|
| **Props** | | |
| `Concrete Tunnel Prop` or `Sewer Pipe Props` | 8+ | Tunnel segments |
| `Rusty Pipe Prop` | 6 | Wall decoration |
| `Dripping Water VFX` | 3 | Atmosphere |
| `Old Filing Cabinet Prop` | 2 | Lore storage |
| `Newspaper Clipping Prop` | 4 | Lore items — "The Incident" articles |
| `Old Photo Prop` | 3 | Previous park owner photos |
| `Emergency Light Prop` | 4 | Dim red lighting |
| `Broken Electrical Panel Prop` | 2 | Atmosphere |
| `Crate Prop` (wooden) | 4 | Loot containers |
| `Locked Gate Prop` | 2 | Progression gates within tunnels |
| **Devices** | | |
| `Barrier Device` | 1 | Blocks entrance until Night 4 unlock |
| `Prop Mover Device` | 1 | Reveals entrance |
| `Trigger Device` | 3 | Lore pickup triggers |
| `Audio Player Device` | 2 | Tunnel ambience, dripping water |
| `Light Device` | 4 | Emergency lights (red) |
| `Item Granter Device` | 2 | Rare loot: blueprints, special tools |
| `Guard Spawner Device` | 1 | Entities can follow you down here |
| `Hiding Spot` (`Button Device` + `Trigger Device`) | 1 | Emergency hiding spot |

---

## Perimeter Fence

> 4 breach points where entities enter the park. Players can fortify these.

| Asset | Qty | Notes |
|---|---|---|
| **Props** | | |
| `Chain Link Fence Prop` | 20+ | Park perimeter |
| `Fence Gate Prop` | 4 | Breach points |
| `Broken Fence Segment Prop` | 4 | Damaged sections |
| `Warning Sign Prop` | 4 | "DANGER" / "KEEP OUT" at breach points |
| `Sandbag Prop` | 8 | Fortification decoration |
| `Barbed Wire Prop` | 6 | Top of fences |
| `Floodlight Prop` | 4 | Perimeter lighting |
| **Devices** | | |
| `Barrier Device` | 4 | Barricade slots (player-placed) |
| `Guard Spawner Device` | 4 | Hollow Kid breach spawn points |
| `Trigger Device` | 4 | Breach detection |
| `Audio Player Device` | 2 | Fence rattling, breach alarm |
| `Button Device` | 4 | Barricade placement points |

---

## Verse Script Devices

> Custom Verse devices. Each .verse file becomes a device you place in the level.

| Verse File | Device Name | Qty | Placement |
|---|---|---|---|
| `main-game.verse` | `main_game_device` | 1 | Anywhere (hidden) — master controller |
| `day-night-cycle.verse` | `day_night_cycle_device` | 1 | Anywhere (hidden) — references all timers/lights |
| `park-manager.verse` | `park_manager_device` | 1 | Central Plaza area — references all attraction devices |
| `entity-ai.verse` | `entity_ai_device` | 1 | Anywhere (hidden) — references all spawners |
| `survival-tools.verse` | `survival_tools_device` | 1 | Anywhere (hidden) — references all tool devices |
| `economy.verse` | `economy_device` | 1 | Anywhere (hidden) — references HUD devices |
| `progression.verse` | `progression_device` | 1 | Anywhere (hidden) — references barriers/unlocks |
| `ui-manager.verse` | `ui_manager_device` | 1 | Anywhere (hidden) — references all HUD devices |

---

## 📊 Total Device Count Summary

| Category | Approximate Count |
|---|---|
| Timer Devices | 8-10 |
| HUD Message Devices | 12-15 |
| Billboard Devices | 15 |
| Audio Player Devices | 25-30 |
| Button Devices | 18-22 |
| Light Devices | 30-40 |
| Guard Spawner Devices | 12-15 |
| Creature Spawner Devices | 2-3 |
| Trigger Devices | 15-20 |
| Barrier Devices | 8-10 |
| Prop Mover Devices | 10-12 |
| VFX Spawner Devices | 4-6 |
| Teleporter Devices | 4-6 |
| Damage Volume Devices | 4-5 |
| Map Indicator Devices | 10 |
| Prop Manipulator Devices | 8-10 |
| Item Granter Devices | 6-8 |
| Verse Devices | 8 |
| **TOTAL DEVICES** | **~200-250** |

---

## 🎨 Recommended UEFN Asset Packs

Search these in the UEFN Content Browser for ready-made props:

1. **Amusement Park Props** — Carnival/fair themed assets
2. **Horror Props Pack** — Cobwebs, broken furniture, spooky decor
3. **Industrial Props** — Pipes, scaffolding, underground tunnel pieces
4. **Neon Signs Pack** — Colorful signs for rides
5. **Nature Props** — Trees, bushes, rocks for park landscaping
6. **Suburban Props** — Fences, benches, lampposts, trash cans
7. **Water Props** — Channels, waterfalls, splash effects
8. **Medieval/Wooden Props** — Crates, barrels, wooden structures

> **Note:** Exact prop names may vary between UEFN versions. Use the Content Browser search with keywords like "carnival", "park", "bench", "fence", "light" to find equivalents.
