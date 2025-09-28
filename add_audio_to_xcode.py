#!/usr/bin/env python3
"""
Script to help add the Audio folder to Xcode as a folder reference.
This ensures the hierarchical audio structure is included in the app bundle.
"""

import os
import subprocess

def main():
    print("🔧 Xcode Audio Folder Setup Helper")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not os.path.exists("PerfectBrew.xcodeproj"):
        print("❌ Error: PerfectBrew.xcodeproj not found. Please run this from the project root.")
        return
    
    # Check if Audio folder exists
    audio_path = "PerfectBrew/Resources/Audio"
    if not os.path.exists(audio_path):
        print(f"❌ Error: {audio_path} not found.")
        return
    
    print(f"✅ Found Audio folder at: {audio_path}")
    
    # Count audio files
    audio_count = 0
    audio_files = []
    for root, dirs, files in os.walk(audio_path):
        for file in files:
            if file.endswith(('.mp3', '.wav', '.m4a', '.aac')):
                audio_count += 1
                audio_files.append(os.path.join(root, file))
    
    print(f"✅ Found {audio_count} audio files")
    
    # Show some examples
    if audio_files:
        print("\n📁 Sample audio files found:")
        for i, file in enumerate(audio_files[:5]):  # Show first 5
            rel_path = os.path.relpath(file, "PerfectBrew/Resources/Audio")
            print(f"   - {rel_path}")
        if len(audio_files) > 5:
            print(f"   ... and {len(audio_files) - 5} more")
    
    print("\n📋 MANUAL STEPS REQUIRED:")
    print("=" * 30)
    print("1. Open PerfectBrew.xcodeproj in Xcode")
    print("2. In the Project Navigator (left sidebar):")
    print("   - Right-click on 'Resources' folder")
    print("   - Select 'Add Files to PerfectBrew'")
    print("3. Navigate to and select the 'Audio' folder")
    print("4. IMPORTANT: Check 'Create folder references' (not 'Create groups')")
    print("5. Click 'Add'")
    print("\n6. Verify the Audio folder appears in Xcode with a blue folder icon")
    print("   (Blue = folder reference, Yellow = group)")
    
    print(f"\n🎯 Expected Result:")
    print(f"   - Audio folder should be blue (folder reference)")
    print(f"   - All {audio_count} audio files should be visible")
    print(f"   - App should be able to play audio files")
    
    print(f"\n🔍 To verify it worked:")
    print(f"   - Build and run the app")
    print(f"   - Select the 2021 World Champion recipe")
    print(f"   - Audio should play for each brewing step")
    
    # Check specifically for 2021 World Champion audio files
    world_champ_path = "PerfectBrew/Resources/Audio/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted"
    if os.path.exists(world_champ_path):
        print(f"\n🎵 2021 World Champion Audio Files:")
        world_champ_files = [f for f in os.listdir(world_champ_path) if f.endswith('.mp3')]
        for file in sorted(world_champ_files):
            print(f"   - {file}")
        print(f"   Total: {len(world_champ_files)} files")

if __name__ == "__main__":
    main()
