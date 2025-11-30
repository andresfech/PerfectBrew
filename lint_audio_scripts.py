#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RECIPES_DIR = ROOT / "PerfectBrew" / "Resources" / "Recipes"

# Allowed starters for timing phrases
ALLOWED_STARTERS = (
    "In ",            # In 15 seconds, ...
    "You have ",      # You have 15 seconds to ...
    "Now wait ",      # Now wait 15 seconds for ...
    "Take ",          # Take 15 seconds to ...
    "Finally, ",      # Finally, ... You have 15 seconds ... (allow final)
)

# Problematic phrases
START_TIMER_RE = re.compile(r"\bStart (your )?timer\b", re.IGNORECASE)
AT_TIMESTAMP_RE = re.compile(r"\bAt\s+\d(?::\d{2})?", re.IGNORECASE)  # At 1:20 / At 90
NOTES_WAV_RE = re.compile(r"notes\.wav\b", re.IGNORECASE)


from typing import Optional


def iter_recipe_files(limit_to_method: Optional[str] = None):
    if not RECIPES_DIR.exists():
        return
    for path in RECIPES_DIR.rglob("*.json"):
        try:
            with path.open("r", encoding="utf-8") as f:
                data = json.load(f)
            if not isinstance(data, list) or not data:
                continue
            recipe = data[0]
            if limit_to_method and recipe.get("brewing_method") != limit_to_method:
                continue
            yield path, recipe
        except Exception:
            # Skip unreadable/invalid files
            continue


def lint_recipe(path: Path, recipe: dict) -> list[dict]:
    issues: list[dict] = []

    # what_to_expect
    wte = recipe.get("what_to_expect") or {}
    script = wte.get("audio_script")
    if script:
        if START_TIMER_RE.search(script):
            issues.append({"file": str(path), "location": "what_to_expect.audio_script", "issue": "Contains 'Start your timer'"})
        if AT_TIMESTAMP_RE.search(script):
            issues.append({"file": str(path), "location": "what_to_expect.audio_script", "issue": "Contains 'At <timestamp>'"})

    # steps
    steps = recipe.get("brewing_steps") or []
    for idx, step in enumerate(steps, start=1):
        s = step.get("audio_script")
        if not s:
            issues.append({"file": str(path), "location": f"brewing_steps[{idx}].audio_script", "issue": "Missing audio_script"})
            continue

        if START_TIMER_RE.search(s):
            issues.append({"file": str(path), "location": f"brewing_steps[{idx}].audio_script", "issue": "Contains 'Start your timer'"})
        if AT_TIMESTAMP_RE.search(s):
            issues.append({"file": str(path), "location": f"brewing_steps[{idx}].audio_script", "issue": "Contains 'At <timestamp>'"})

        # Should begin with a timing phrase or "Finally," variant
        starts_ok = s.startswith(ALLOWED_STARTERS)
        if not starts_ok:
            # Allow short imperative if duration is 0 (rare) or if sentence later contains a timing phrase
            if not any(p in s for p in (" seconds", " second")):
                issues.append({"file": str(path), "location": f"brewing_steps[{idx}].audio_script", "issue": "Does not start with timing phrase (e.g., 'You have X seconds ...' / 'In X seconds ...')"})

    return issues


def main():
    only = None
    if len(sys.argv) > 1:
        only = sys.argv[1]

    all_issues: list[dict] = []
    for path, recipe in iter_recipe_files(limit_to_method=None if only == "all" else None):
        all_issues.extend(lint_recipe(path, recipe))

    if not all_issues:
        print("No audio_script issues found.")
        return 0

    # Print report
    for issue in all_issues:
        print(f"{issue['file']} :: {issue['location']} :: {issue['issue']}")
    print(f"\nTotal issues: {len(all_issues)}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())


