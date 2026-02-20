#!/usr/bin/env python3
"""
UEFN Toolkit CLI — Command-line interface for AI-driven map building.

Usage:
    python cli.py create-project <name>
    python cli.py place-device <type> <x> <y> <z> [--properties JSON]
    python cli.py deploy-verse <source_dir> [--project NAME]
    python cli.py validate-verse <source_dir>
    python cli.py build-map [--plan-only]
    python cli.py run-plan <plan.json> [--project PATH]
    python cli.py list-devices
    python cli.py setup
"""

import argparse
import json
import logging
import subprocess
import sys
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="[CLI] %(levelname)s: %(message)s")
log = logging.getLogger("cli")

TOOLKIT_DIR = Path(__file__).parent
UEFN_ROOT = Path(r"C:\Program Files\Epic Games\UE_5.7")
EDITOR_CMD = UEFN_ROOT / "Engine" / "Binaries" / "Win64" / "UnrealEditor-Cmd.exe"


def cmd_setup(args):
    """Run environment setup checks."""
    from setup import verify_all
    ok = verify_all()
    sys.exit(0 if ok else 1)


def cmd_create_project(args):
    """Create and configure a new UEFN project."""
    from setup import setup_project
    project_dir = setup_project(args.name)
    print(f"Project created at: {project_dir}")
    print(f"Next: Open in UEFN or use 'python cli.py build-map' to build.")


def cmd_place_device(args):
    """Place a single device (generates a mini build plan or runs live)."""
    from uefn_builder import place_device, export_build_plan

    properties = {}
    if args.properties:
        try:
            properties = json.loads(args.properties)
        except json.JSONDecodeError:
            log.error(f"Invalid JSON for properties: {args.properties}")
            sys.exit(1)

    label = args.label or f"{args.type}_{int(args.x)}_{int(args.y)}"
    place_device(args.type, args.x, args.y, args.z, properties=properties, label=label)

    plan_path = TOOLKIT_DIR / "single_device_plan.json"
    export_build_plan(str(plan_path))
    print(f"Device plan saved to {plan_path}")

    if args.execute and args.project:
        _execute_plan(plan_path, args.project)


def cmd_deploy_verse(args):
    """Deploy Verse files to a UEFN project."""
    from verse_deployer import deploy_verse
    ok = deploy_verse(
        args.source_dir,
        project_name=args.project,
        project_path=args.project_path,
        validate=not args.skip_validation,
        dry_run=args.dry_run,
    )
    sys.exit(0 if ok else 1)


def cmd_validate_verse(args):
    """Validate Verse syntax without deploying."""
    from verse_deployer import validate_verse_directory
    results = validate_verse_directory(Path(args.source_dir))
    total = sum(len(v) for v in results.values())

    if total == 0:
        print(f"✓ All {len(results)} file(s) passed validation.")
    else:
        print(f"✗ {total} issue(s) in {len(results)} file(s).")
    sys.exit(0 if total == 0 else 1)


def cmd_build_map(args):
    """Run the full DEAD PROFIT map builder."""
    from dead_profit_builder import build_all
    build_all()

    if not args.plan_only and args.project:
        plan_path = TOOLKIT_DIR / "dead_profit_build_plan.json"
        if plan_path.exists():
            _execute_plan(plan_path, args.project)


def cmd_run_plan(args):
    """Execute a build plan JSON inside UEFN."""
    plan_path = Path(args.plan)
    if not plan_path.exists():
        log.error(f"Plan file not found: {plan_path}")
        sys.exit(1)

    if not args.project:
        log.error("--project is required to execute a plan")
        sys.exit(1)

    _execute_plan(plan_path, args.project)


def cmd_list_devices(args):
    """List all known device types."""
    # Import the device map from uefn_builder
    devices = {
        "button": "Interactive button device",
        "trigger": "Invisible trigger zone",
        "item granter": "Grants items to players",
        "spawn pad": "Player spawn point",
        "barrier": "Invisible/visible barrier",
        "creature spawner": "Spawns AI creatures",
        "hud message": "Displays on-screen messages",
        "timer": "Countdown/countup timer",
        "score manager": "Manages player scores",
        "elimination manager": "Tracks eliminations",
        "channel": "Inter-device communication",
        "vending machine": "Item vending machine",
        "damage zone": "Deals damage in an area",
        "music sequencer": "Plays music sequences",
        "teleporter": "Teleports players",
        "player checkpoint": "Checkpoint/respawn point",
        "conditional button": "Button with conditions",
        "skydome": "Sky/weather/time-of-day control",
    }

    print(f"\n{'Device Type':<25} Description")
    print("-" * 60)
    for name, desc in sorted(devices.items()):
        print(f"  {name:<23} {desc}")
    print(f"\nTotal: {len(devices)} device types")
    print("Use raw asset paths for devices not in this list.")


