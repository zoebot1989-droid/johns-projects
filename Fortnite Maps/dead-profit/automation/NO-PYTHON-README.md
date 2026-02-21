# Why There Are No Python Scripts

UEFN **does not support** Python scripting, Editor Utility Widgets, or Blueprints.

Unlike standard Unreal Engine 5, UEFN strips:
- ❌ Python Editor Scripting (`unreal` module)
- ❌ Editor Utility Widgets/Blueprints
- ❌ C++ plugins
- ❌ Command-line/headless builds
- ❌ Third-party plugins

**The only scripting language in UEFN is Verse.** All automation happens at runtime via Verse scripts that spawn props, control devices, and manage game logic.

The JSON config files in `config/` are **planning documents for you** (the human). Edit them to plan your layout, then translate the positions into the Verse data arrays.

Future possibility: If Epic adds Python support to UEFN, the `auto-layout.py`, `batch-import.py`, and `zone-setup.py` scripts from the original plan would become viable. For now, Verse is all we have.
