#!/usr/bin/env python3
"""
Comprehensive debug script to analyze recipe timing issues.
This will help us understand exactly what's happening with the step timers.
"""

import json
import os
import glob

def analyze_recipe_timing(file_path):
    """Analyze timing logic in a recipe file."""
    print(f"\n{'='*60}")
    print(f"ANALYZING: {os.path.basename(file_path)}")
    print(f"{'='*60}")
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            recipes = json.load(f)
    except Exception as e:
        print(f"  Error reading {file_path}: {e}")
        return
    
    for recipe_idx, recipe in enumerate(recipes):
        print(f"\nRECIPE {recipe_idx + 1}: {recipe['title']}")
        print(f"Method: {recipe.get('brewing_method', 'Unknown')}")
        
        if 'brewing_steps' in recipe and 'parameters' in recipe:
            steps = recipe['brewing_steps']
            params = recipe['parameters']
            
            # Analyze brewing steps
            print(f"\nBREWING STEPS ({len(steps)} steps):")
            cumulative_time = 0
            step_details = []
            
            for i, step in enumerate(steps):
                time = step['time_seconds']
                instruction = step['instruction']
                cumulative_time += time
                
                step_details.append({
                    'index': i + 1,
                    'time': time,
                    'cumulative': cumulative_time,
                    'instruction': instruction[:50] + "..." if len(instruction) > 50 else instruction
                })
                
                print(f"  Step {i+1:2d}: {time:3d}s (cumulative: {cumulative_time:3d}s) - {instruction[:60]}...")
            
            # Analyze timing parameters
            total_brew_time = params.get('total_brew_time_seconds', 0)
            bloom_time = params.get('bloom_time_seconds', 0)
            
            print(f"\nTIMING ANALYSIS:")
            print(f"  Total steps time: {cumulative_time}s")
            print(f"  Recipe total time: {total_brew_time}s")
            print(f"  Bloom time: {bloom_time}s")
            print(f"  Time difference: {total_brew_time - cumulative_time}s")
            
            # Identify potential issues
            issues = []
            
            if total_brew_time != cumulative_time:
                issues.append(f"Total time mismatch: recipe says {total_brew_time}s but steps add up to {cumulative_time}s")
            
            if any(step['time'] == 0 for step in steps):
                issues.append("Found steps with 0 seconds duration")
            
            if any(step['time'] < 5 for step in steps):
                issues.append("Found steps with very short duration (< 5s)")
            
            if len(issues) > 0:
                print(f"\n⚠️  ISSUES FOUND:")
                for issue in issues:
                    print(f"    - {issue}")
            else:
                print(f"\n✅ No timing issues detected")
            
            # Simulate timer behavior
            print(f"\nTIMER SIMULATION:")
            print(f"  Simulating step progression every 10 seconds...")
            
            for elapsed in range(0, min(cumulative_time + 10, 300), 10):
                current_step = None
                step_start = 0
                step_duration = 0
                step_index = 0
                
                # Find current step
                cumulative = 0
                for i, step in enumerate(steps):
                    step_end = cumulative + step['time_seconds']
                    
                    if elapsed >= cumulative and elapsed < step_end:
                        current_step = step
                        step_start = cumulative
                        step_duration = step['time_seconds']
                        step_index = i
                        break
                    
                    cumulative = step_end
                
                if current_step:
                    step_elapsed = elapsed - step_start
                    step_remaining = max(0, step_duration - step_elapsed)
                    
                    if elapsed % 30 == 0 or step_remaining < 10:  # Show every 30s or when step is about to end
                        print(f"    {elapsed:3d}s: Step {step_index + 1} - "
                              f"'{current_step['instruction'][:30]}...' - "
                              f"Elapsed: {step_elapsed:2.0f}s, Remaining: {step_remaining:2.0f}s")
                else:
                    if elapsed >= cumulative_time:
                        print(f"    {elapsed:3d}s: All steps completed")
                        break

def main():
    """Main function to analyze ALL recipe files."""
    recipe_dir = "PerfectBrew/Resources"
    
    # Find ALL recipe JSON files
    recipe_files = glob.glob(os.path.join(recipe_dir, "recipes_*.json"))
    
    print(f"Found {len(recipe_files)} recipe files to analyze:")
    for file in recipe_files:
        print(f"  - {os.path.basename(file)}")
    
    print(f"\n{'='*60}")
    print("STARTING COMPREHENSIVE TIMING ANALYSIS")
    print(f"{'='*60}")
    
    for recipe_file in recipe_files:
        try:
            analyze_recipe_timing(recipe_file)
        except Exception as e:
            print(f"Error analyzing {recipe_file}: {e}")
    
    print(f"\n{'='*60}")
    print("ANALYSIS COMPLETED")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()


