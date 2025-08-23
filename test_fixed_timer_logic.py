#!/usr/bin/env python3
"""
Test script to verify the fixed timer logic works correctly.
This simulates the BrewingGuideViewModel's updateStep logic.
"""

import json

def test_timer_logic():
    """Test the timer logic with a sample recipe."""
    
    # Sample recipe with corrected individual times
    sample_recipe = {
        "brewing_steps": [
            {"time_seconds": 25, "instruction": "Pour 250g hot water..."},
            {"time_seconds": 25, "instruction": "Stir for 10 seconds..."},
            {"time_seconds": 70, "instruction": "Let coffee steep for 2 minutes..."},
            {"time_seconds": 50, "instruction": "Hold AeroPress and mug together..."},
            {"time_seconds": 30, "instruction": "Continue steeping for another 30 seconds..."},
            {"time_seconds": 30, "instruction": "Press down slowly over 30 seconds..."}
        ]
    }
    
    print("Testing fixed timer logic with corrected recipe times:")
    print("Step times: " + ", ".join([f"{step['time_seconds']}s" for step in sample_recipe["brewing_steps"]]))
    print()
    
    # Simulate the updateStep logic
    for second in range(0, 250, 5):  # Test every 5 seconds up to 250s
        elapsed_time = second
        
        # Find the current brewing step based on elapsed time
        current_brewing_step = sample_recipe["brewing_steps"][0]["instruction"]
        step_start_time = 0
        step_duration = 0
        
        # Calculate cumulative time for each step
        cumulative_time = 0
        current_step_index = 0
        
        for index, step in enumerate(sample_recipe["brewing_steps"]):
            time = step["time_seconds"]
            instruction = step["instruction"]
            step_end_time = cumulative_time + time
            
            if elapsed_time >= cumulative_time and elapsed_time < step_end_time:
                # We're in this step
                current_brewing_step = instruction
                step_start_time = cumulative_time
                step_duration = time
                current_step_index = index
                break
            
            cumulative_time = step_end_time
        
        # If we've passed all steps, show the last step
        if elapsed_time >= cumulative_time and sample_recipe["brewing_steps"] and current_step_index == 0:
            last_step = sample_recipe["brewing_steps"][-1]
            current_brewing_step = last_step["instruction"]
            step_start_time = cumulative_time - last_step["time_seconds"]
            step_duration = last_step["time_seconds"]
            current_step_index = len(sample_recipe["brewing_steps"]) - 1
        
        # Calculate remaining time for current step
        step_elapsed = elapsed_time - step_start_time
        step_remaining = max(0, step_duration - step_elapsed)
        
        if second % 25 == 0:  # Show every 25 seconds to avoid spam
            print(f"Second {second:3d}: Step {current_step_index + 1} - "
                  f"'{current_brewing_step[:40]}...' - "
                  f"Elapsed: {step_elapsed:2.0f}s, Remaining: {step_remaining:2.0f}s")
        
        # Show step transitions
        if step_remaining == 0 and step_elapsed > 0:
            print(f"  → Step {current_step_index + 1} completed!")
    
    print("\nTimer logic test completed!")

if __name__ == "__main__":
    test_timer_logic()


