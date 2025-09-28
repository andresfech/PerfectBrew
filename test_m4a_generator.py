#!/usr/bin/env python3
"""
Test script to verify the M4A audio generator works correctly.
"""

import os
import json
from universal_audio_generator import UniversalAudioGenerator

def test_m4a_generation():
    """Test M4A audio generation with a simple recipe."""
    
    # Create a test recipe
    test_recipe = {
        "title": "Test Recipe for M4A Generation",
        "brewing_method": "AeroPress",
        "brewing_steps": [
            {
                "time_seconds": 10,
                "instruction": "Test step 1",
                "audio_script": "This is a test audio script for step one.",
                "audio_file_name": "test_step_1.mp3"  # Will be converted to .m4a
            },
            {
                "time_seconds": 20,
                "instruction": "Test step 2", 
                "audio_script": "This is a test audio script for step two.",
                "audio_file_name": "test_step_2.wav"  # Will be converted to .m4a
            }
        ]
    }
    
    print("🧪 TESTING M4A AUDIO GENERATOR")
    print("=" * 50)
    
    # Create test output directory
    test_output_dir = "test_audio_output"
    os.makedirs(test_output_dir, exist_ok=True)
    
    try:
        # Initialize generator
        print("Loading TTS model...")
        generator = UniversalAudioGenerator(device="cpu")
        
        # Generate audio
        print("Generating test audio...")
        success = generator.generate_recipe_audio(test_recipe, test_output_dir)
        
        if success:
            print("✅ Test completed successfully!")
            
            # Check generated files
            recipe_folder = generator._convert_title_to_folder_name(test_recipe['title'])
            recipe_dir = os.path.join(test_output_dir, recipe_folder)
            
            if os.path.exists(recipe_dir):
                files = os.listdir(recipe_dir)
                m4a_files = [f for f in files if f.endswith('.m4a')]
                
                print(f"📁 Generated {len(m4a_files)} M4A files:")
                for file in m4a_files:
                    file_path = os.path.join(recipe_dir, file)
                    size = os.path.getsize(file_path)
                    print(f"   - {file} ({size} bytes)")
                
                # Clean up test files
                import shutil
                shutil.rmtree(test_output_dir)
                print("🧹 Cleaned up test files")
                
            else:
                print("❌ Recipe output directory not found")
        else:
            print("❌ Test failed")
            
    except Exception as e:
        print(f"❌ Test error: {e}")
        # Clean up on error
        import shutil
        if os.path.exists(test_output_dir):
            shutil.rmtree(test_output_dir)

if __name__ == "__main__":
    test_m4a_generation()
