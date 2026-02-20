"""
DEAD PROFIT Map Builder — Constructs the full amusement park map layout.

Uses uefn_builder.py to place all zones, devices, lighting, and props.
Can run inside UEFN (live) or outside (generates build plan JSON).
"""

import logging
from uefn_builder import (
    place_device, place_prop, place_point_light, place_spot_light,
    place_directional_light, create_zone, create_building,
    create_circle_placement, place_grid, spawn_actor,
    save_level, export_build_plan, LIVE_MODE
)

logging.basicConfig(level=logging.INFO, format="[DeadProfit] %(levelname)s: %(message)s")
log = logging.getLogger("dead-profit")

# =====================================================================
# Map Constants — All coordinates in UE units (cm). Origin at map center.
# =====================================================================

# Zone centers (x, y, z)
ZONES = {
    "entrance":    {"center": (0, -8000, 0),      "width": 4000, "depth": 3000},
    "main_plaza":  {"center": (0, -4000, 0),      "width": 6000, "depth": 4000},
    "rides_north": {"center": (-5000, 2000, 0),   "width": 6000, "depth": 6000},
    "rides_south": {"center": (5000, 2000, 0),    "width": 6000, "depth": 6000},
    "food_court":  {"center": (0, 2000, 0),       "width": 4000, "depth": 3000},
    "haunted_house": {"center": (0, 8000, 0),     "width": 5000, "depth": 5000},
    "maintenance": {"center": (-7000, 8000, 0),   "width": 3000, "depth": 3000},
    "backstage":   {"center": (7000, 8000, 0),    "width": 3000, "depth": 3000},
}

# Prop paths (Fortnite Creative gallery assets — adjust to actual UEFN content paths)
PROPS = {
    "carnival_tent": "/FortniteCreative/Galleries/CarnivalGallery/SM_CarnivalTent.SM_CarnivalTent",
    "food_stall": "/FortniteCreative/Galleries/RestaurantGallery/SM_FoodStall.SM_FoodStall",
    "fence": "/FortniteCreative/Galleries/FenceGallery/SM_MetalFence.SM_MetalFence",
    "lamp_post": "/FortniteCreative/Galleries/UrbanGallery/SM_StreetLamp.SM_StreetLamp",
    "bench": "/FortniteCreative/Galleries/ParkGallery/SM_ParkBench.SM_ParkBench",
    "trash_can": "/FortniteCreative/Galleries/UrbanGallery/SM_TrashCan.SM_TrashCan",
    "tree_spooky": "/FortniteCreative/Galleries/HalloweenGallery/SM_SpookyTree.SM_SpookyTree",
    "barrel": "/FortniteCreative/Galleries/IndustrialGallery/SM_Barrel.SM_Barrel",
    "crate": "/FortniteCreative/Galleries/IndustrialGallery/SM_WoodenCrate.SM_WoodenCrate",
    "sign": "/FortniteCreative/Galleries/SignGallery/SM_NeonSign.SM_NeonSign",
    "ferris_wheel": "/FortniteCreative/Galleries/CarnivalGallery/SM_FerrisWheel.SM_FerrisWheel",
    "roller_coaster": "/FortniteCreative/Galleries/CarnivalGallery/SM_RollerCoasterTrack.SM_RollerCoasterTrack",
}


def build_entrance():
    """Entrance zone: spawn pads, welcome triggers, ticket booth."""
    log.info("Building ENTRANCE zone...")
    z = ZONES["entrance"]
    cx, cy, cz = z["center"]

    # Player spawn pads — 4 pads spread across entrance
    for i in range(4):
        x_off = -600 + i * 400
        place_device("spawn pad", cx + x_off, cy - 500, cz, label=f"entrance_spawn_{i}")

    # Welcome trigger — displays intro HUD message
    place_device("trigger", cx, cy, cz, properties={
        "triggered_by_player": True,
        "visible_in_game": False,
    }, label="entrance_welcome_trigger")

    place_device("hud message", cx + 200, cy, cz, properties={
        "message_text": "Welcome to DEAD PROFIT Amusement Park...",
    }, label="entrance_welcome_msg")

    # Ticket booth building
    create_building((cx - 400, cy - 200, cz), 800, 400, floors=1, label="ticket_booth")

    # Entrance gate props
    place_prop(PROPS["sign"], cx, cy - 800, cz + 500, scale=(3, 3, 3), label="entrance_sign")
    place_prop(PROPS["fence"], cx - 1500, cy - 300, cz, label="entrance_fence_L")
    place_prop(PROPS["fence"], cx + 1500, cy - 300, cz, label="entrance_fence_R")

    # Entrance lighting
    place_spot_light(cx, cy - 800, cz + 600, rotation=(-60, 0, 0), intensity=15000,
                     color=(255, 100, 100), label="entrance_sign_light")
    for i in range(6):
        place_point_light(cx - 1000 + i * 400, cy, cz + 300, intensity=2000,
                          color=(255, 200, 150), label=f"entrance_path_light_{i}")


