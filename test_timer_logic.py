#!/usr/bin/env python3
"""
Test script to verify timer logic is working correctly.
This simulates how the app should handle step transitions.
"""

import json

def test_timer_logic():
    """Test the timer logic with a sample recipe."""
    
    # Sample recipe data (similar to what we have in the JSON files)
    sample_recipe = {
        "brewing_steps": [
            {"time_seconds": 25, "instruction": "Bloom: Pour 40mL water"},
            {"time_seconds": 45, "instruction": "Main pour: Add 75mL water"},
            {"time_seconds": 60, "instruction": "Swirl gently"},
            {"time_seconds": 90, "instruction": "Final pour: Add remaining water"},
            {"time_seconds": 180, "instruction": "Wait for drain"}
        ]
    }
    
    print("Testing Timer Logic")
    print("=" * 50)
    
    # Simulate the app's timer logic
    elapsed_time = 0
    total_time = sum(step["time_seconds"] for step in sample_recipe["brewing_steps"])
    
    print(f"Total recipe time: {total_time} seconds")
    print()
    
    # Simulate each second
    for second in range(total_time + 5):  # Add 5 seconds to see what happens after
        elapsed_time = second
        
        # Find current step (simulating updateStep function)
        cumulative_time = 0
        current_step = None
        step_start_time = 0
        step_duration = 0
        
        for i, step in enumerate(sample_recipe["brewing_steps"]):
            step_end_time = cumulative_time + step["time_seconds"]
            
            if second < 5:  # Debug for first few seconds
                print(f"  DEBUG: Checking step {i+1}: {cumulative_time}s to {step_end_time}s, elapsed: {elapsed_time}s")
            
            if elapsed_time >= cumulative_time and elapsed_time < step_end_time:
                # We're in this step
                current_step = step
                step_start_time = cumulative_time
                step_duration = step["time_seconds"]
                if second < 5:
                    print(f"  DEBUG: Found step {i+1}!")
                break
                
            cumulative_time = step_end_time
        
        # If we've passed all steps, show the last step
        if elapsed_time >= cumulative_time and sample_recipe["brewing_steps"] and current_step is None:
            last_step = sample_recipe["brewing_steps"][-1]
            current_step = last_step
            step_start_time = cumulative_time - last_step["time_seconds"]
            step_duration = last_step["time_seconds"]
        
        if current_step:
            step_elapsed = elapsed_time - step_start_time
            step_remaining = max(0, step_duration - step_elapsed)
            
            if second < 30:  # Only show first 30 seconds to avoid spam
                step_index = sample_recipe["brewing_steps"].index(current_step) + 1
                print(f"Second {second:3d}: Step {step_index} - "
                      f"'{current_step['instruction'][:30]}...' - "
                      f"Elapsed: {step_elapsed:2.0f}s, Remaining: {step_remaining:2.0f}s")
        
        # Show step transitions
        if step_remaining == 0 and step_elapsed > 0:
            step_index = sample_recipe["brewing_steps"].index(current_step) + 1
            print(f"  → Step {step_index} completed!")
    
    print()
    print("Timer logic test completed!")
    print("Expected behavior:")
    print("- Step 1: 25 seconds (0-24)")
    print("- Step 2: 45 seconds (25-69)")
    print("- Step 3: 60 seconds (70-129)")
    print("- Step 4: 90 seconds (130-219)")
    print("- Step 5: 180 seconds (220-399)")

if __name__ == "__main__":
    test_timer_logic()
