#!/usr/bin/env python3
"""
Comprehensive validation for AeroPress recipe timers and audio scripts.
Validates:
1. Audio script length matches time_seconds (2.5 words/second rule)
2. Audio scripts start with proper timing phrases
3. No "Start your timer" or "At <timestamp>" phrases
4. Total brew time consistency
5. Audio file references
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Tuple

ROOT = Path(__file__).resolve().parent
RECIPES_DIR = ROOT / "PerfectBrew" / "Resources" / "Recipes" / "AeroPress"

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

# Words per second for TTS (conservative estimate)
WORDS_PER_SECOND = 2.5

# UX-focused thresholds for audio script length
# Based on cognitive load and user attention principles:
# - Too short (<30%): Insufficient guidance, feels rushed
# - Warning (30-50%): Acceptable but could use more content
# - Optimal (50-85%): Comfortable density, room for pauses
# - Warning (85-95%): Getting tight, might feel rushed
# - Too long (>95%): Risk of cutoff, overwhelming

MIN_PERCENT = 0.30  # Minimum 30% of time (ensures basic guidance)
OPTIMAL_MIN = 0.50  # Optimal range starts at 50%
OPTIMAL_MAX = 0.85  # Optimal range ends at 85% (leaves breathing room)
WARNING_MAX = 0.95  # Warning if over 95% (too tight)


def count_words(text: str) -> int:
    """Count words in text."""
    return len(text.split())


def validate_audio_timing(script: str, time_seconds: int) -> Tuple[bool, str, str]:
    """
    Validate audio script fits within time constraint with UX-focused thresholds.
    Returns: (is_valid, severity, message)
    """
    word_count = count_words(script)
    estimated_seconds = word_count / WORDS_PER_SECOND
    percent_used = estimated_seconds / time_seconds if time_seconds > 0 else 0
    
    # Calculate target word ranges
    min_words = int(time_seconds * MIN_PERCENT * WORDS_PER_SECOND)
    optimal_min_words = int(time_seconds * OPTIMAL_MIN * WORDS_PER_SECOND)
    optimal_max_words = int(time_seconds * OPTIMAL_MAX * WORDS_PER_SECOND)
    max_words = int(time_seconds * WARNING_MAX * WORDS_PER_SECOND)
    
    if estimated_seconds > time_seconds:
        return False, "error", (
            f"Script too long: {word_count} words ≈ {estimated_seconds:.1f}s "
            f"({percent_used:.0%} of {time_seconds}s) - WILL CUT OFF"
        )
    elif percent_used < MIN_PERCENT:
        return False, "error", (
            f"Script too short: {word_count} words ≈ {estimated_seconds:.1f}s "
            f"({percent_used:.0%} of {time_seconds}s) - Insufficient guidance. "
            f"Target: {min_words}-{optimal_max_words} words"
        )
    elif percent_used < OPTIMAL_MIN:
        return True, "warning", (
            f"Script could be longer: {word_count} words ≈ {estimated_seconds:.1f}s "
            f"({percent_used:.0%} of {time_seconds}s). "
            f"Optimal: {optimal_min_words}-{optimal_max_words} words for better UX"
        )
    elif percent_used <= OPTIMAL_MAX:
        return True, "ok", (
            f"Optimal length: {word_count} words ≈ {estimated_seconds:.1f}s "
            f"({percent_used:.0%} of {time_seconds}s) - Good balance"
        )
    elif percent_used <= WARNING_MAX:
        return True, "warning", (
            f"Script getting tight: {word_count} words ≈ {estimated_seconds:.1f}s "
            f"({percent_used:.0%} of {time_seconds}s) - Consider trimming slightly"
        )
    else:
        return False, "error", (
            f"Script too long: {word_count} words ≈ {estimated_seconds:.1f}s "
            f"({percent_used:.0%} of {time_seconds}s) - Risk of cutoff"
        )


def validate_timing_phrase(script: str) -> Tuple[bool, str]:
    """Validate audio script starts with proper timing phrase."""
    starts_ok = script.startswith(ALLOWED_STARTERS)
    
    if starts_ok:
        return True, "OK"
    
    # Check if it contains timing phrase later
    has_timing = any(p in script for p in (" seconds", " second"))
    if has_timing:
        return False, "Contains timing phrase but doesn't start with one"
    else:
        return False, "Missing timing phrase (e.g., 'You have X seconds ...' / 'In X seconds ...')"


def validate_recipe(path: Path, recipe: Dict) -> List[Dict]:
    """Validate a single recipe."""
    issues: List[Dict] = []
    recipe_name = recipe.get("title", "Unknown")
    
    # Validate what_to_expect
    wte = recipe.get("what_to_expect") or {}
    script = wte.get("audio_script")
    if script:
        if START_TIMER_RE.search(script):
            issues.append({
                "file": str(path),
                "recipe": recipe_name,
                "location": "what_to_expect.audio_script",
                "severity": "error",
                "issue": "Contains 'Start your timer'",
                "script": script[:100] + "..." if len(script) > 100 else script
            })
        if AT_TIMESTAMP_RE.search(script):
            issues.append({
                "file": str(path),
                "recipe": recipe_name,
                "location": "what_to_expect.audio_script",
                "severity": "error",
                "issue": "Contains 'At <timestamp>'",
                "script": script[:100] + "..." if len(script) > 100 else script
            })
    
    # Validate brewing steps
    steps = recipe.get("brewing_steps") or []
    total_time = 0
    
    for idx, step in enumerate(steps, start=1):
        step_time = step.get("time_seconds", 0)
        total_time += step_time
        script = step.get("audio_script")
        
        if not script:
            issues.append({
                "file": str(path),
                "recipe": recipe_name,
                "location": f"brewing_steps[{idx}].audio_script",
                "severity": "error",
                "issue": "Missing audio_script",
                "time_seconds": step_time
            })
            continue
        
        # Check for problematic phrases
        if START_TIMER_RE.search(script):
            issues.append({
                "file": str(path),
                "recipe": recipe_name,
                "location": f"brewing_steps[{idx}].audio_script",
                "severity": "error",
                "issue": "Contains 'Start your timer'",
                "time_seconds": step_time,
                "script": script[:100] + "..." if len(script) > 100 else script
            })
        
        if AT_TIMESTAMP_RE.search(script):
            issues.append({
                "file": str(path),
                "recipe": recipe_name,
                "location": f"brewing_steps[{idx}].audio_script",
                "severity": "error",
                "issue": "Contains 'At <timestamp>'",
                "time_seconds": step_time,
                "script": script[:100] + "..." if len(script) > 100 else script
            })
        
        # Check timing phrase
        timing_ok, timing_msg = validate_timing_phrase(script)
        if not timing_ok:
            issues.append({
                "file": str(path),
                "recipe": recipe_name,
                "location": f"brewing_steps[{idx}].audio_script",
                "severity": "warning",
                "issue": timing_msg,
                "time_seconds": step_time,
                "script": script[:100] + "..." if len(script) > 100 else script
            })
        
        # Check audio timing
        timing_fit, timing_severity, timing_info = validate_audio_timing(script, step_time)
        if not timing_fit or timing_severity in ("error", "warning"):
            issues.append({
                "file": str(path),
                "recipe": recipe_name,
                "location": f"brewing_steps[{idx}].audio_script",
                "severity": timing_severity,
                "issue": timing_info,
                "time_seconds": step_time,
                "script": script[:100] + "..." if len(script) > 100 else script
            })
    
    # Validate total brew time
    expected_total = recipe.get("parameters", {}).get("total_brew_time_seconds", 0)
    if expected_total > 0 and abs(total_time - expected_total) > 2:  # Allow 2s tolerance
        issues.append({
            "file": str(path),
            "recipe": recipe_name,
            "location": "total_brew_time",
            "severity": "warning",
            "issue": f"Step times sum to {total_time}s but recipe specifies {expected_total}s",
            "calculated": total_time,
            "expected": expected_total
        })
    
    return issues


def main():
    """Main validation function."""
    if not RECIPES_DIR.exists():
        print(f"Error: Recipes directory not found: {RECIPES_DIR}")
        return 1
    
    all_issues: List[Dict] = []
    recipe_count = 0
    
    for path in sorted(RECIPES_DIR.rglob("*.json")):
        try:
            with path.open("r", encoding="utf-8") as f:
                data = json.load(f)
            
            if not isinstance(data, list) or not data:
                continue
            
            recipe = data[0]
            if recipe.get("brewing_method") != "AeroPress":
                continue
            
            recipe_count += 1
            issues = validate_recipe(path, recipe)
            all_issues.extend(issues)
            
        except Exception as e:
            print(f"Error reading {path}: {e}")
            continue
    
    # Print report
    print(f"\n{'='*80}")
    print(f"AeroPress Recipe Validation Report")
    print(f"{'='*80}")
    print(f"Recipes checked: {recipe_count}")
    print(f"Total issues: {len(all_issues)}")
    
    if not all_issues:
        print("\n✅ All AeroPress recipes passed validation!")
        return 0
    
    # Group by severity
    errors = [i for i in all_issues if i["severity"] == "error"]
    warnings = [i for i in all_issues if i["severity"] == "warning"]
    
    print(f"\nErrors: {len(errors)}")
    print(f"Warnings: {len(warnings)}")
    
    # Print errors first
    if errors:
        print(f"\n{'='*80}")
        print("❌ ERRORS (Must Fix - Bad UX):")
        print(f"{'='*80}")
        print("These scripts are too short (<30%) or too long (>95%), causing poor user experience.")
        for issue in errors:
            print(f"\n📁 {Path(issue['file']).name}")
            print(f"   Recipe: {issue['recipe']}")
            print(f"   Location: {issue['location']}")
            print(f"   ⚠️  {issue['issue']}")
            if 'time_seconds' in issue:
                print(f"   Time: {issue['time_seconds']}s")
            if 'script' in issue:
                print(f"   Script: {issue['script']}")
    
    # Print warnings
    if warnings:
        print(f"\n{'='*80}")
        print("⚠️  WARNINGS (Consider Improving - Suboptimal UX):")
        print(f"{'='*80}")
        print("These scripts are acceptable but could be improved for better user experience.")
        print("30-50%: Could use more content | 85-95%: Getting tight")
        for issue in warnings:
            print(f"\n📁 {Path(issue['file']).name}")
            print(f"   Recipe: {issue['recipe']}")
            print(f"   Location: {issue['location']}")
            print(f"   💡 {issue['issue']}")
            if 'time_seconds' in issue:
                print(f"   Time: {issue['time_seconds']}s")
    
    # Summary by recipe
    print(f"\n{'='*80}")
    print("Summary by Recipe:")
    print(f"{'='*80}")
    print("✅ = Optimal (50-85% fill) | ⚠️ = Needs improvement | ❌ = Critical issues")
    recipe_issues = {}
    for issue in all_issues:
        recipe = issue['recipe']
        if recipe not in recipe_issues:
            recipe_issues[recipe] = {"errors": 0, "warnings": 0, "ok": 0}
        severity = issue['severity']
        if severity == "ok":
            recipe_issues[recipe]["ok"] += 1
        elif severity == "error":
            recipe_issues[recipe]["errors"] += 1
        else:
            recipe_issues[recipe]["warnings"] += 1
    
    for recipe, counts in sorted(recipe_issues.items()):
        total = counts["errors"] + counts["warnings"] + counts["ok"]
        status = "❌" if counts["errors"] > 0 else "⚠️" if counts["warnings"] > 0 else "✅"
        print(f"{status} {recipe}: {counts['errors']} errors, {counts['warnings']} warnings, {counts['ok']} optimal")
    
    print(f"\n{'='*80}")
    print("UX Guidelines for Audio Script Length:")
    print(f"{'='*80}")
    print("• <30% of time: ERROR - Too short, insufficient guidance")
    print("• 30-50% of time: WARNING - Acceptable but could use more content")
    print("• 50-85% of time: ✅ OPTIMAL - Good balance, comfortable density")
    print("• 85-95% of time: WARNING - Getting tight, consider trimming")
    print("• >95% of time: ERROR - Too long, risk of cutoff")
    print("\nRationale: Users need breathing room to process instructions.")
    print("Filling 100% creates cognitive overload and risks audio cutoff.")
    
    return 1 if errors else 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
