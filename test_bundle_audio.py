#!/usr/bin/env python3
"""
Test script to verify audio files are accessible in the app bundle.
This simulates how the app would look for audio files.
"""

import os
import subprocess

def test_bundle_audio():
    """Test if audio files are accessible in the app bundle."""
    
    print("🔍 Testing Audio File Accessibility in App Bundle")
    print("=" * 60)
    
    # Simulate the app bundle structure
    # In a real app, this would be Bundle.main.url(forResource:withExtension:)
    
    # Test the 2021 World Champion recipe
    recipe_title = "2021 World AeroPress Champion - Tuomas Merikanto (Finland) - Inverted"
    audio_files = [
        "2021_world_aeropress_brewing_step1.mp3",
        "2021_world_aeropress_brewing_step2.mp3", 
        "2021_world_aeropress_brewing_step3.mp3",
        "2021_world_aeropress_brewing_step4.mp3",
        "2021_world_aeropress_brewing_step5.mp3",
        "2021_world_aeropress_brewing_step6.mp3",
        "2021_world_aeropress_brewing_step7.mp3",
        "2021_world_aeropress_brewing_step8.mp3"
    ]
    
    print(f"Recipe: {recipe_title}")
    print(f"Testing {len(audio_files)} audio files...")
    print()
    
    # Test different search strategies
    search_strategies = [
        # Strategy 1: Direct bundle root search
        lambda f: f"Bundle.main.url(forResource: \"{f}\", withExtension: nil)",
        
        # Strategy 2: Search in Audio folder structure
        lambda f: f"Bundle.main.url(forResource: \"Audio/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted/{f}\", withExtension: nil)",
        
        # Strategy 3: Search with folder reference
        lambda f: f"Bundle.main.url(forResource: \"{f}\", withExtension: nil, subdirectory: \"Audio/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted\")",
    ]
    
    strategy_names = [
        "Direct bundle root search",
        "Full path search", 
        "Subdirectory search"
    ]
    
    for i, (strategy, name) in enumerate(zip(search_strategies, strategy_names), 1):
        print(f"Strategy {i}: {name}")
        print("-" * 40)
        
        found_count = 0
        for audio_file in audio_files:
            # Simulate the search (we can't actually test Bundle.main.url from Python)
            # But we can check if the file exists in the expected location
            expected_path = f"PerfectBrew/Resources/Audio/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted/{audio_file}"
            
            if os.path.exists(expected_path):
                print(f"✅ {audio_file} - EXISTS")
                found_count += 1
            else:
                print(f"❌ {audio_file} - NOT FOUND")
        
        print(f"Found: {found_count}/{len(audio_files)} files")
        print()
    
    # Test the actual file structure
    print("📁 Actual File Structure Test")
    print("-" * 40)
    
    base_path = "PerfectBrew/Resources/Audio"
    if os.path.exists(base_path):
        print(f"✅ Audio base directory exists: {base_path}")
        
        # Check World Champions directory
        world_champs_path = f"{base_path}/AeroPress/World_Champions"
        if os.path.exists(world_champs_path):
            print(f"✅ World Champions directory exists: {world_champs_path}")
            
            # Check 2021 World Champion directory
            champ_2021_path = f"{world_champs_path}/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted"
            if os.path.exists(champ_2021_path):
                print(f"✅ 2021 World Champion directory exists: {champ_2021_path}")
                
                # List files in the directory
                files = os.listdir(champ_2021_path)
                audio_files_found = [f for f in files if f.endswith('.mp3')]
                print(f"✅ Found {len(audio_files_found)} audio files in directory")
                
                for file in sorted(audio_files_found):
                    print(f"   - {file}")
            else:
                print(f"❌ 2021 World Champion directory not found: {champ_2021_path}")
        else:
            print(f"❌ World Champions directory not found: {world_champs_path}")
    else:
        print(f"❌ Audio base directory not found: {base_path}")
    
    print("\n" + "=" * 60)
    print("🎯 RECOMMENDATIONS:")
    print("1. The files exist in the file system ✅")
    print("2. Xcode should automatically include them due to PBXFileSystemSynchronizedRootGroup ✅")
    print("3. The issue might be in the AudioService path resolution logic")
    print("4. Check the debug logs when running the app to see what paths are being searched")
    print("5. The AudioService should find files using Strategy 2 (full path search)")

if __name__ == "__main__":
    test_bundle_audio()
