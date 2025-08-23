#!/usr/bin/env python3
"""
Script to set minimum reasonable times for all brewing steps.
This ensures users have enough time to read and execute instructions,
especially for the first few steps of a recipe.
"""

import json
import os
import glob

def fix_minimum_timings(file_path):
    """Set minimum reasonable times for all brewing steps."""
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
            for i, step in enumerate(recipe['brewing_steps']):
                current_time = step.get('time_seconds', 0)
                instruction = step['instruction'].lower()
                
                # Determine minimum time based on step position and content
                if i < 2:  # First two steps are critical - need more time
                    min_time = 25
                elif i < 4:  # Next two steps - moderate time
                    min_time = 20
                else:  # Later steps - standard minimum
                    min_time = 15
                
                # Special cases for very short actions
                if 'place' in instruction or 'insert' in instruction or 'screw' in instruction:
                    min_time = max(min_time, 12)  # Equipment steps need some time
                elif 'wait' in instruction or 'let' in instruction:
                    min_time = max(min_time, 30)  # Waiting steps should be meaningful
                
                # If current time is less than minimum, increase it
                if current_time < min_time:
                    old_time = current_time
                    step['time_seconds'] = min_time
                    changes_made += 1
                    print(f"  Step {i+1}: {old_time}s -> {min_time}s: {step['instruction'][:50]}...")
    
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
    
    print("\nSetting minimum reasonable times for all steps...")
    print("Minimum times:")
    print("  - First 2 steps: 25 seconds")
    print("  - Steps 3-4: 20 seconds") 
    print("  - Later steps: 15 seconds")
    print("  - Equipment steps: 12+ seconds")
    print("  - Waiting steps: 30+ seconds")
    
    for recipe_file in recipe_files:
        try:
            changes = fix_minimum_timings(recipe_file)
            total_changes += changes
        except Exception as e:
            print(f"Error processing {recipe_file}: {e}")
    
    print(f"\nTotal changes made: {total_changes}")
    
    # Show example of first few steps from a recipe
    print("\nExample of improved timing (first recipe from V60):")
    try:
        with open("PerfectBrew/Resources/recipes_v60.json", 'r', encoding='utf-8') as f:
            recipes = json.load(f)
        
        if recipes:
            first_recipe = recipes[0]
            print(f"Recipe: {first_recipe['title']}")
            for i, step in enumerate(first_recipe['brewing_steps'][:3]):
                print(f"  Step {i+1}: {step['time_seconds']}s - {step['instruction'][:60]}...")
    except Exception as e:
        print(f"Could not show example: {e}")
    
    print("\nRecipe timing improvements completed!")

if __name__ == "__main__":
    main()


