#!/usr/bin/env python3
"""
Script to fix recipe timing logic.
This ensures that:
1. Step times are individual (not cumulative)
2. Water contact time is preserved by subtracting preparation steps
3. Total brew time matches the sum of individual step times
"""

import json
import os
import glob

def fix_recipe_timing_logic(file_path):
    """Fix timing logic in a recipe file."""
    print(f"Processing {file_path}...")

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            recipes = json.load(f)
    except Exception as e:
        print(f"  Error reading {file_path}: {e}")
        return 0

    changes_made = 0

    for recipe in recipes:
        if 'brewing_steps' in recipe and 'parameters' in recipe:
            print(f"  Recipe: {recipe['title']}")
            
            # Get current brewing steps
            steps = recipe['brewing_steps']
            
            # Identify water contact steps (usually contain keywords like "steep", "wait", "drain")
            water_contact_steps = []
            preparation_steps = []
            
            for i, step in enumerate(steps):
                instruction = step['instruction'].lower()
                if any(keyword in instruction for keyword in ['steep', 'wait', 'drain', 'extract', 'brew']):
                    water_contact_steps.append(i)
                else:
                    preparation_steps.append(i)
            
            print(f"    Water contact steps: {[i+1 for i in water_contact_steps]}")
            print(f"    Preparation steps: {[i+1 for i in preparation_steps]}")
            
            # Calculate total preparation time
            prep_time = sum(steps[i]['time_seconds'] for i in preparation_steps)
            print(f"    Total preparation time: {prep_time}s")
            
            # Calculate total water contact time needed
            water_contact_needed = 0
            for i in water_contact_steps:
                current_time = steps[i]['time_seconds']
                # If this step has a very long time, it's probably cumulative
                if current_time > 60:  # More than 1 minute suggests cumulative time
                    # Estimate individual time (this will be refined)
                    water_contact_needed += current_time - prep_time
                else:
                    water_contact_needed += current_time
            
            print(f"    Estimated water contact time needed: {water_contact_needed}s")
            
            # Fix step times to be individual
            new_steps = []
            cumulative_time = 0
            
            for i, step in enumerate(steps):
                current_time = step['time_seconds']
                instruction = step['instruction'].lower()
                
                if i in water_contact_steps:
                    # This is a water contact step
                    if current_time > 60:  # Likely cumulative
                        # Calculate individual time by subtracting previous cumulative
                        if i > 0:
                            individual_time = current_time - cumulative_time
                        else:
                            individual_time = current_time
                        
                        # Ensure minimum reasonable time
                        individual_time = max(30, individual_time)
                    else:
                        individual_time = current_time
                else:
                    # This is a preparation step - keep as is
                    individual_time = current_time
                
                # Update cumulative time
                cumulative_time += individual_time
                
                # Create new step with corrected time
                new_step = step.copy()
                new_step['time_seconds'] = individual_time
                new_steps.append(new_step)
                
                print(f"      Step {i+1}: {current_time}s -> {individual_time}s ({step['instruction'][:40]}...)")
            
            # Update the recipe
            recipe['brewing_steps'] = new_steps
            
            # Update total brew time
            new_total = sum(step['time_seconds'] for step in new_steps)
            old_total = recipe['parameters'].get('total_brew_time_seconds', 0)
            
            if new_total != old_total:
                recipe['parameters']['total_brew_time_seconds'] = new_total
                print(f"    Total time: {old_total}s -> {new_total}s")
                changes_made += 1
            
            print()

    if changes_made > 0:
        # Write back the fixed recipes
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(recipes, f, indent=2, ensure_ascii=False)
            print(f"  Fixed timing logic in {file_path}")
        except Exception as e:
            print(f"  Error writing {file_path}: {e}")
    else:
        print(f"  No timing logic issues found in {file_path}")

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

    print("\nFixing recipe timing logic...")

    for recipe_file in recipe_files:
        try:
            changes = fix_recipe_timing_logic(recipe_file)
            total_changes += changes
        except Exception as e:
            print(f"Error processing {recipe_file}: {e}")

    print(f"\nTotal changes made: {total_changes}")
    print("\nRecipe timing logic fixes completed!")

if __name__ == "__main__":
    main()


