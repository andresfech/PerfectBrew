#!/usr/bin/env python3
"""
Script to fix 0-second brewing steps in recipe files by adding reasonable time durations.
This ensures that brewing steps don't disappear instantly in the app.
"""

import json
import os
import re

def fix_recipe_timings(file_path):
    """Fix 0-second brewing steps in a recipe file."""
    print(f"Processing {file_path}...")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        recipes = json.load(f)
    
    changes_made = 0
    
    for recipe in recipes:
        if 'brewing_steps' in recipe:
            for step in recipe['brewing_steps']:
                if step.get('time_seconds') == 0:
                    # Determine appropriate time based on instruction content
                    instruction = step['instruction'].lower()
                    
                    if 'pour' in instruction and 'water' in instruction:
                        if 'bloom' in instruction:
                            # Bloom steps need more time for proper saturation
                            if 'stir' in instruction or 'swirl' in instruction:
                                step['time_seconds'] = 25
                            else:
                                step['time_seconds'] = 20
                        else:
                            # Regular pour steps
                            if 'stir' in instruction or 'swirl' in instruction:
                                step['time_seconds'] = 15
                            else:
                                step['time_seconds'] = 10
                    elif 'stir' in instruction:
                        # Stirring steps
                        if 'gently' in instruction:
                            step['time_seconds'] = 10
                        else:
                            step['time_seconds'] = 15
                    elif 'swirl' in instruction:
                        # Swirling steps
                        step['time_seconds'] = 8
                    elif 'insert' in instruction or 'place' in instruction:
                        # Equipment placement steps
                        step['time_seconds'] = 5
                    elif 'wait' in instruction or 'let' in instruction:
                        # Waiting steps should have meaningful time
                        step['time_seconds'] = 30
                    else:
                        # Default for other actions
                        step['time_seconds'] = 10
                    
                    changes_made += 1
                    print(f"  Fixed step: {step['instruction'][:50]}... -> {step['time_seconds']}s")
    
    if changes_made > 0:
        # Write back the fixed recipes
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(recipes, f, indent=2, ensure_ascii=False)
        print(f"  Fixed {changes_made} steps in {file_path}")
    else:
        print(f"  No changes needed in {file_path}")
    
    return changes_made

def main():
    """Main function to process all recipe files."""
    recipe_dir = "PerfectBrew/Resources"
    total_changes = 0
    
    # Find all recipe JSON files
    recipe_files = [f for f in os.listdir(recipe_dir) if f.startswith('recipes_') and f.endswith('.json')]
    
    print(f"Found {len(recipe_files)} recipe files to process:")
    for file in recipe_files:
        print(f"  - {file}")
    
    print("\nProcessing files...")
    
    for recipe_file in recipe_files:
        file_path = os.path.join(recipe_dir, recipe_file)
        try:
            changes = fix_recipe_timings(file_path)
            total_changes += changes
        except Exception as e:
            print(f"Error processing {recipe_file}: {e}")
    
    print(f"\nTotal changes made: {total_changes}")
    print("Recipe timing fixes completed!")

if __name__ == "__main__":
    main()


