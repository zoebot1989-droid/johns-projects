"""
UEFN Builder — Core automation API for placing actors, devices, and configuring maps.

This script runs INSIDE UEFN's Python environment (via ExecutePythonScript commandlet
or the in-editor Python console). It requires the `unreal` module.

When running outside UEFN (for testing/CLI), it uses a stub unreal module that logs
operations to a JSON build plan instead of executing them live.
"""

import json
import logging
import math
import os
import sys
from dataclasses import dataclass, field, asdict
from typing import List, Optional, Tuple, Dict, Any

logging.basicConfig(level=logging.INFO, format="[UEFNBuilder] %(levelname)s: %(message)s")
log = logging.getLogger("uefn-builder")

# ---------------------------------------------------------------------------
# Unreal module abstraction — works both inside and outside UEFN
# ---------------------------------------------------------------------------

try:
    import unreal
    LIVE_MODE = True
    log.info("Running in UEFN Python environment (live mode).")
except ImportError:
    LIVE_MODE = False
    log.info("Running outside UEFN (plan mode — operations logged to build plan).")


@dataclass
class PlacedActor:
    """Record of a placed actor."""
    name: str
    actor_class: str
    x: float
    y: float
    z: float
    rotation: Tuple[float, float, float] = (0, 0, 0)
    scale: Tuple[float, float, float] = (1, 1, 1)
    properties: Dict[str, Any] = field(default_factory=dict)
    label: str = ""


class BuildPlan:
    """Accumulates operations when not running inside UEFN. Exportable as JSON."""

    def __init__(self):
        self.actors: List[dict] = []
        self.operations: List[dict] = []

    def add_actor(self, actor: PlacedActor):
        self.actors.append(asdict(actor))

    def add_op(self, op_type: str, **kwargs):
        self.operations.append({"type": op_type, **kwargs})

    def export(self, path: str = "build_plan.json"):
        data = {"actors": self.actors, "operations": self.operations}
        with open(path, "w") as f:
            json.dump(data, f, indent=2)
        log.info(f"Build plan exported to {path}")
        return data


# Global build plan for offline mode
_plan = BuildPlan()


# ---------------------------------------------------------------------------
# Core placement functions
# ---------------------------------------------------------------------------

def _make_transform(x, y, z, rot=(0, 0, 0), scale=(1, 1, 1)):
    """Create an Unreal transform (live mode) or a dict (plan mode)."""
    if LIVE_MODE:
        location = unreal.Vector(x, y, z)
        rotation = unreal.Rotator(rot[0], rot[1], rot[2])
        scale3d = unreal.Vector(scale[0], scale[1], scale[2])
        t = unreal.Transform()
        t.set_editor_property("translation", location)
        t.set_editor_property("rotation", rotation)
        t.set_editor_property("scale3d", scale3d)
        return t
    return {"location": [x, y, z], "rotation": list(rot), "scale": list(scale)}


def spawn_actor(actor_class_path: str, x: float, y: float, z: float,
                rotation=(0, 0, 0), scale=(1, 1, 1), label: str = "",
                properties: Dict[str, Any] = None) -> PlacedActor:
    """
    Spawn an actor in the level.

    Args:
        actor_class_path: UE asset path like '/Game/Devices/ButtonDevice.ButtonDevice_C'
                          or a short name like 'PointLight' for engine classes.
        x, y, z: World coordinates.
        rotation: (pitch, yaw, roll) in degrees.
        scale: (x, y, z) scale multiplier.
        label: Human-readable label for the actor.
        properties: Dict of property_name -> value to set after spawning.
    """
    properties = properties or {}
    record = PlacedActor(
        name=label or actor_class_path.split(".")[-1],
        actor_class=actor_class_path,
        x=x, y=y, z=z,
        rotation=rotation, scale=scale,
        properties=properties, label=label
    )

    if LIVE_MODE:
        # Resolve class
        if "/" in actor_class_path:
            actor_class = unreal.EditorAssetLibrary.load_asset(actor_class_path)
            if actor_class is None:
                log.error(f"Could not load asset: {actor_class_path}")
                return record
        else:
            actor_class = getattr(unreal, actor_class_path, None)
            if actor_class is None:
                log.error(f"Unknown unreal class: {actor_class_path}")
                return record

        transform = _make_transform(x, y, z, rotation, scale)

        try:
            actor = unreal.EditorLevelLibrary.spawn_actor_from_class(actor_class, unreal.Vector(x, y, z))
            if actor:
                actor.set_actor_transform(transform, False, False)
                if label:
                    actor.set_actor_label(label)
                for prop, val in properties.items():
                    try:
                        actor.set_editor_property(prop, val)
                    except Exception as e:
                        log.warning(f"Could not set {prop}={val} on {label}: {e}")
                log.info(f"Spawned {actor_class_path} at ({x},{y},{z}) as '{label}'")
        except Exception as e:
            log.error(f"Failed to spawn {actor_class_path}: {e}")
    else:
        _plan.add_actor(record)
        log.info(f"[PLAN] Spawn {actor_class_path} at ({x},{y},{z}) label='{label}'")

    return record


