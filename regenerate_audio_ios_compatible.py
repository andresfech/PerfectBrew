#!/usr/bin/env python3
"""
Regenerate audio files in iOS-compatible format.
The previous MP3 files have decoding issues on iOS.
This script will generate M4A files which are more compatible.
"""

import os
import json
import subprocess
import sys

def check_chatterbox():
    """Check if Chatterbox is available"""
    try:
        result = subprocess.run(['chatterbox', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ Chatterbox is available")
            return True
        else:
            print("❌ Chatterbox not found or not working")
            return False
    except FileNotFoundError:
        print("❌ Chatterbox not found")
        return False

def generate_audio_m4a(text, output_file):
    """Generate M4A audio file using Chatterbox"""
    try:
        # Use Chatterbox to generate M4A (AAC) format which is more iOS compatible
        cmd = [
            'chatterbox',
            '--text', text,
            '--output', output_file,
            '--format', 'm4a',
            '--voice', 'en-US-AriaNeural'  # Use a high-quality voice
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
    print("🎵 REGENERATING AUDIO FILES FOR iOS COMPATIBILITY")
    print("=" * 60)
    
    # Check if Chatterbox is available
    if not check_chatterbox():
        print("Please install Chatterbox first:")
        print("pip install chatterbox-tts")
        return
    
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
        
        if generate_audio_m4a(audio_script, output_path):
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