def _execute_plan(plan_path: Path, project_path: str):
    """Execute a build plan by generating a script and running it in UEFN."""
    from uefn_builder import generate_execution_script

    exec_script = TOOLKIT_DIR / "_exec_plan.py"
    generate_execution_script(str(plan_path), str(exec_script))

    if not EDITOR_CMD.exists():
        log.error(f"UnrealEditor-Cmd.exe not found at {EDITOR_CMD}")
        log.info(f"Generated script at {exec_script} — run manually in UEFN Python console.")
        return

    # Build the commandlet invocation
    cmd = [
        str(EDITOR_CMD),
        project_path,
        f'-ExecutePythonScript="{exec_script}"',
        "-stdout",
        "-unattended",
        "-nosplash",
    ]

    log.info(f"Executing in UEFN: {' '.join(cmd)}")
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        if result.returncode == 0:
            log.info("UEFN execution completed successfully.")
        else:
            log.error(f"UEFN execution failed (code {result.returncode})")
            if result.stderr:
                log.error(result.stderr[:2000])
    except subprocess.TimeoutExpired:
        log.error("UEFN execution timed out (300s)")
    except FileNotFoundError:
        log.error("Could not launch UnrealEditor-Cmd.exe")
        log.info(f"Run manually: py \"{exec_script}\" in the UEFN Python console")


def main():
    parser = argparse.ArgumentParser(
        description="UEFN Automation Toolkit CLI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    sub = parser.add_subparsers(dest="command", help="Available commands")

    # setup
    sub.add_parser("setup", help="Check environment and dependencies")

    # create-project
    p = sub.add_parser("create-project", help="Create a new UEFN project")
    p.add_argument("name", help="Project name")

    # place-device
    p = sub.add_parser("place-device", help="Place a device at coordinates")
    p.add_argument("type", help="Device type (e.g. 'trigger', 'button')")
    p.add_argument("x", type=float)
    p.add_argument("y", type=float)
    p.add_argument("z", type=float)
    p.add_argument("--properties", help="JSON string of properties", default=None)
    p.add_argument("--label", help="Actor label", default=None)
    p.add_argument("--execute", action="store_true", help="Execute in UEFN immediately")
    p.add_argument("--project", help="Project path for execution")

    # deploy-verse
    p = sub.add_parser("deploy-verse", help="Deploy Verse files to project")
    p.add_argument("source_dir", help="Directory containing .verse files")
    p.add_argument("--project", help="Project name to search for")
    p.add_argument("--project-path", help="Direct path to project")
    p.add_argument("--skip-validation", action="store_true")
    p.add_argument("--dry-run", action="store_true")

    # validate-verse
    p = sub.add_parser("validate-verse", help="Validate Verse syntax")
    p.add_argument("source_dir", help="Directory containing .verse files")

    # build-map
    p = sub.add_parser("build-map", help="Build the full DEAD PROFIT map")
    p.add_argument("--plan-only", action="store_true", help="Generate plan JSON only, don't execute")
    p.add_argument("--project", help="Project path for execution")

    # run-plan
    p = sub.add_parser("run-plan", help="Execute a build plan JSON in UEFN")
    p.add_argument("plan", help="Path to build plan JSON")
    p.add_argument("--project", help="Project path (required)")

    # list-devices
    sub.add_parser("list-devices", help="List available device types")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    commands = {
        "setup": cmd_setup,
        "create-project": cmd_create_project,
        "place-device": cmd_place_device,
        "deploy-verse": cmd_deploy_verse,
        "validate-verse": cmd_validate_verse,
        "build-map": cmd_build_map,
        "run-plan": cmd_run_plan,
        "list-devices": cmd_list_devices,
    }

    fn = commands.get(args.command)
    if fn:
        fn(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
