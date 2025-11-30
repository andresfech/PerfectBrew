#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RECIPES_DIR = ROOT / "PerfectBrew" / "Resources" / "Recipes"

START_TIMER_RE = re.compile(r"\bStart (your )?timer\b", re.IGNORECASE)
AT_TIMESTAMP_RE = re.compile(r"\bAt\s+\d(?::\d{2})?", re.IGNORECASE)


def load_recipe(path: Path):
    with path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    return data


def save_recipe(path: Path, data):
    # Preserve formatting: two-space indentation and trailing newline
    text = json.dumps(data, ensure_ascii=False, indent=2)
    path.write_text(text + "\n", encoding="utf-8")


def normalize_script(text: str) -> str:
    # Remove "Start your timer"
    text = START_TIMER_RE.sub("", text).strip()

    # Remove leading "In X seconds, you should have ..." redundancy - keep as-is
    # Replace "At m:ss" references by removing the timestamp phrasing
    text = AT_TIMESTAMP_RE.sub("", text)
    text = re.sub(r"\s{2,}", " ", text).strip(", .")

    # Ensure period at end
    if text and not text.endswith(('.', '!', '?')):
        text += "."
    return text


def process_file(path: Path) -> int:
    changed = 0
    data = load_recipe(path)
    if not isinstance(data, list) or not data:
        return 0
    recipe = data[0]

    # what_to_expect
    wte = recipe.get("what_to_expect")
    if isinstance(wte, dict) and wte.get("audio_script"):
        new = normalize_script(wte["audio_script"])
        if new != wte["audio_script"]:
            wte["audio_script"] = new
            changed += 1

    # steps
    for step in recipe.get("brewing_steps", []):
        s = step.get("audio_script")
        if not s:
            continue
        new = normalize_script(s)
        if new != s:
            step["audio_script"] = new
            changed += 1

    if changed:
        save_recipe(path, data)
    return changed


def main():
    total = 0
    for path in RECIPES_DIR.rglob("*.json"):
        try:
            total += process_file(path)
        except Exception:
            continue
    print(f"Updated audio_script fields: {total}")


if __name__ == "__main__":
    main()









