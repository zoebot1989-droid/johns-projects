# Dead Profit — Creative Direction Guide

> You don't need to be an artist. Follow these recipes exactly and it'll look great.

---

## 🎨 Master Color Palette

### Daytime Colors
| Zone | Primary | Secondary | Accent | Mood |
|------|---------|-----------|--------|------|
| Entrance | `#FFE4B5` Warm Sand | `#8B4513` Rust Brown | `#FF6347` Faded Red | "Welcome... or warning?" |
| Central Plaza | `#FFF8DC` Cream | `#228B22` Overgrown Green | `#B8860B` Tarnished Gold | "Grand but neglected" |
| Kiddie Zone | `#FFB6C1` Faded Pink | `#87CEEB` Peeling Blue | `#FFD700` Chipped Yellow | "Innocence rotting" |
| Food Court | `#FAFAD2` Grease Yellow | `#8B0000` Ketchup Red | `#006400` Mold Green | "Don't eat here" |
| Rides Area | `#D2B48C` Rust Tan | `#B22222` Iron Red | `#708090` Steel Grey | "Structural decay" |
| Haunted House | `#483D8B` Deep Purple | `#2F4F4F` Shadow Grey | `#8B0000` Blood Red | "Classic horror" |
| Water Rides | `#7FFFD4` Algae Green | `#008B8B` Murky Teal | `#2E8B57` Swamp | "Stagnant and slimy" |
| Boss Arena | `#FFFFFF` Spotlight | `#FF4500` Stage Orange | `#FFD700` Star Gold | "Showtime" |
| Tunnels | `#FF6347` Emergency Red | `#2F4F4F` Pipe Grey | `#8B4513` Rust | "Industrial nightmare" |

### Nighttime Colors (everything shifts darker)
| Zone | Light Color | Fog Color | Mood Shift |
|------|------------|-----------|------------|
| Entrance | `#4a4a6a` Dim Blue | `#1a1a2e` Deep Navy | Welcoming → Foreboding |
| Central Plaza | `#2c3e50` Cold Blue | `#16213e` Midnight | Peaceful → Watching |
| Kiddie Zone | `#4a0e4e` Sick Purple | `#1a1a2e` Deep Navy | Cute → Deeply Wrong |
| Food Court | `#8B8000` Sickly Yellow | `#2d2d2d` Smoke Grey | Gross → Terrifying |
| Rides Area | `#8B0000` Blood Red | `#1a1a1a` Pitch Black | Dangerous → Deadly |
| Haunted House | `#1a0a2e` Near-Black | `#0a0a0a` Void | Creepy → NOPE |
| Water Rides | `#006400` Toxic Green | `#0a2a1a` Swamp Black | Murky → Alive |
| Boss Arena | `#FF0000` Red Alert | `#2a0a0a` Blood Fog | Empty → War Zone |
| Tunnels | `#8B0000` Alarm Red | `#1a1a1a` Darkness | Uncomfortable → Run |

---

## 🗺️ Park Layout — Top-Down View

```
                    N
                    ↑
                    
    ┌───────────────────────────────────────────────┐
    │                                               │
    │           ┌─────────┐                         │
    │           │ HAUNTED  │                         │
    │           │  HOUSE   │                         │
    │           └────┬─────┘                         │
    │                │                               │
    │   ┌────────┐  ┌┴────────┐  ┌──────────┐      │
    │   │ WATER  │  │  BOSS   │  │  KIDDIE  │      │
    │   │ RIDES  │  │ ARENA   │  │   ZONE   │      │
    │   └───┬────┘  └────┬────┘  └────┬─────┘      │
    │       │            │            │             │
    │  ┌────┴──────┐ ┌───┴────┐ ┌────┴──────┐     │
    │  │  RIDES    │ │ FOOD   │ │           │     │
    │  │  AREA     │ │ COURT  │ │           │     │
    │  └────┬──────┘ └───┬────┘ │           │     │
    │       │            │      │           │     │
    │       └────────┬───┘      │           │     │
    │           ┌────┴─────────┐│           │     │
    │           │   CENTRAL    ├┘           │     │
    │           │    PLAZA     │            │     │
    │           │  ⛲ Fountain │            │     │
    │           └──────┬───────┘            │     │
    │                  │                    │     │
    │           ┌──────┴───────┐            │     │
    │           │   ENTRANCE   │            │     │
    │           │   🎪 Gate    │            │     │
    │           └──────────────┘            │     │
    │                  ↓                    │     │
    └──────────────── GATE ─────────────────┘     │
                                                   
                    S

    UNDERGROUND TUNNELS: Beneath Central Plaza
    Entrances: Plaza (hidden), Rides, Haunted House, Water Rides
```

