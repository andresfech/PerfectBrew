#!/usr/bin/env python3
"""
clean_partial_translations.py

Removes all partial Spanish translations from recipe JSONs to start fresh.
This eliminates the "Spanglish" problem.

Usage:
    python3 clean_partial_translations.py --method AeroPress
    python3 clean_partial_translations.py --method V60
    python3 clean_partial_translations.py --method French_Press
    python3 clean_partial_translations.py --method Chemex
    python3 clean_partial_translations.py --all
"""

import json
import os
import sys
import argparse

RECIPES_DIR = "PerfectBrew/Resources/Recipes"

# Fields to remove (Spanish translations)
ES_FIELDS_RECIPE = ["title_es", "notes_es", "preparation_steps_es"]
ES_FIELDS_STEP = ["instruction_es", "short_instruction_es", "audio_script_es", "audio_file_name_es"]
ES_FIELDS_WTE = ["description_es", "audio_script_es", "audio_file_name_es"]


def clean_recipe(recipe: dict) -> dict:
    """Remove all _es fields from a recipe."""
    # Remove top-level _es fields
    for field in ES_FIELDS_RECIPE:
        if field in recipe:
            del recipe[field]
    
    # Clean brewing_steps
    if "brewing_steps" in recipe:
        for step in recipe["brewing_steps"]:
            for field in ES_FIELDS_STEP:
                if field in step:
                    del step[field]
    
    # Clean what_to_expect
    if "what_to_expect" in recipe and isinstance(recipe["what_to_expect"], dict):
        for field in ES_FIELDS_WTE:
            if field in recipe["what_to_expect"]:
                del recipe["what_to_expect"][field]
    
    return recipe


def clean_file(filepath: str, dry_run: bool = False) -> bool:
    """Clean a single recipe file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        modified = False
        
        # Handle array of recipes
        if isinstance(data, list):
            for recipe in data:
                # Check if any _es fields exist
                has_es = any(field in recipe for field in ES_FIELDS_RECIPE)
                if "brewing_steps" in recipe:
                    for step in recipe["brewing_steps"]:
                        has_es = has_es or any(field in step for field in ES_FIELDS_STEP)
                if "what_to_expect" in recipe and isinstance(recipe["what_to_expect"], dict):
                    has_es = has_es or any(field in recipe["what_to_expect"] for field in ES_FIELDS_WTE)
                
                if has_es:
                    clean_recipe(recipe)
                    modified = True
        else:
            has_es = any(field in data for field in ES_FIELDS_RECIPE)
            if has_es:
                clean_recipe(data)
                modified = True
        
        if modified:
            if dry_run:
                print(f"  [DRY RUN] Would clean: {filepath}")
            else:
                with open(filepath, 'w', encoding='utf-8') as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)
                print(f"  ✅ Cleaned: {filepath}")
        
        return modified
    except Exception as e:
        print(f"  ❌ Error: {filepath} - {e}")
        return False


def clean_method(method: str, dry_run: bool = False) -> int:
    """Clean all recipes for a specific brewing method."""
    method_dir = os.path.join(RECIPES_DIR, method)
    
    if not os.path.exists(method_dir):
        print(f"❌ Method directory not found: {method_dir}")
        return 0
    
    print(f"\n🧹 Cleaning {method} recipes...")
    
    cleaned = 0
    for root, dirs, files in os.walk(method_dir):
        for file in files:
            if file.endswith('.json'):
                filepath = os.path.join(root, file)
                if clean_file(filepath, dry_run):
                    cleaned += 1
    
    print(f"   Cleaned {cleaned} files in {method}")
    return cleaned


def main():
    parser = argparse.ArgumentParser(description='Clean partial Spanish translations')
    parser.add_argument('--method', '-m', help='Brewing method to clean (AeroPress, V60, French_Press, Chemex)')
    parser.add_argument('--all', '-a', action='store_true', help='Clean all methods')
    parser.add_argument('--dry-run', '-d', action='store_true', help='Preview without modifying')
    
    args = parser.parse_args()
    
    print("=" * 60)
    print("Clean Partial Spanish Translations")
    print("=" * 60)
    
    if args.dry_run:
        print("⚠️  DRY RUN MODE - No files will be modified\n")
    
    methods = []
    if args.all:
        methods = ["AeroPress", "V60", "French_Press", "Chemex"]
    elif args.method:
        methods = [args.method]
    else:
        print("Please specify --method or --all")
        sys.exit(1)
    
    total_cleaned = 0
    for method in methods:
        total_cleaned += clean_method(method, args.dry_run)
    
    print("\n" + "=" * 60)
    print(f"✅ Total: {total_cleaned} files {'would be ' if args.dry_run else ''}cleaned")
    print("=" * 60)


if __name__ == "__main__":
    main()


