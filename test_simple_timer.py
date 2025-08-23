#!/usr/bin/env python3
"""
Simple test script to verify the corrected timer logic.
"""

def test_timer_logic():
    """Test the corrected timer logic."""
    
    # Sample recipe with individual step times
    brewing_steps = [
        {"time_seconds": 25, "instruction": "Pour water"},
        {"time_seconds": 25, "instruction": "Stir"},
        {"time_seconds": 20, "instruction": "Insert plunger"},
        {"time_seconds": 60, "instruction": "Wait"},
        {"time_seconds": 120, "instruction": "Press down"}
    ]
    
    print("Testing corrected timer logic:")
    print("Step times: " + ", ".join([f"{step['time_seconds']}s" for step in brewing_steps]))
    print()
    
    # Test the corrected logic
    for elapsed_time in range(0, 260, 5):  # Test every 5 seconds
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
        
        # If we've passed all steps, show the last step
        if elapsed_time >= cumulative_time and brewing_steps and current_step_index == 0:
            last_step = brewing_steps[-1]
            current_step = last_step
            step_start_time = cumulative_time - last_step['time_seconds']
            step_duration = last_step['time_seconds']
            current_step_index = len(brewing_steps) - 1
        
        if current_step:
            step_elapsed = elapsed_time - step_start_time
            step_remaining = max(0, step_duration - step_elapsed)
            
            if elapsed_time % 25 == 0:  # Show every 25 seconds
                print(f"Second {elapsed_time:3d}: Step {current_step_index + 1} - "
                      f"'{current_step['instruction']}' - "
                      f"Elapsed: {step_elapsed:2.0f}s, Remaining: {step_remaining:2.0f}s")
        
        # Show step transitions
        if current_step and step_remaining == 0 and step_elapsed > 0:
            print(f"  → Step {current_step_index + 1} completed!")
    
    print("\nTimer logic test completed!")

if __name__ == "__main__":
    test_timer_logic()