def build_main_plaza():
    """Central plaza connecting all zones."""
    log.info("Building MAIN PLAZA zone...")
    z = ZONES["main_plaza"]
    cx, cy, cz = z["center"]

    # Central fountain area (circle of props)
    create_circle_placement(PROPS["lamp_post"], (cx, cy, cz), radius=800, count=8,
                            label_prefix="plaza_lamp")

    # Benches around plaza
    for i in range(12):
        angle_offset = i * 30
        import math
        rad = math.radians(angle_offset)
        bx = cx + 1200 * math.cos(rad)
        by = cy + 1200 * math.sin(rad)
        place_prop(PROPS["bench"], bx, by, cz, rotation=(0, angle_offset + 90, 0),
                   label=f"plaza_bench_{i}")

    # Info boards / direction signs
    place_device("hud message", cx + 500, cy, cz + 200, properties={
        "message_text": "← Rides | Food Court → | Haunted House ↑",
    }, label="plaza_directions")

    # Ambient lighting
    for i in range(4):
        for j in range(3):
            place_point_light(cx - 2000 + i * 1300, cy - 1500 + j * 1500, cz + 400,
                              intensity=3000, color=(255, 220, 180),
                              label=f"plaza_ambient_{i}_{j}")


def build_rides_zone(side: str):
    """Rides zone (north or south). Contains ride props and interactive devices."""
    zone_key = f"rides_{side}"
    log.info(f"Building RIDES zone ({side})...")
    z = ZONES[zone_key]
    cx, cy, cz = z["center"]

    if side == "north":
        # Ferris wheel area
        place_prop(PROPS["ferris_wheel"], cx, cy, cz, scale=(2, 2, 2), label="ferris_wheel")
        place_device("trigger", cx, cy - 500, cz, properties={
            "visible_in_game": False,
        }, label="ferris_wheel_trigger")
        place_device("teleporter", cx + 200, cy - 500, cz, label="ferris_wheel_teleport_in")
        place_device("teleporter", cx + 200, cy + 1500, cz, label="ferris_wheel_teleport_out")

        # Bumper cars area
        create_zone("bumper_cars", (cx - 2000, cy, cz), 1500, 1500, [
            {"type": "barrier", "offset": (0, 0, 0), "properties": {}},
            {"type": "trigger", "offset": (0, -700, 0)},
            {"type": "item granter", "offset": (0, -700, 0), "properties": {}},
        ])
    else:
        # Roller coaster
        place_prop(PROPS["roller_coaster"], cx, cy, cz, scale=(3, 3, 3), label="roller_coaster")
        place_device("trigger", cx - 500, cy, cz, label="coaster_trigger")
        place_device("damage zone", cx, cy + 1000, cz, properties={
            "damage_amount": 10,
        }, label="coaster_damage_zone")

        # Spinning ride
        create_circle_placement(PROPS["barrel"], (cx + 2000, cy, cz),
                                radius=500, count=6, label_prefix="spin_ride")
        place_device("trigger", cx + 2000, cy, cz, label="spin_ride_trigger")

    # Carnival tents along the zone
    for i in range(3):
        place_prop(PROPS["carnival_tent"], cx - 2500 + i * 2500, cy - 2500, cz,
                   scale=(1.5, 1.5, 1.5), label=f"rides_{side}_tent_{i}")

    # Zone lighting — colored carnival lights
    colors = [(255, 50, 50), (50, 255, 50), (50, 50, 255), (255, 255, 50)]
    for i in range(8):
        place_point_light(cx - 2500 + i * 700, cy - 1000, cz + 400,
                          intensity=2500, color=colors[i % len(colors)],
                          label=f"rides_{side}_light_{i}")