---

## 📐 Zone Detail Layouts

### Entrance Zone
```
    ┌──── Lamppost    Lamppost ────┐
    │                              │
    │  [Bench]  TICKET  [Bench]   │
    │          BOOTHS              │
    │  [Trash] [1][2][3] [Trash]  │
    │                              │
    │    ──── TURNSTILES ────     │
    │                              │
    │  🪧 Map   ═══════  🪧 Map  │
    │  Board    ↑ PATH ↑  Board   │
    │           to Plaza           │
    └──────────────────────────────┘
    
    Lamppost spacing: 10m (1000 units) apart
    Benches: facing inward toward path
```

### Central Plaza
```
         Tree   Lamppost   Tree
           \       |       /
    Bush ── ┌─────────────┐ ── Bush
            │    Shops    │
    Bench ──│             │── Bench
            │   ⛲        │
    Lamp ── │  FOUNTAIN   │── Lamp
            │             │
    Bench ──│   Statue    │── Bench
            │             │
            └─────────────┘
           /       |       \
         Tree   Lamppost   Tree
    
    Fountain: dead center
    Lampposts: ring of 12, evenly spaced at zone radius
    Trees: clusters of 2-3, NOT evenly spaced (natural feel)
    Benches: face toward fountain
```

### Food Court
```
    ┌──────────────────────────────────┐
    │                                  │
    │  [Stall][Stall][Stall]          │
    │                                  │
    │   🍽️  🍽️  🍽️  🍽️            │
    │  table table table table         │
    │   ☂️   ☂️   ☂️   ☂️            │
    │                                  │
    │  [Stall][Stall][Stall]          │
    │                                  │
    │  🗑️ Dumpster    Vending 🥤     │
    │                                  │
    └──────────────────────────────────┘
    
    Stalls: two rows facing each other (market style)
    Tables: between the rows, 3m (300 units) apart
    Dumpsters: behind stalls, slightly askew (messy)
    Trash: overflowing near every table
```

---

## 💡 Lighting Recipes

### Recipe 1: Warm Welcome (Entrance, Day)
- **Light color:** `#FFE4B5` (warm sand)
- **Intensity:** 80%
- **Placement:** Lampposts every 10m along path
- **Tip:** Lights slightly angled toward the ground

### Recipe 2: Eerie Blue (All zones, Night)
- **Light color:** `#4a4a6a` (dim blue-grey)
- **Intensity:** 30%
- **Placement:** Same as day, but dimmer
- **Add:** Occasional `#8B0000` red light for horror accent

### Recipe 3: Neon Buzz (Entrance, Food Court, Rides)
- **Colors:** Cycle between `#FF1493` (hot pink), `#00FF7F` (neon green), `#FF4500` (orange)
- **Intensity:** 100%
- **Placement:** On signs, above stalls, archways
- **Effect:** Occasional flicker (the Verse script handles this)

### Recipe 4: Horror Flicker (Haunted House, Night everywhere)
- **Color:** `#8B0000` (dark red)
- **Intensity:** 50% → 0% → 50% (rapid flicker)
- **Placement:** Inside haunted house corridors, near broken rides
- **Frequency:** Random flicker every 1-5 seconds

### Recipe 5: Emergency (Tunnels)
- **Color:** `#FF0000` (pure red)
- **Intensity:** 80%
- **Placement:** Every 5m in tunnels
- **Effect:** Slow pulse (2-second cycle)
- **Add:** Single white `#FFFFFF` emergency light at tunnel intersections

### Recipe 6: Boss Spotlight
- **Color:** `#FFFFFF` (pure white) for main spot, `#FF4500` for rim lights
- **Intensity:** 200% (max brightness)
- **Placement:** 4-6 spotlights aimed at center stage
- **During boss:** Red wash `#8B0000` on everything except stage center

---

## 🎭 Prop Placement Patterns

### Pattern: "Path Border"
Line props along both sides of a walkway:
```
  Lamp---Lamp---Lamp---Lamp
  │                       │
  │      WALKWAY          │
  │                       │
  Lamp---Lamp---Lamp---Lamp
```
- Spacing: 1000 units (10m) between lampposts
- Offset: 200 units from path edge