def place_device(device_type: str, x: float, y: float, z: float,
                 rotation=(0, 0, 0), properties: Dict[str, Any] = None,
                 label: str = "") -> PlacedActor:
    """
    Place a Fortnite Creative device by type name.

    Common device types map to their asset paths automatically.
    """
    device_paths = {
        "button": "/FortniteCreative/Devices/ButtonDevice/ButtonDevice.ButtonDevice_C",
        "trigger": "/FortniteCreative/Devices/TriggerDevice/BP_TriggerDevice.BP_TriggerDevice_C",
        "item granter": "/FortniteCreative/Devices/ItemGranterDevice/BP_ItemGranter.BP_ItemGranter_C",
        "spawn pad": "/FortniteCreative/Devices/SpawnPad/BP_SpawnPad.BP_SpawnPad_C",
        "barrier": "/FortniteCreative/Devices/BarrierDevice/BP_BarrierDevice.BP_BarrierDevice_C",
        "creature spawner": "/FortniteCreative/Devices/CreatureSpawner/BP_CreatureSpawner.BP_CreatureSpawner_C",
        "hud message": "/FortniteCreative/Devices/HUDMessageDevice/BP_HUDMessageDevice.BP_HUDMessageDevice_C",
        "timer": "/FortniteCreative/Devices/TimerDevice/BP_TimerDevice.BP_TimerDevice_C",
        "score manager": "/FortniteCreative/Devices/ScoreManager/BP_ScoreManager.BP_ScoreManager_C",
        "elimination manager": "/FortniteCreative/Devices/EliminationManager/BP_EliminationManager.BP_EliminationManager_C",
        "channel": "/FortniteCreative/Devices/ChannelDevice/BP_ChannelDevice.BP_ChannelDevice_C",
        "vending machine": "/FortniteCreative/Devices/VendingMachine/BP_VendingMachine.BP_VendingMachine_C",
        "damage zone": "/FortniteCreative/Devices/DamageZone/BP_DamageZone.BP_DamageZone_C",
        "music sequencer": "/FortniteCreative/Devices/MusicSequencer/BP_MusicSequencer.BP_MusicSequencer_C",
        "teleporter": "/FortniteCreative/Devices/Teleporter/BP_Teleporter.BP_Teleporter_C",
        "player checkpoint": "/FortniteCreative/Devices/PlayerCheckpoint/BP_PlayerCheckpoint.BP_PlayerCheckpoint_C",
        "conditional button": "/FortniteCreative/Devices/ConditionalButton/BP_ConditionalButton.BP_ConditionalButton_C",
        "skydome": "/FortniteCreative/Devices/Skydome/BP_Skydome.BP_Skydome_C",
    }

    key = device_type.lower().strip()
    path = device_paths.get(key, device_type)  # Fall back to raw path

    if not label:
        label = f"{device_type}_{int(x)}_{int(y)}"

    return spawn_actor(path, x, y, z, rotation=rotation, properties=properties or {}, label=label)


def place_prop(prop_path: str, x: float, y: float, z: float,
               rotation=(0, 0, 0), scale=(1, 1, 1), label: str = "") -> PlacedActor:
    """Place a static mesh / prop from a content path."""
    return spawn_actor(prop_path, x, y, z, rotation=rotation, scale=scale, label=label)


# ---------------------------------------------------------------------------
# Lighting helpers
# ---------------------------------------------------------------------------

