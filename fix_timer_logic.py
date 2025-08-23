#!/usr/bin/env python3
"""
Script to fix timer logic in recipes.
This ensures that:
1. Total brew time matches the sum of individual step times
2. Timers work correctly in sequence
3. No steps disappear unexpectedly
"""

import json
import os
import glob

def fix_timer_logic(file_path):
    """Fix timer logic in a recipe file."""
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
            # Calculate total time from individual steps
            calculated_total = sum(step.get('time_seconds', 0) for step in recipe['brewing_steps'])
            
            # Get current total from parameters
            current_total = recipe['parameters'].get('total_brew_time_seconds', 0)
            
            # Check if there's a mismatch
            if calculated_total != current_total:
                print(f"  Recipe: {recipe['title']}")
                print(f"    Current total: {current_total}s")
                print(f"    Calculated total: {calculated_total}s")
                
                # Update the total to match calculated
                recipe['parameters']['total_brew_time_seconds'] = calculated_total
                changes_made += 1
                print(f"    -> Updated total to {calculated_total}s")
                
                # Also check if we need to adjust individual step times for better flow
                if calculated_total < 60:  # If total is less than 1 minute, steps are too short
                    print(f"    -> Total time too short, adjusting step times...")
                    for i, step in enumerate(recipe['brewing_steps']):
                        current_time = step.get('time_seconds', 0)
                        if current_time < 20:  # Increase very short steps
                            new_time = max(20, current_time + 5)
                            step['time_seconds'] = new_time
                            print(f"      Step {i+1}: {current_time}s -> {new_time}s")
                            changes_made += 1
                
                # Recalculate after adjustments
                new_calculated_total = sum(step.get('time_seconds', 0) for step in recipe['brewing_steps'])
                if new_calculated_total != calculated_total:
                    recipe['parameters']['total_brew_time_seconds'] = new_calculated_total
                    print(f"    -> Final total: {new_calculated_total}s")
    
    if changes_made > 0:
        # Write back the fixed recipes
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(recipes, f, indent=2, ensure_ascii=False)
            print(f"  Fixed {changes_made} timing issues in {file_path}")
        except Exception as e:
            print(f"  Error writing {file_path}: {e}")
    else:
        print(f"  No timing issues found in {file_path}")
    
    return changes_made

def verify_timer_consistency(file_path):
    """Verify that timer logic is consistent."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            recipes = json.load(f)
    except Exception as e:
        return f"Error reading {file_path}: {e}"
    
    issues = []
    
    for recipe in recipes:
        if 'brewing_steps' in recipe and 'parameters' in recipe:
            calculated_total = sum(step.get('time_seconds', 0) for step in recipe['brewing_steps'])
            current_total = recipe['parameters'].get('total_brew_time_seconds', 0)
            
            if calculated_total != current_total:
                issues.append(f"{recipe['title']}: {current_total}s vs {calculated_total}s")
            
            # Check for very short steps that might cause issues
            for i, step in enumerate(recipe['brewing_steps']):
                if step.get('time_seconds', 0) < 15:
                    issues.append(f"{recipe['title']} Step {i+1}: {step.get('time_seconds', 0)}s (too short)")
    
    return issues

def main():
    """Main function to process ALL recipe files."""
    recipe_dir = "PerfectBrew/Resources"
    total_changes = 0
    
    # Find ALL recipe JSON files
    recipe_files = glob.glob(os.path.join(recipe_dir, "recipes_*.json"))
    
    print(f"Found {len(recipe_files)} recipe files to process:")
    for file in recipe_files:
        print(f"  - {os.path.basename(file)}")
    
    print("\nFixing timer logic...")
    
    for recipe_file in recipe_files:
        try:
            changes = fix_timer_logic(recipe_file)
            total_changes += changes
        except Exception as e:
            print(f"Error processing {recipe_file}: {e}")
    
    print(f"\nTotal changes made: {total_changes}")
    
    # Verify consistency after fixes
    print("\nVerifying timer consistency...")
    all_issues = []
    for recipe_file in recipe_files:
        issues = verify_timer_consistency(recipe_file)
        if isinstance(issues, list):
            all_issues.extend(issues)
        else:
            print(f"  {issues}")
    
    if all_issues:
        print(f"\n❌ Found {len(all_issues)} remaining issues:")
        for issue in all_issues[:10]:  # Show first 10 issues
            print(f"  - {issue}")
        if len(all_issues) > 10:
            print(f"  ... and {len(all_issues) - 10} more")
    else:
        print("✅ All timer logic is now consistent!")
    
    # Show example of fixed recipe
    print("\nExample of fixed recipe (first recipe from V60):")
    try:
        with open("PerfectBrew/Resources/recipes_v60.json", 'r', encoding='utf-8') as f:
            recipes = json.load(f)
        
        if recipes:
            first_recipe = recipes[0]
            print(f"Recipe: {first_recipe['title']}")
            print(f"Total brew time: {first_recipe['parameters']['total_brew_time_seconds']}s")
            step_total = 0
            for i, step in enumerate(first_recipe['brewing_steps']):
                step_total += step['time_seconds']
                print(f"  Step {i+1}: {step['time_seconds']}s - {step['instruction'][:50]}...")
            print(f"Calculated total: {step_total}s")
            if step_total == first_recipe['parameters']['total_brew_time_seconds']:
                print("✅ Timer logic is consistent!")
            else:
                print("❌ Timer logic still has issues")
    except Exception as e:
        print(f"Could not show example: {e}")
    
    print("\nTimer logic fixes completed!")

if __name__ == "__main__":
    main()