def build_food_court():
    """Food court zone: vending machines, stalls, seating."""
    log.info("Building FOOD COURT zone...")
    z = ZONES["food_court"]
    cx, cy, cz = z["center"]

    # Food stalls in a row
    for i in range(5):
        x_off = -1600 + i * 800
        place_prop(PROPS["food_stall"], cx + x_off, cy - 500, cz, label=f"food_stall_{i}")

    # Vending machines
    for i in range(3):
        place_device("vending machine", cx - 800 + i * 800, cy + 500, cz,
                     label=f"vending_machine_{i}")

    # Seating grid
    place_grid(PROPS["bench"], (cx - 1000, cy + 800, cz), rows=3, cols=4,
               spacing=500, label_prefix="food_seat")

    # Trash cans
    for i in range(4):
        place_prop(PROPS["trash_can"], cx - 1200 + i * 800, cy + 300, cz,
                   label=f"food_trash_{i}")

    # Warm lighting
    for i in range(3):
        place_point_light(cx - 800 + i * 800, cy, cz + 350, intensity=4000,
                          color=(255, 200, 130), label=f"food_light_{i}")


def build_haunted_house():
    """Haunted house zone: dark interior, creature spawners, jump scares."""
    log.info("Building HAUNTED HOUSE zone...")
    z = ZONES["haunted_house"]
    cx, cy, cz = z["center"]

    # Main building shell
    create_building((cx - 2000, cy - 2000, cz), 4000, 4000, floors=2,
                    floor_height=500, label="haunted_house_main")

    # Entry trigger + message
    place_device("trigger", cx, cy - 2200, cz, properties={
        "visible_in_game": False,
    }, label="haunted_entry_trigger")
    place_device("hud message", cx + 100, cy - 2200, cz, properties={
        "message_text": "You hear something... Run.",
    }, label="haunted_entry_msg")

    # Creature spawners inside
    spawner_positions = [
        (cx - 800, cy - 500, cz),
        (cx + 800, cy + 500, cz),
        (cx, cy + 1500, cz),
        (cx - 1200, cy + 1000, cz),
        (cx + 1200, cy - 800, cz),
    ]
    for i, (sx, sy, sz) in enumerate(spawner_positions):
        place_device("creature spawner", sx, sy, sz, properties={
            "spawn_limit": 3,
        }, label=f"haunted_spawner_{i}")

    # Scare triggers (trigger + damage zone combos)
    for i in range(4):
        tx = cx - 1000 + i * 700
        ty = cy + i * 400
        place_device("trigger", tx, ty, cz, label=f"scare_trigger_{i}")
        place_device("damage zone", tx, ty + 100, cz, properties={
            "damage_amount": 5,
        }, label=f"scare_damage_{i}")

    # Spooky trees around exterior
    for i in range(8):
        import math
        angle = (2 * math.pi * i) / 8
        tx = cx + 2800 * math.cos(angle)
        ty = cy + 2800 * math.sin(angle)
        place_prop(PROPS["tree_spooky"], tx, ty, cz, scale=(1.5, 1.5, 2),
                   label=f"haunted_tree_{i}")

    # Minimal eerie lighting — dim red/purple
    place_point_light(cx, cy, cz + 400, intensity=800, color=(150, 0, 0), label="haunted_center_light")
    for i in range(4):
        place_point_light(cx - 1500 + i * 1000, cy, cz + 300, intensity=500,
                          color=(100, 0, 150), label=f"haunted_corridor_light_{i}")


def build_maintenance_zone():
    """Backstage / maintenance area: hidden loot, environmental storytelling."""
    log.info("Building MAINTENANCE zone...")
    z = ZONES["maintenance"]
    cx, cy, cz = z["center"]

    # Storage building
    create_building((cx - 1000, cy - 1000, cz), 2000, 2000, floors=1, label="maintenance_shed")

    # Crates and barrels
    for i in range(6):
        place_prop(PROPS["crate"], cx - 800 + i * 300, cy - 600, cz, label=f"maint_crate_{i}")
    for i in range(4):
        place_prop(PROPS["barrel"], cx + 500, cy - 400 + i * 300, cz, label=f"maint_barrel_{i}")

    # Hidden item granters (loot)
    place_device("item granter", cx - 500, cy + 200, cz, properties={},
                 label="maint_loot_1")
    place_device("item granter", cx + 300, cy - 300, cz, properties={},
                 label="maint_loot_2")

    # Trigger to reveal maintenance area clues
    place_device("trigger", cx, cy - 1200, cz, label="maint_discovery_trigger")
    place_device("hud message", cx + 100, cy - 1200, cz, properties={
        "message_text": "Employee records... something isn't right here.",
    }, label="maint_clue_msg")

    # Dim industrial lighting
    place_point_light(cx, cy, cz + 300, intensity=1500, color=(200, 200, 150),
                      label="maint_overhead")


