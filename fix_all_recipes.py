#!/usr/bin/env python3
"""
Improved script to fix ALL 0-second brewing steps in ALL recipe files.
This ensures that brewing steps don't disappear instantly in the app.
"""

import json
import os
import glob

def fix_recipe_timings(file_path):
    """Fix 0-second brewing steps in a recipe file."""
    print(f"Processing {file_path}...")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            recipes = json.load(f)
    except Exception as e:
        print(f"  Error reading {file_path}: {e}")
        return 0
    
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
                    elif 'screw' in instruction or 'cap' in instruction:
                        # Screwing on cap steps
                        step['time_seconds'] = 8
                    elif 'flip' in instruction:
                        # Flipping steps
                        step['time_seconds'] = 5
                    else:
                        # Default for other actions
                        step['time_seconds'] = 10
                    
                    changes_made += 1
                    print(f"  Fixed step: {step['instruction'][:50]}... -> {step['time_seconds']}s")
    
    if changes_made > 0:
        # Write back the fixed recipes
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(recipes, f, indent=2, ensure_ascii=False)
            print(f"  Fixed {changes_made} steps in {file_path}")
        except Exception as e:
            print(f"  Error writing {file_path}: {e}")
    else:
        print(f"  No changes needed in {file_path}")
    
    return changes_made

def main():
    """Main function to process ALL recipe files."""
    recipe_dir = "PerfectBrew/Resources"
    total_changes = 0
    
    # Find ALL recipe JSON files
    recipe_files = glob.glob(os.path.join(recipe_dir, "recipes_*.json"))
    
    print(f"Found {len(recipe_files)} recipe files to process:")
    for file in recipe_files:
        print(f"  - {os.path.basename(file)}")
    
    print("\nProcessing files...")
    
    for recipe_file in recipe_files:
        try:
            changes = fix_recipe_timings(recipe_file)
            total_changes += changes
        except Exception as e:
            print(f"Error processing {recipe_file}: {e}")
    
    print(f"\nTotal changes made: {total_changes}")
    
    # Verify no 0-second steps remain
    print("\nVerifying no 0-second steps remain...")
    remaining_zeros = 0
    for recipe_file in recipe_files:
        try:
            with open(recipe_file, 'r', encoding='utf-8') as f:
                recipes = json.load(f)
            
            for recipe in recipes:
                if 'brewing_steps' in recipe:
                    for step in recipe['brewing_steps']:
                        if step.get('time_seconds') == 0:
                            remaining_zeros += 1
                            print(f"  WARNING: Found 0-second step in {os.path.basename(recipe_file)}: {step['instruction'][:50]}...")
        except Exception as e:
            print(f"Error verifying {recipe_file}: {e}")
    
    if remaining_zeros == 0:
        print("✅ All 0-second steps have been fixed!")
    else:
        print(f"❌ {remaining_zeros} 0-second steps still remain. Please check manually.")
    
    print("Recipe timing fixes completed!")

if __name__ == "__main__":
    main()


