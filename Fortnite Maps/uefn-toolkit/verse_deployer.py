"""
Verse Deployer — Copies Verse source files into a UEFN project's expected directory structure
and performs basic syntax validation.
"""

import os
import re
import sys
import shutil
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO, format="[VerseDeployer] %(levelname)s: %(message)s")
log = logging.getLogger("verse-deployer")

# Default project search paths
PROJECTS_DIR = Path.home() / "Documents" / "Fortnite Projects"


def find_project(project_name: str) -> Path:
    """Locate a UEFN project directory by name."""
    # Check common locations
    candidates = [
        PROJECTS_DIR / project_name,
        Path.cwd() / project_name,
    ]
    for c in candidates:
        if c.exists():
            return c
    # Search for .uefnproject file
    for d in PROJECTS_DIR.iterdir() if PROJECTS_DIR.exists() else []:
        if d.is_dir() and list(d.glob("*.uefnproject")):
            if project_name.lower() in d.name.lower():
                return d
    raise FileNotFoundError(f"Project '{project_name}' not found. Searched: {candidates}")


def get_verse_dir(project_path: Path) -> Path:
    """
    Get the Verse content directory for a UEFN project.
    UEFN expects Verse files under:
      <Project>/Plugins/GameFeatures/<ProjectName>/Content/Verse/
    or sometimes:
      <Project>/Content/Verse/
    """
    project_name = project_path.name

    # Primary: GameFeatures plugin path
    gf_verse = project_path / "Plugins" / "GameFeatures" / project_name / "Content" / "Verse"
    if gf_verse.exists():
        return gf_verse

    # Secondary: direct Content/Verse
    content_verse = project_path / "Content" / "Verse"
    if content_verse.exists():
        return content_verse

    # Default to GameFeatures path and create it
    gf_verse.mkdir(parents=True, exist_ok=True)
    log.info(f"Created Verse directory: {gf_verse}")
    return gf_verse


def validate_verse_file(filepath: Path) -> list:
    """
    Basic Verse syntax validation. Returns list of issues found.
    This is NOT a full compiler — just catches common mistakes.
    """
    issues = []
    text = filepath.read_text(encoding="utf-8", errors="replace")
    lines = text.split("\n")

    # Track indentation and braces
    brace_depth = 0
    in_block_comment = False

    for i, line in enumerate(lines, 1):
        stripped = line.strip()

        # Skip empty lines and comments
        if not stripped or stripped.startswith("#"):
            continue

        # Block comment tracking (Verse uses # for line comments)
        # Verse doesn't have block comments, but track anyway

        # Check: unmatched braces
        brace_depth += stripped.count("{") - stripped.count("}")

        # Check: common Verse keywords are lowercase
        if re.match(r'^(Class|Function|Var|If|Else|For|Loop|Return)\b', stripped):
            issues.append(f"Line {i}: Verse keywords should be lowercase: '{stripped.split()[0]}'")

        # Check: missing := in variable declarations
        if re.match(r'^\s*var\s+\w+\s*=', stripped) and ':=' not in stripped:
            issues.append(f"Line {i}: Variable assignment should use ':=' not '='")

        # Check: class definition syntax
        if stripped.startswith("class") and ":" not in stripped and "{" not in stripped:
            issues.append(f"Line {i}: Class definition may be missing ':' or body")

        # Check: function missing parens
        if re.match(r'^\s*(public\s+|private\s+)?[\w]+\s*\(', stripped):
            if stripped.count("(") != stripped.count(")"):
                issues.append(f"Line {i}: Unmatched parentheses")

        # Check: using 'self' (Verse uses 'Self')
        if re.search(r'\bself\.', stripped):
            issues.append(f"Line {i}: Use 'Self' (capital S) not 'self' in Verse")

        # Check: semicolons (Verse doesn't use them)
        if stripped.endswith(";") and not stripped.startswith("#"):
            issues.append(f"Line {i}: Verse doesn't use semicolons")

    if brace_depth != 0:
        issues.append(f"Unmatched braces: depth ended at {brace_depth} (expected 0)")

    return issues


