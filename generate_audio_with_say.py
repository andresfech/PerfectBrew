#!/usr/bin/env python3
"""
Generate audio files using macOS 'say' command for iOS compatibility.
This will create M4A files that are fully compatible with iOS.
"""

import os
import json
import subprocess
import sys

def generate_audio_say(text, output_file):
    """Generate M4A audio file using macOS 'say' command"""
    try:
        # Use macOS 'say' command to generate M4A files
        cmd = [
            'say',
            '-v', 'Samantha',  # Use a high-quality voice
            '-r', '180',       # Speaking rate (words per minute)
            '-o', output_file, # Output file
            text
        ]
        
        print(f"🎵 Generating: {output_file}")
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"✅ Generated: {output_file}")
            return True
        else:
            print(f"❌ Failed to generate {output_file}: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error generating {output_file}: {e}")
        return False

def main():
    print("🎵 GENERATING AUDIO FILES WITH macOS 'say' COMMAND")
    print("=" * 60)
    
    # Load the recipe
    recipe_file = "PerfectBrew/Resources/Recipes/AeroPress/World_Champions/2021_Tuomas_Merikanto_Finland/AeroPress_2021_Tuomas_Merikanto_single_serve.json"
    
    if not os.path.exists(recipe_file):
        print(f"❌ Recipe file not found: {recipe_file}")
        return
    
    with open(recipe_file, 'r') as f:
        recipes = json.load(f)
    
    recipe = recipes[0]
    print(f"✅ Loaded recipe: {recipe['title']}")
    
    # Create output directory
    output_dir = "PerfectBrew/Resources/Audio/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted"
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate audio for each brewing step
    brewing_steps = recipe.get('brewing_steps', [])
    success_count = 0
    
    for i, step in enumerate(brewing_steps, 1):
        audio_script = step.get('audio_script')
        audio_file_name = step.get('audio_file_name')
        
        if not audio_script or not audio_file_name:
            print(f"⚠️  Step {i} missing audio script or file name")
            continue
        
        # Convert MP3 filename to M4A
        m4a_filename = audio_file_name.replace('.mp3', '.m4a')
        output_path = os.path.join(output_dir, m4a_filename)
        
        print(f"\n📝 Step {i}: {step.get('instruction', '')[:50]}...")
        print(f"🎤 Script: {audio_script[:100]}...")
        
        if generate_audio_say(audio_script, output_path):
            success_count += 1
        else:
            print(f"❌ Failed to generate audio for step {i}")
    
    print(f"\n📊 SUMMARY:")
    print(f"  Successfully generated: {success_count}/{len(brewing_steps)} audio files")
    print(f"  Output directory: {output_dir}")
    
    if success_count == len(brewing_steps):
        print("✅ All audio files generated successfully!")
        print("\n🔧 NEXT STEPS:")
        print("1. Update the recipe JSON to use .m4a files instead of .mp3")
        print("2. Test the audio playback in the app")
    else:
        print("❌ Some audio files failed to generate")

if __name__ == "__main__":
    main()
