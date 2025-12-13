#!/usr/bin/env python3
"""
migrate_spanish_translations.py

Injects Spanish translations from recipes_es.json into individual recipe JSON files.
This script reads translations and updates recipe files with _es fields.

Usage:
    python3 migrate_spanish_translations.py [--dry-run]
    
Options:
    --dry-run   Preview changes without modifying files
"""

import json
import os
import sys
import re
from pathlib import Path

# Paths
TRANSLATIONS_FILE = "PerfectBrew/Resources/Translations/recipes_es.json"
RECIPES_DIR = "PerfectBrew/Resources/Recipes"


def load_translations():
    """Load Spanish translations from the master file."""
    if not os.path.exists(TRANSLATIONS_FILE):
        print(f"❌ Translations file not found: {TRANSLATIONS_FILE}")
        return {}
    
    with open(TRANSLATIONS_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    return data.get("translations", {})


def get_recipe_key(filepath):
    """
    Generate a translation key from a recipe filepath.
    e.g., AeroPress/Tim_Wendelboe/AeroPress_Tim_Wendelboe_single_serve.json
          -> AeroPress_Tim_Wendelboe_single_serve
    """
    filename = os.path.basename(filepath)
    return filename.replace('.json', '')


def find_all_recipes(base_dir):
    """Find all recipe JSON files recursively."""
    recipes = []
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.json'):
                recipes.append(os.path.join(root, file))
    return recipes


def inject_single_recipe(recipe, translation):
    """
    Inject Spanish translation into a single recipe dict.
    Returns True if any modification was made.
    """
    modified = False
    
    # Title
    if "title_es" in translation:
        recipe["title_es"] = translation["title_es"]
        modified = True
    
    # Notes
    if "notes_es" in translation:
        recipe["notes_es"] = translation["notes_es"]
        modified = True
    
    # Preparation steps
    if "preparation_steps_es" in translation:
        recipe["preparation_steps_es"] = translation["preparation_steps_es"]
        modified = True
    
    # Brewing steps
    if "brewing_steps" in translation and "brewing_steps" in recipe:
        for i, step_trans in enumerate(translation["brewing_steps"]):
            if i < len(recipe["brewing_steps"]):
                step = recipe["brewing_steps"][i]
                if "instruction_es" in step_trans:
                    step["instruction_es"] = step_trans["instruction_es"]
                    modified = True
                if "short_instruction_es" in step_trans:
                    step["short_instruction_es"] = step_trans["short_instruction_es"]
                    modified = True
                if "audio_script_es" in step_trans:
                    step["audio_script_es"] = step_trans["audio_script_es"]
                    modified = True
                if "audio_file_name_es" in step_trans:
                    step["audio_file_name_es"] = step_trans["audio_file_name_es"]
                    modified = True
    
    # What to expect
    if "what_to_expect" in translation and "what_to_expect" in recipe:
        wte = translation["what_to_expect"]
        if "description_es" in wte:
            recipe["what_to_expect"]["description_es"] = wte["description_es"]
            modified = True
        if "audio_script_es" in wte:
            recipe["what_to_expect"]["audio_script_es"] = wte["audio_script_es"]
            modified = True
        if "audio_file_name_es" in wte:
            recipe["what_to_expect"]["audio_file_name_es"] = wte["audio_file_name_es"]
            modified = True
    
    return modified


def inject_translation(recipe_path, translation, dry_run=False):
    """
    Inject Spanish translation into a recipe JSON file.
    Handles both single recipe objects and arrays of recipes.
    """
    with open(recipe_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    modified = False
    
    # Handle array of recipes (most common case)
    if isinstance(data, list):
        for recipe in data:
            if inject_single_recipe(recipe, translation):
                modified = True
    # Handle single recipe object
    elif isinstance(data, dict):
        if inject_single_recipe(data, translation):
            modified = True
    
    if modified:
        if dry_run:
            print(f"  [DRY RUN] Would update: {recipe_path}")
        else:
            with open(recipe_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            print(f"  ✅ Updated: {recipe_path}")
    
    return modified


def main():
    dry_run = "--dry-run" in sys.argv
    
    print("=" * 60)
    print("Spanish Translation Migration Script")
    print("=" * 60)
    
    if dry_run:
        print("⚠️  DRY RUN MODE - No files will be modified")
    
    # Load translations
    translations = load_translations()
    if not translations:
        print("❌ No translations found. Exiting.")
        return 1
    
    print(f"📚 Loaded {len(translations)} translation entries")
    
    # Find all recipes
    recipes = find_all_recipes(RECIPES_DIR)
    print(f"📂 Found {len(recipes)} recipe files")
    
    # Process each recipe
    updated_count = 0
    for recipe_path in recipes:
        key = get_recipe_key(recipe_path)
        
        if key in translations:
            print(f"\n🔄 Processing: {key}")
            if inject_translation(recipe_path, translations[key], dry_run):
                updated_count += 1
    
    print("\n" + "=" * 60)
    print(f"✅ Migration complete: {updated_count} recipes {'would be ' if dry_run else ''}updated")
    print("=" * 60)
    
    return 0


if __name__ == "__main__":
    sys.exit(main())