def validate_verse_directory(source_dir: Path) -> dict:
    """Validate all .verse files in a directory. Returns {filename: [issues]}."""
    results = {}
    verse_files = list(source_dir.rglob("*.verse"))

    if not verse_files:
        log.warning(f"No .verse files found in {source_dir}")
        return results

    for vf in verse_files:
        issues = validate_verse_file(vf)
        results[str(vf.relative_to(source_dir))] = issues
        if issues:
            log.warning(f"{vf.name}: {len(issues)} issue(s) found")
            for issue in issues:
                log.warning(f"  {issue}")
        else:
            log.info(f"{vf.name}: OK")

    return results


def deploy_verse(source_dir: str, project_path: str = None, project_name: str = None,
                 validate: bool = True, dry_run: bool = False) -> bool:
    """
    Deploy Verse files from source_dir into a UEFN project.

    Args:
        source_dir: Path to directory containing .verse files.
        project_path: Direct path to project (optional).
        project_name: Project name to search for (optional).
        validate: Run syntax validation before copying.
        dry_run: Log what would happen without actually copying.

    Returns:
        True if deployment succeeded.
    """
    source = Path(source_dir)
    if not source.exists():
        log.error(f"Source directory not found: {source}")
        return False

    # Find project
    if project_path:
        proj = Path(project_path)
    elif project_name:
        try:
            proj = find_project(project_name)
        except FileNotFoundError as e:
            log.error(str(e))
            return False
    else:
        log.error("Must specify either project_path or project_name")
        return False

    verse_files = list(source.rglob("*.verse"))
    if not verse_files:
        log.error(f"No .verse files found in {source}")
        return False

    log.info(f"Found {len(verse_files)} Verse file(s) to deploy")

    # Validate
    if validate:
        log.info("Validating Verse files...")
        results = validate_verse_directory(source)
        total_issues = sum(len(v) for v in results.values())
        if total_issues > 0:
            log.warning(f"Validation found {total_issues} issue(s). Proceeding anyway (non-fatal).")

    # Get target directory
    target = get_verse_dir(proj)
    log.info(f"Deploy target: {target}")

    # Copy files preserving directory structure
    copied = 0
    for vf in verse_files:
        rel = vf.relative_to(source)
        dest = target / rel
        dest.parent.mkdir(parents=True, exist_ok=True)

        if dry_run:
            log.info(f"[DRY RUN] Would copy: {rel} → {dest}")
        else:
            shutil.copy2(vf, dest)
            log.info(f"Copied: {rel}")
        copied += 1

    # Also copy any .json manifest files
    for jf in source.rglob("*.json"):
        rel = jf.relative_to(source)
        dest = target / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        if not dry_run:
            shutil.copy2(jf, dest)

    action = "Would deploy" if dry_run else "Deployed"
    log.info(f"{action} {copied} Verse file(s) to {target}")
    return True


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python verse_deployer.py <source_dir> [--project-name NAME | --project-path PATH]")
        print("       python verse_deployer.py <source_dir> --validate-only")
        sys.exit(1)

    source = sys.argv[1]

    if "--validate-only" in sys.argv:
        results = validate_verse_directory(Path(source))
        total = sum(len(v) for v in results.values())
        print(f"\nValidation complete: {total} issue(s) in {len(results)} file(s)")
        sys.exit(0 if total == 0 else 1)

    project_name = None
    project_path = None
    for i, arg in enumerate(sys.argv):
        if arg == "--project-name" and i + 1 < len(sys.argv):
            project_name = sys.argv[i + 1]
        elif arg == "--project-path" and i + 1 < len(sys.argv):
            project_path = sys.argv[i + 1]

    if not project_name and not project_path:
        print("Error: Specify --project-name or --project-path")
        sys.exit(1)

    ok = deploy_verse(source, project_path=project_path, project_name=project_name)
    sys.exit(0 if ok else 1)