def place_point_light(x, y, z, intensity=5000, color=(255, 255, 255), radius=1000, label=""):
    """Place a point light."""
    props = {
        "intensity": intensity,
        "light_color": color,
        "attenuation_radius": radius,
    }
    return spawn_actor("PointLight", x, y, z, properties=props, label=label or f"PointLight_{int(x)}_{int(y)}")


def place_spot_light(x, y, z, rotation=(0, 0, 0), intensity=8000, color=(255, 255, 255),
                     inner_angle=22, outer_angle=44, label=""):
    """Place a spot light."""
    props = {
        "intensity": intensity,
        "light_color": color,
        "inner_cone_angle": inner_angle,
        "outer_cone_angle": outer_angle,
    }
    return spawn_actor("SpotLight", x, y, z, rotation=rotation, properties=props,
                       label=label or f"SpotLight_{int(x)}_{int(y)}")


def place_directional_light(rotation=(-45, 0, 0), intensity=3.0, label="Sun"):
    """Place a directional light (sun)."""
    return spawn_actor("DirectionalLight", 0, 0, 10000, rotation=rotation,
                       properties={"intensity": intensity}, label=label)


# ---------------------------------------------------------------------------
# Geometry / layout helpers
# ---------------------------------------------------------------------------

def place_grid(actor_class: str, origin: Tuple[float, float, float],
               rows: int, cols: int, spacing: float,
               properties: Dict[str, Any] = None, label_prefix: str = "grid") -> List[PlacedActor]:
    """
    Place actors in a grid pattern.

    Args:
        origin: (x, y, z) of the grid's corner.
        rows/cols: Grid dimensions.
        spacing: Distance between placements in UE units (cm).
    """
    results = []
    ox, oy, oz = origin
    for r in range(rows):
        for c in range(cols):
            x = ox + c * spacing
            y = oy + r * spacing
            label = f"{label_prefix}_{r}_{c}"
            a = spawn_actor(actor_class, x, y, oz, properties=properties or {}, label=label)
            results.append(a)
    return results


def create_zone(name: str, center: Tuple[float, float, float],
                width: float, depth: float, devices: List[dict] = None) -> dict:
    """
    Define a named rectangular zone and optionally place devices within it.

    Devices are specified as: [{"type": "trigger", "offset": (dx, dy, dz), "properties": {...}}, ...]
    """
    cx, cy, cz = center
    zone = {
        "name": name,
        "center": center,
        "bounds": {"min": (cx - width/2, cy - depth/2, cz), "max": (cx + width/2, cy + depth/2, cz)},
        "actors": []
    }

    if LIVE_MODE:
        _plan.add_op("create_zone", name=name, center=list(center), width=width, depth=depth)
    else:
        _plan.add_op("create_zone", name=name, center=list(center), width=width, depth=depth)

    for dev in (devices or []):
        dx, dy, dz = dev.get("offset", (0, 0, 0))
        actor = place_device(
            dev["type"],
            cx + dx, cy + dy, cz + dz,
            properties=dev.get("properties", {}),
            label=f"{name}_{dev['type']}"
        )
        zone["actors"].append(actor)

    log.info(f"Zone '{name}' created at {center}, {width}x{depth}")
    return zone


def create_building(origin: Tuple[float, float, float], width: float, depth: float,
                    floors: int = 1, floor_height: float = 400,
                    wall_class: str = "/FortniteCreative/Prefabs/Wall_Basic.Wall_Basic_C",
                    label: str = "building") -> List[PlacedActor]:
    """
    Create a simple box building using wall prefabs.
    Places 4 walls per floor at the edges of the footprint.
    """
    ox, oy, oz = origin
    actors = []

    for floor in range(floors):
        z = oz + floor * floor_height
        # Four walls: north, south, east, west
        walls = [
            (ox + width/2, oy, z, (0, 0, 0)),    # North
            (ox + width/2, oy + depth, z, (0, 180, 0)),  # South
            (ox, oy + depth/2, z, (0, 90, 0)),    # East
            (ox + width, oy + depth/2, z, (0, -90, 0)),  # West
        ]
        for i, (wx, wy, wz, rot) in enumerate(walls):
            a = spawn_actor(wall_class, wx, wy, wz, rotation=rot,
                            scale=(width/400 if i < 2 else depth/400, 1, 1),
                            label=f"{label}_f{floor}_wall{i}")
            actors.append(a)

    log.info(f"Building '{label}' created: {floors} floors at {origin}")
    return actors


