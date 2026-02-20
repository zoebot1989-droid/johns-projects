# UEFN Automation Toolkit

Programmatically build Fortnite Creative maps using Python automation with UEFN's built-in Python scripting support.

## Architecture

```
cli.py                  ← Command-line entry point (runs outside UEFN)
├── setup.py            ← Validates environment, enables Python plugin
├── uefn-builder.py     ← Core building API (runs INSIDE UEFN Python env)
├── dead-profit-builder.py  ← DEAD PROFIT map-specific builder
├── verse-deployer.py   ← Deploys Verse scripts to UEFN projects
```

**Two execution contexts:**
1. **Outside UEFN** — `cli.py`, `setup.py`, `verse-deployer.py` run as normal Python scripts
2. **Inside UEFN** — `uefn-builder.py` and `dead-profit-builder.py` run via UEFN's Python console or `ExecutePythonScript` commandlet

## Prerequisites

- **UEFN** installed at `C:\Program Files\Epic Games\UE_5.7`
- **Python 3.9+** on system PATH (for CLI/setup scripts)
- **PythonScriptPlugin** enabled in UEFN (setup.py handles this)

## Quick Start

```bash
# 1. Verify environment and enable Python scripting
python setup.py

# 2. Create a new UEFN project
python cli.py create-project DeadProfit

# 3. Deploy Verse scripts
python cli.py deploy-verse ../dead-profit/verse/

# 4. Build the full DEAD PROFIT map (launches UEFN headless)
python cli.py build-map
```

## How It Works

### Running Python Inside UEFN

UEFN supports the `unreal` Python module via PythonScriptPlugin. Scripts run in-editor via:

1. **Output Log console** — `py "path/to/script.py"` in the UEFN console
2. **Commandlet** — `UnrealEditor-Cmd.exe <project> -ExecutePythonScript="path/to/script.py"`
3. **Startup scripts** — Place in `Content/Python/init_unreal.py`

This toolkit uses method 2 (commandlet) for automation.

### Key Unreal Python Classes

| Class | Purpose |
|-------|---------|
| `unreal.EditorLevelLibrary` | Spawn actors, get/set transforms |
| `unreal.EditorAssetLibrary` | Load/find assets |
| `unreal.EditorLevelSubsystem` | Level management |
| `unreal.GameplayStatics` | World queries |
| `unreal.EditorActorSubsystem` | Actor operations |
| `unreal.LandscapeEditorUtils` | Terrain ops (limited in UEFN) |

### UEFN Limitations vs Full UE5

- **No C++ plugins** — only Verse and limited Python
- **No custom meshes at runtime** — must use Fortnite assets or imports
- **Restricted asset paths** — must reference `/Game/` or Fortnite content paths
- **No direct landscape sculpting API** — use terrain devices or pre-made landscapes
- **Blueprint restrictions** — some BP nodes are disabled in UEFN
- **Verse is preferred** — Epic pushes Verse over Python for game logic

### Workarounds

- **Terrain**: Use `Landscape` device placements + height modifiers instead of raw heightmap API
- **Custom geometry**: Import props via UEFN's asset import, then place programmatically
- **Game logic**: Deploy Verse scripts (this toolkit automates that) rather than Python at runtime
- **Lighting**: Use `unreal.EditorLevelLibrary` to place and configure light actors

## CLI Commands

| Command | Description |
|---------|-------------|
| `create-project <name>` | Create new UEFN project from template |
| `place-device <type> <x> <y> <z>` | Place a device at coordinates |
| `deploy-verse <path>` | Copy Verse files to project |
| `build-map` | Run full DEAD PROFIT builder |
| `validate-verse <path>` | Check Verse syntax |
| `list-devices` | Show available device types |

## File Structure Created by Toolkit

```
<ProjectRoot>/
├── Content/
│   └── Python/
│       └── init_unreal.py      ← Auto-runs on editor load
├── Plugins/
│   └── GameFeatures/
│       └── <ProjectName>/
│           └── Content/
│               └── Verse/      ← Verse scripts go here
└── <ProjectName>.uefnproject
```