def build_backstage():
    """Backstage area — mirror of maintenance on the other side."""
    log.info("Building BACKSTAGE zone...")
    z = ZONES["backstage"]
    cx, cy, cz = z["center"]

    create_building((cx - 1000, cy - 1000, cz), 2000, 2000, floors=1, label="backstage_building")

    for i in range(5):
        place_prop(PROPS["crate"], cx - 600 + i * 300, cy + 500, cz, label=f"backstage_crate_{i}")

    place_device("item granter", cx, cy, cz, label="backstage_loot")
    place_device("trigger", cx, cy - 1200, cz, label="backstage_trigger")
    place_device("hud message", cx + 100, cy - 1200, cz, properties={
        "message_text": "The show must go on... at any cost.",
    }, label="backstage_msg")

    place_point_light(cx, cy, cz + 300, intensity=1500, color=(180, 180, 200),
                      label="backstage_light")


def build_global_lighting():
    """Set up the overall map lighting — directional sun + sky."""
    log.info("Setting up global lighting...")

    # Main sun (slightly warm, angled for dramatic shadows)
    place_directional_light(rotation=(-50, 30, 0), intensity=2.5, label="sun_main")

    # Secondary fill (cooler, opposite side)
    place_directional_light(rotation=(-30, -150, 0), intensity=0.8, label="sun_fill")

    # Sky dome device for day/night cycle
    place_device("skydome", 0, 0, 0, properties={}, label="skydome_main")


def build_game_logic_devices():
    """Place global game management devices."""
    log.info("Placing game logic devices...")

    # Score manager
    place_device("score manager", 0, -9000, 0, label="global_score_manager")

    # Elimination manager
    place_device("elimination manager", 200, -9000, 0, label="global_elim_manager")

    # Timer device (for timed events)
    place_device("timer", 400, -9000, 0, properties={}, label="global_timer")

    # Channel devices for inter-device communication
    channels = ["game_start", "phase_change", "boss_spawn", "game_end"]
    for i, ch in enumerate(channels):
        place_device("channel", 600 + i * 200, -9000, 0, label=f"channel_{ch}")


def build_perimeter_fencing():
    """Place fences around the entire map boundary."""
    log.info("Building perimeter fencing...")

    # Map bounds roughly -10000 to 10000 on both axes
    fence_spacing = 500
    for side, positions in {
        "north": [(-10000 + i * fence_spacing, -10000, 0) for i in range(40)],
        "south": [(-10000 + i * fence_spacing, 12000, 0) for i in range(40)],
        "east": [(10000, -10000 + i * fence_spacing, 0) for i in range(44)],
        "west": [(-10000, -10000 + i * fence_spacing, 0) for i in range(44)],
    }.items():
        for i, (fx, fy, fz) in enumerate(positions):
            rot = (0, 0, 0) if side in ("north", "south") else (0, 90, 0)
            place_prop(PROPS["fence"], fx, fy, fz, rotation=rot,
                       label=f"perimeter_{side}_{i}")


def build_all():
    """Build the entire DEAD PROFIT map."""
    log.info("=" * 60)
    log.info("DEAD PROFIT — Full Map Build Starting")
    log.info("=" * 60)

    build_global_lighting()
    build_game_logic_devices()
    build_entrance()
    build_main_plaza()
    build_rides_zone("north")
    build_rides_zone("south")
    build_food_court()
    build_haunted_house()
    build_maintenance_zone()
    build_backstage()
    build_perimeter_fencing()

    if LIVE_MODE:
        save_level()
    else:
        export_build_plan("dead_profit_build_plan.json")

    log.info("=" * 60)
    log.info("DEAD PROFIT — Build Complete!")
    log.info("=" * 60)


if __name__ == "__main__":
    build_all()
