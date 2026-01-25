#!/usr/bin/env python3
"""
inject_manual_translations.py

Injects complete manual Spanish translations from manual_translations_es.json
into individual recipe JSON files. Only injects 100% Spanish content.

Usage:
    python3 inject_manual_translations.py
"""

import json
import os
import glob

TRANSLATIONS_FILE = "PerfectBrew/Resources/Translations/manual_translations_es.json"
RECIPES_DIR = "PerfectBrew/Resources/Recipes"

# Map translation keys to file paths
RECIPE_PATHS = {
    "AeroPress_Tim_Wendelboe_single_serve": "AeroPress/Tim_Wendelboe/AeroPress_Tim_Wendelboe_single_serve.json",
    "AeroPress_James_Hoffmann_single_serve": "AeroPress/James_Hoffmann/AeroPress_James_Hoffmann_single_serve.json",
    "V60_James_Hoffmann_single_serve": "V60/James_Hoffmann/V60_James_Hoffmann_single_serve.json",
    "French_Press_James_Hoffmann_single_serve": "French_Press/James_Hoffmann/French_Press_James_Hoffmann_single_serve.json",
    "V60_Tetsu_Kasuya_single_serve": "V60/Tetsu_Kasuya/V60_Tetsu_Kasuya_single_serve.json",
}


def inject_translation(recipe: dict, translation: dict) -> dict:
    """Inject Spanish translations into a recipe."""
    
    # Top-level fields
    if "title_es" in translation:
        recipe["title_es"] = translation["title_es"]
    if "notes_es" in translation:
        recipe["notes_es"] = translation["notes_es"]
    if "preparation_steps_es" in translation:
        recipe["preparation_steps_es"] = translation["preparation_steps_es"]
    
    # Brewing steps
    if "brewing_steps" in translation and "brewing_steps" in recipe:
        for i, step_trans in enumerate(translation["brewing_steps"]):
            if i < len(recipe["brewing_steps"]):
                step = recipe["brewing_steps"][i]
                if "instruction_es" in step_trans:
                    step["instruction_es"] = step_trans["instruction_es"]
                if "short_instruction_es" in step_trans:
                    step["short_instruction_es"] = step_trans["short_instruction_es"]
                if "audio_script_es" in step_trans:
                    step["audio_script_es"] = step_trans["audio_script_es"]
    
    # What to expect
    if "what_to_expect" in translation and "what_to_expect" in recipe:
        wte = recipe["what_to_expect"]
        wte_trans = translation["what_to_expect"]
        if "description_es" in wte_trans:
            wte["description_es"] = wte_trans["description_es"]
        if "audio_script_es" in wte_trans:
            wte["audio_script_es"] = wte_trans["audio_script_es"]
    
    return recipe


def main():
    print("=" * 60)
    print("Inject Manual Spanish Translations")
    print("=" * 60)
    
    # Load translations
    with open(TRANSLATIONS_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    translations = data.get("translations", {})
    
    for key, rel_path in RECIPE_PATHS.items():
        if key not in translations:
            print(f"⚠️  No translation found for: {key}")
            continue
        
        filepath = os.path.join(RECIPES_DIR, rel_path)
        if not os.path.exists(filepath):
            print(f"❌ File not found: {filepath}")
            continue
        
        # Load recipe
        with open(filepath, 'r', encoding='utf-8') as f:
            recipe_data = json.load(f)
        
        # Handle array wrapper
        is_array = isinstance(recipe_data, list)
        recipe = recipe_data[0] if is_array else recipe_data
        
        # Inject translations
        recipe = inject_translation(recipe, translations[key])
        
        # Save back
        output_data = [recipe] if is_array else recipe
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Injected: {rel_path}")
    
    print("\n" + "=" * 60)
    print("✅ Done! 5 priority recipes now have complete Spanish translations.")
    print("=" * 60)


if __name__ == "__main__":
    main()


