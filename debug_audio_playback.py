#!/usr/bin/env python3
"""
Debug script to diagnose audio playback issues.
This will help identify why audio is not playing in the app.
"""

import os
import json

def debug_audio_playback():
    print("🔍 DEBUGGING AUDIO PLAYBACK")
    print("=" * 50)
    
    # Test the 2021 World Champion recipe
    recipe_file = "PerfectBrew/Resources/Recipes/AeroPress/World_Champions/2021_Tuomas_Merikanto_Finland/AeroPress_2021_Tuomas_Merikanto_single_serve.json"
    
    if not os.path.exists(recipe_file):
        print("❌ Recipe file not found:", recipe_file)
        return
    
    # Load the recipe
    with open(recipe_file, 'r') as f:
        recipes = json.load(f)
    
    recipe = recipes[0]  # Get the first (and only) recipe
    print(f"✅ Recipe loaded: {recipe['title']}")
    print()
    
    # Check brewing steps
    brewing_steps = recipe.get('brewing_steps', [])
    print(f"📋 Brewing steps: {len(brewing_steps)}")
    
    audio_files_found = 0
    audio_files_missing = 0
    
    for i, step in enumerate(brewing_steps, 1):
        audio_file_name = step.get('audio_file_name')
        audio_script = step.get('audio_script')
        
        print(f"\nStep {i}:")
        print(f"  Time: {step.get('time_seconds')}s")
        print(f"  Instruction: {step.get('instruction', '')[:50]}...")
        print(f"  Audio file: {audio_file_name or 'NONE'}")
        print(f"  Audio script: {'YES' if audio_script else 'NO'}")
        
        if audio_file_name:
            # Check if audio file exists
            audio_path = f"PerfectBrew/Resources/Audio/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted/{audio_file_name}"
            if os.path.exists(audio_path):
                print(f"  ✅ Audio file exists")
                audio_files_found += 1
            else:
                print(f"  ❌ Audio file missing: {audio_path}")
                audio_files_missing += 1
        else:
            print(f"  ⚠️  No audio file specified")
    
    print(f"\n📊 AUDIO FILES SUMMARY:")
    print(f"  Found: {audio_files_found}")
    print(f"  Missing: {audio_files_missing}")
    print(f"  Total steps: {len(brewing_steps)}")
    
    # Check AudioService logic
    print(f"\n🔧 AUDIOSERVICE LOGIC:")
    recipe_title = recipe['title']
    print(f"  Recipe title: {recipe_title}")
    
    # Simulate getBrewingMethod
    brewing_method = "AeroPress" if "AeroPress" in recipe_title else "Unknown"
    print(f"  Brewing method: {brewing_method}")
    
    # Simulate convertTitleToFolderName
    folder_name = "2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted" if "2021 World AeroPress Champion" in recipe_title else "Unknown"
    print(f"  Folder name: {folder_name}")
    
    # Test search path
    search_path = f"Audio/{brewing_method}/World_Champions/{folder_name}"
    print(f"  Search path: {search_path}")
    
    # Check if the search path exists
    full_search_path = f"PerfectBrew/Resources/{search_path}"
    if os.path.exists(full_search_path):
        print(f"  ✅ Search path exists")
        files = os.listdir(full_search_path)
        audio_files = [f for f in files if f.endswith('.mp3')]
        print(f"  ✅ Found {len(audio_files)} audio files in search path")
    else:
        print(f"  ❌ Search path does not exist: {full_search_path}")
    
    print(f"\n🎯 EXPECTED BEHAVIOR:")
    print(f"1. User selects recipe: {recipe_title}")
    print(f"2. AudioService identifies brewing method: {brewing_method}")
    print(f"3. Converts title to folder: {folder_name}")
    print(f"4. Searches in: {search_path}")
    print(f"5. Finds and plays audio for each step")
    
    print(f"\n🔍 DEBUGGING STEPS:")
    print(f"1. Check if isAudioEnabled is true in the app")
    print(f"2. Check if hasAudioForCurrentStep() returns true")
    print(f"3. Check if playCurrentStepAudio() is being called")
    print(f"4. Check Xcode console for debug messages")
    print(f"5. Verify audio files are in the app bundle")
    
    print(f"\n📋 COMMON ISSUES:")
    print(f"• Audio is disabled (isAudioEnabled = false)")
    print(f"• Audio files not in app bundle")
    print(f"• AudioService not finding files")
    print(f"• Audio session not properly configured")
    print(f"• Step timing issues")
    
    if audio_files_found == len(brewing_steps):
        print(f"\n✅ ALL AUDIO FILES FOUND!")
        print(f"The issue is likely in the app logic, not the files.")
    else:
        print(f"\n❌ SOME AUDIO FILES MISSING!")
        print(f"Check file paths and ensure files are in the correct location.")

if __name__ == "__main__":
    debug_audio_playback()