### Pattern: "Scattered Abandon"
For debris, barrels, crates — NOT in grid, slightly random:
```
    Barrel        Crate
         Crate
    
              Barrel   Barrel
       Crate
                    Barrel
```
- Vary rotation (never all facing same way)
- Cluster 2-3 together, then gap, then 1 alone
- Some tipped over (rotate pitch 45-90°)

### Pattern: "Ring Boundary"
For zone perimeters:
```
          L
        /   \
      L       L
     |         |
      L       L
        \   /
          L
```
- 8-12 lampposts in a circle at zone radius
- Every other one can be a tree instead for variety

### Pattern: "Market Row"
For food stalls, carnival booths:
```
  [Stall] [Stall] [Stall]
  
  [Stall] [Stall] [Stall]
```
- Two parallel rows, facing each other
- 400 units between stalls in same row
- 800 units between rows (space for tables/players)

---

## 🖼️ Reference Inspiration

### Games to Reference
| Game | What to Steal |
|------|--------------|
| **Dark Deception** | Creepy theme park atmosphere, colored lighting |
| **Five Nights at Freddy's: Security Breach** | Abandoned entertainment venue, neon + dark |
| **Left 4 Dead 2 (Dark Carnival)** | Outdoor park at night, fog, broken rides |
| **Bendy and the Ink Machine** | Abandoned workplace horror, decay aesthetic |
| **Little Nightmares** | Scale, atmosphere, unsettling whimsy |
| **Bioshock** | Art deco + decay, neon signs in ruins |
| **The Park (Funcom)** | Literally an abandoned amusement park horror |

### Visual Rules of Thumb
| If it looks like... | You're doing it right ✅ |
|---------------------|------------------------|
| A theme park after a hurricane | Entrance & Plaza |
| Willy Wonka's factory but evil | Food Court |
| A rusty shipyard | Rides Area |
| Every horror movie haunted house | Haunted House |
| Shrek's swamp | Water Rides |
| A heavy metal concert stage | Boss Arena |
| Alien (1979) maintenance corridors | Tunnels |
| Kiddie playground after dark | Kiddie Zone |

### What NOT to Do
- ❌ Don't make it too clean (it's ABANDONED)
- ❌ Don't use only one color per zone (mix 2-3)
- ❌ Don't place props in perfect grids (randomize rotation/position slightly)
- ❌ Don't forget vertical variety (stack crates, lean things against walls)
- ❌ Don't leave flat empty spaces (scatter debris, weeds, puddles)
- ❌ Don't make every light the same brightness (vary intensity 30-100%)

---

## 🔊 Sound Design Guide

### Per-Zone Ambient Sounds
| Zone | Day Sound | Night Sound | Horror Trigger |
|------|-----------|-------------|----------------|
| Entrance | Birds, distant traffic | Crickets, gate creaking | Metal scraping |
| Plaza | Wind, fountain drip | Whispers, metal creak | Footsteps behind you |
| Kiddie | Broken music box | Distorted lullaby, giggles | Child laughing |
| Food Court | Buzzing flies | Scratching, squelching | Plate smashing |
| Rides | Metal groaning, wind | Chains rattling, screaming metal | Ride starting up |
| Haunted | Creaking floors, drips | Screams, doors slamming | Breathing |
| Water | Dripping, frogs | Splashing, gurgling | Something in the water |
| Boss Arena | Wind, empty stage | Ominous hum | Crowd cheering (distorted) |
| Tunnels | Pipes humming, drips | Clanging, echoing footsteps | Steam burst |

### Sound Layering
1. **Base layer:** Constant ambient (wind, water, hum) — volume 30-40%
2. **Zone layer:** Zone-specific sounds — volume 50-60%
3. **Trigger layer:** Event sounds on interaction — volume 80-100%
4. **Horror layer:** Night-only scary sounds — random timing, volume 70-90%

---

## ⏰ Workflow Cheat Sheet

1. **Sculpt terrain** → Flat zones connected by paths (30 min)
2. **Paint terrain** → Grass=green, Paths=concrete, Water=blue (15 min)
3. **Drop reference props** → One of each from asset list (45 min)
4. **Place devices** → Lights, VFX, Audio, Triggers (45 min)
5. **Add Verse scripts** → Copy-paste, wire references (20 min)
6. **Test** → Launch, walk around, adjust positions (ongoing)
7. **Polish** → Add more scatter props, tweak colors, test with friends

**Total time to playable prototype: ~3-4 hours**
