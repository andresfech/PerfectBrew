#!/usr/bin/env python3
"""
Convert existing MP3 files to M4A format for iOS compatibility.
This will fix the audio playback issue without regenerating the audio.
"""

import os
import subprocess
import json

def check_ffmpeg():
    """Check if ffmpeg is available"""
    try:
        result = subprocess.run(['ffmpeg', '-version'], capture_output=True, text=True)
        if result.returncode == 0:
            print("✅ ffmpeg is available")
            return True
        else:
            print("❌ ffmpeg not found")
            return False
    except FileNotFoundError:
        print("❌ ffmpeg not found")
        return False

def convert_mp3_to_m4a(input_file, output_file):
    """Convert MP3 file to M4A using ffmpeg"""
    try:
        cmd = [
            'ffmpeg',
            '-i', input_file,           # Input file
            '-c:a', 'aac',              # Audio codec: AAC
            '-b:a', '128k',             # Audio bitrate: 128kbps
            '-ar', '44100',             # Sample rate: 44.1kHz
            '-ac', '2',                 # Stereo
            '-y',                       # Overwrite output file
            output_file
        ]
        
        print(f"🔄 Converting: {os.path.basename(input_file)} → {os.path.basename(output_file)}")
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"✅ Converted: {os.path.basename(output_file)}")
            return True
        else:
            print(f"❌ Failed to convert {os.path.basename(input_file)}: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error converting {os.path.basename(input_file)}: {e}")
        return False

def update_recipe_json():
    """Update recipe JSON to use .m4a files instead of .mp3"""
    recipe_file = "PerfectBrew/Resources/Recipes/AeroPress/World_Champions/2021_Tuomas_Merikanto_Finland/AeroPress_2021_Tuomas_Merikanto_single_serve.json"
    
    with open(recipe_file, 'r') as f:
        recipes = json.load(f)
    
    recipe = recipes[0]
    updated = False
    
    for step in recipe.get('brewing_steps', []):
        if step.get('audio_file_name', '').endswith('.mp3'):
            step['audio_file_name'] = step['audio_file_name'].replace('.mp3', '.m4a')
            updated = True
    
    if updated:
        with open(recipe_file, 'w') as f:
            json.dump(recipes, f, indent=2)
        print("✅ Updated recipe JSON to use .m4a files")
    else:
        print("⚠️  No .mp3 files found in recipe JSON")

def main():
    print("🔄 CONVERTING MP3 FILES TO M4A FOR iOS COMPATIBILITY")
    print("=" * 60)
    
    # Check if ffmpeg is available
    if not check_ffmpeg():
        print("Please install ffmpeg first:")
        print("brew install ffmpeg")
        return
    
    # Define paths
    input_dir = "PerfectBrew/Resources/Audio/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted"
    
    if not os.path.exists(input_dir):
        print(f"❌ Input directory not found: {input_dir}")
        return
    
    # Find all MP3 files
    mp3_files = [f for f in os.listdir(input_dir) if f.endswith('.mp3')]
    
    if not mp3_files:
        print("❌ No MP3 files found in input directory")
        return
    
    print(f"📁 Found {len(mp3_files)} MP3 files to convert")
    
    # Convert each MP3 file to M4A
    success_count = 0
    
    for mp3_file in sorted(mp3_files):
        input_path = os.path.join(input_dir, mp3_file)
        m4a_file = mp3_file.replace('.mp3', '.m4a')
        output_path = os.path.join(input_dir, m4a_file)
        
        if convert_mp3_to_m4a(input_path, output_path):
            success_count += 1
            
            # Remove the original MP3 file
            os.remove(input_path)
            print(f"🗑️  Removed original MP3: {mp3_file}")
    
    print(f"\n📊 CONVERSION SUMMARY:")
    print(f"  Successfully converted: {success_count}/{len(mp3_files)} files")
    print(f"  Output directory: {input_dir}")
    
    if success_count == len(mp3_files):
        print("✅ All files converted successfully!")
        
        # Update recipe JSON
        update_recipe_json()
        
        print("\n🎯 NEXT STEPS:")
        print("1. Build and run the app in Xcode")
        print("2. Test the 2021 World Champion recipe")
        print("3. Audio should now play correctly!")
    else:
        print("❌ Some files failed to convert")

if __name__ == "__main__":
    main()
