#!/usr/bin/env python3
"""
Test script to simulate the exact AeroPress recipe timing issue.
"""

def test_aeropress_timer():
    """Test the AeroPress recipe timing step by step."""
    
    # AeroPress recipe steps (from the JSON)
    brewing_steps = [
        {"time_seconds": 25, "instruction": "Pour 250g hot water"},
        {"time_seconds": 25, "instruction": "Stir for 10 seconds"},
        {"time_seconds": 20, "instruction": "Insert plunger and pull up slightly"},
        {"time_seconds": 60, "instruction": "Wait 1 minute"},
        {"time_seconds": 120, "instruction": "Press down slowly over 30 seconds"}
    ]
    
    print("Testing AeroPress recipe timing (FIXED VERSION):")
    print("Step times: " + ", ".join([f"{step['time_seconds']}s" for step in brewing_steps]))
    print()
    
    # Test the corrected logic step by step
    for elapsed_time in range(0, 260, 1):  # Test every second
        current_step = None
        step_start_time = 0
        step_duration = 0
        current_step_index = 0
        
        # Calculate cumulative time for each step
        cumulative_time = 0
        
        for index, step in enumerate(brewing_steps):
            time = step['time_seconds']
            instruction = step['instruction']
            step_end_time = cumulative_time + time
            
            if elapsed_time >= cumulative_time and elapsed_time < step_end_time:
                # We're in this step
                current_step = step
                step_start_time = cumulative_time
                step_duration = time
                current_step_index = index
                break
            
            cumulative_time = step_end_time
        
        # If we've passed all steps, show the last step (FIXED LOGIC)
        if elapsed_time >= cumulative_time and brewing_steps and current_step_index == 0:
            # Only show last step if we've actually completed all steps
            total_steps_time = sum(step['time_seconds'] for step in brewing_steps)
            if elapsed_time >= total_steps_time:
                last_step = brewing_steps[-1]
                current_step = last_step
                step_start_time = cumulative_time - last_step['time_seconds']
                step_duration = last_step['time_seconds']
                current_step_index = len(brewing_steps) - 1
        
        if current_step:
            step_elapsed = elapsed_time - step_start_time
            step_remaining = max(0, step_duration - step_elapsed)
            
            # Show step transitions and key moments
            if (elapsed_time % 25 == 0 or 
                step_remaining == 0 or 
                elapsed_time in [0, 1, 24, 25, 26, 49, 50, 51, 69, 70, 71, 129, 130, 131, 249, 250]):
                
                print(f"Second {elapsed_time:3d}: Step {current_step_index + 1} - "
                      f"'{current_step['instruction'][:30]}...' - "
                      f"Elapsed: {step_elapsed:2.0f}s, Remaining: {step_remaining:2.0f}s")
                
                if step_remaining == 0 and step_elapsed > 0:
                    print(f"  → Step {current_step_index + 1} completed!")
        
        # Stop after showing all key moments
        if elapsed_time > 250:
            break
    
    print("\nAeroPress timer test completed!")

if __name__ == "__main__":
    test_aeropress_timer()