def create_circle_placement(actor_class: str, center: Tuple[float, float, float],
                            radius: float, count: int, face_center: bool = True,
                            label_prefix: str = "circle") -> List[PlacedActor]:
    """Place actors in a circle pattern, optionally facing the center."""
    cx, cy, cz = center
    actors = []
    for i in range(count):
        angle = (2 * math.pi * i) / count
        x = cx + radius * math.cos(angle)
        y = cy + radius * math.sin(angle)
        yaw = math.degrees(math.atan2(cy - y, cx - x)) if face_center else 0
        a = spawn_actor(actor_class, x, y, cz, rotation=(0, yaw, 0),
                        label=f"{label_prefix}_{i}")
        actors.append(a)
    return actors


# ---------------------------------------------------------------------------
# Level / Project operations
# ---------------------------------------------------------------------------

def load_level(level_path: str):
    """Load a level by path."""
    if LIVE_MODE:
        try:
            unreal.EditorLevelLibrary.load_level(level_path)
            log.info(f"Loaded level: {level_path}")
        except Exception as e:
            log.error(f"Failed to load level {level_path}: {e}")
    else:
        _plan.add_op("load_level", path=level_path)
        log.info(f"[PLAN] Load level: {level_path}")


def save_level():
    """Save the current level."""
    if LIVE_MODE:
        try:
            unreal.EditorLevelLibrary.save_current_level()
            log.info("Level saved.")
        except Exception as e:
            log.error(f"Failed to save level: {e}")
    else:
        _plan.add_op("save_level")
        log.info("[PLAN] Save level")


def clear_all_actors(actor_class: str = None):
    """Delete all actors of a given class, or all spawned actors if None."""
    if LIVE_MODE:
        try:
            actors = unreal.EditorLevelLibrary.get_all_level_actors()
            for a in actors:
                if actor_class is None or a.get_class().get_name() == actor_class:
                    a.destroy_actor()
            log.info(f"Cleared actors (filter={actor_class})")
        except Exception as e:
            log.error(f"Failed to clear actors: {e}")
    else:
        _plan.add_op("clear_actors", filter=actor_class)


def get_build_plan() -> BuildPlan:
    """Get the current build plan (offline mode)."""
    return _plan


def export_build_plan(path: str = "build_plan.json") -> dict:
    """Export the build plan to JSON."""
    return _plan.export(path)


# ---------------------------------------------------------------------------
# Commandlet execution helper (for running from CLI outside UEFN)
# ---------------------------------------------------------------------------

def generate_execution_script(build_plan_path: str, output_script: str = "_exec_plan.py"):
    """
    Generate a Python script that replays a build plan inside UEFN.
    This script is what gets passed to ExecutePythonScript.
    """
    plan_data = json.loads(open(build_plan_path).read())

    lines = [
        "# Auto-generated UEFN execution script",
        "import unreal",
        "from uefn_builder import spawn_actor, place_device, place_point_light, save_level",
        "",
    ]

    for actor in plan_data.get("actors", []):
        props_str = json.dumps(actor.get("properties", {}))
        lines.append(
            f'spawn_actor({actor["actor_class"]!r}, {actor["x"]}, {actor["y"]}, {actor["z"]}, '
            f'rotation={tuple(actor["rotation"])}, scale={tuple(actor["scale"])}, '
            f'label={actor["label"]!r}, properties={props_str})'
        )

    lines.append("")
    lines.append("save_level()")
    lines.append('unreal.log("Build plan executed successfully.")')

    with open(output_script, "w") as f:
        f.write("\n".join(lines))

    log.info(f"Generated execution script: {output_script}")
    return output_script


if __name__ == "__main__":
    # Demo: create a sample build plan
    print("UEFN Builder — Demo (plan mode)")
    place_device("trigger", 0, 0, 0, label="test_trigger")
    place_device("spawn pad", 500, 0, 0, label="spawn_1")
    place_point_light(250, 0, 300, intensity=5000, label="light_1")
    create_zone("test_zone", (1000, 1000, 0), 2000, 2000, [
        {"type": "button", "offset": (0, 0, 0)},
        {"type": "barrier", "offset": (500, 0, 0)},
    ])
    export_build_plan()
    print("Done. See build_plan.json")
