#!/usr/bin/env python3
"""
UEFN Toolkit Setup — Validates environment and enables Python scripting plugin.
Run this first before using any other toolkit scripts.
"""

import os
import sys
import json
import shutil
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
log = logging.getLogger("uefn-setup")

# Paths
UEFN_ROOT = Path(r"C:\Program Files\Epic Games\UE_5.7")
EDITOR_CMD = UEFN_ROOT / "Engine" / "Binaries" / "Win64" / "UnrealEditor-Cmd.exe"
PYTHON_PLUGIN = UEFN_ROOT / "Engine" / "Plugins" / "Experimental" / "PythonScriptPlugin"
PROJECTS_DIR = Path.home() / "Documents" / "Fortnite Projects"
DEFAULT_PLUGINS_CONFIG = UEFN_ROOT / "Engine" / "Config" / "BaseEditor.ini"


def check_uefn_installed() -> bool:
    """Verify UEFN installation exists."""
    if not UEFN_ROOT.exists():
        log.error(f"UEFN not found at {UEFN_ROOT}")
        log.error("Install UEFN via Epic Games Launcher or update UEFN_ROOT path.")
        return False
    log.info(f"UEFN found: {UEFN_ROOT}")
    return True


def check_editor_cmd() -> bool:
    """Verify UnrealEditor-Cmd.exe exists."""
    if not EDITOR_CMD.exists():
        log.error(f"UnrealEditor-Cmd.exe not found at {EDITOR_CMD}")
        return False
    log.info(f"Editor commandlet: {EDITOR_CMD}")
    return True


def check_python_plugin() -> bool:
    """Verify PythonScriptPlugin is available."""
    if not PYTHON_PLUGIN.exists():
        log.error(f"PythonScriptPlugin not found at {PYTHON_PLUGIN}")
        log.error("This plugin may need to be installed separately.")
        return False
    uplugin = PYTHON_PLUGIN / "PythonScriptPlugin.uplugin"
    if uplugin.exists():
        log.info(f"PythonScriptPlugin found: {PYTHON_PLUGIN}")
    else:
        log.warning(f"Plugin dir exists but .uplugin file missing — may still work.")
    return True


def enable_python_plugin_for_project(project_path: Path) -> bool:
    """
    Enable PythonScriptPlugin in a UEFN project's config.
    Modifies DefaultEngine.ini or the .uefnproject file to enable the plugin.
    """
    config_dir = project_path / "Config"
    config_dir.mkdir(parents=True, exist_ok=True)

    engine_ini = config_dir / "DefaultEditorPerProjectUserSettings.ini"

    # Add Python plugin enable entry
    plugin_entry = "\n[/Script/PythonScriptPlugin.PythonScriptPluginSettings]\nbEnableContentBrowserIntegration=True\n"
    startup_entry = "\n[/Script/EditorScriptingUtilities.EditorScriptingSettings]\nStartupScripts=/Game/Python/init_unreal.py\n"

    existing = engine_ini.read_text() if engine_ini.exists() else ""

    if "PythonScriptPlugin" not in existing:
        with open(engine_ini, "a") as f:
            f.write(plugin_entry)
            f.write(startup_entry)
        log.info(f"Enabled PythonScriptPlugin in {engine_ini}")
    else:
        log.info("PythonScriptPlugin already configured.")

    # Also ensure the plugin is listed in .uefnproject if it exists
    uefn_files = list(project_path.glob("*.uefnproject"))
    for uf in uefn_files:
        try:
            data = json.loads(uf.read_text())
            plugins = data.setdefault("Plugins", [])
            if not any(p.get("Name") == "PythonScriptPlugin" for p in plugins):
                plugins.append({"Name": "PythonScriptPlugin", "Enabled": True})
                uf.write_text(json.dumps(data, indent=2))
                log.info(f"Added PythonScriptPlugin to {uf.name}")
        except (json.JSONDecodeError, Exception) as e:
            log.warning(f"Could not modify {uf.name}: {e}")

    return True


def create_python_init(project_path: Path):
    """Create the Content/Python directory and init script."""
    py_dir = project_path / "Content" / "Python"
    py_dir.mkdir(parents=True, exist_ok=True)

    init_script = py_dir / "init_unreal.py"
    if not init_script.exists():
        init_script.write_text(
            '"""\nUEFN Python Init Script\n'
            'This runs automatically when the editor loads (if configured).\n'
            '"""\nimport unreal\n\n'
            'unreal.log("UEFN Toolkit: Python environment initialized.")\n'
        )
        log.info(f"Created init script: {init_script}")


def verify_all() -> bool:
    """Run all checks. Returns True if environment is ready."""
    checks = [
        ("UEFN Installation", check_uefn_installed),
        ("Editor Commandlet", check_editor_cmd),
        ("Python Plugin", check_python_plugin),
    ]

    results = []
    for name, fn in checks:
        ok = fn()
        results.append((name, ok))
        status = "✓" if ok else "✗"
        print(f"  [{status}] {name}")

    all_ok = all(ok for _, ok in results)
    print()
    if all_ok:
        log.info("All checks passed. Environment is ready.")
    else:
        log.error("Some checks failed. Fix issues above before proceeding.")
    return all_ok


def setup_project(project_name: str, project_dir: Path = None) -> Path:
    """Set up a project directory with Python scripting enabled."""
    if project_dir is None:
        project_dir = PROJECTS_DIR / project_name

    project_dir.mkdir(parents=True, exist_ok=True)
    enable_python_plugin_for_project(project_dir)
    create_python_init(project_dir)

    log.info(f"Project '{project_name}' configured at {project_dir}")
    return project_dir


if __name__ == "__main__":
    print("=" * 60)
    print("UEFN Automation Toolkit — Environment Setup")
    print("=" * 60)
    print()

    ok = verify_all()

    if ok and len(sys.argv) > 1:
        project_name = sys.argv[1]
        print(f"\nSetting up project: {project_name}")
        setup_project(project_name)

    sys.exit(0 if ok else 1)
