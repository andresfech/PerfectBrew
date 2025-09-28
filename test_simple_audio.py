#!/usr/bin/env python3
"""
Simple test to verify audio files are accessible.
This tests the actual file structure that should work with PBXFileSystemSynchronizedRootGroup.
"""

import os

def test_audio_structure():
    print("🔍 Testing Audio File Structure")
    print("=" * 50)
    
    # Test the 2021 World Champion audio files
    base_path = "PerfectBrew/Resources/Audio"
    world_champ_path = f"{base_path}/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted"
    
    print(f"Base path: {base_path}")
    print(f"World Champion path: {world_champ_path}")
    print()
    
    # Check if the directory exists
    if os.path.exists(world_champ_path):
        print("✅ World Champion directory exists")
        
        # List all files in the directory
        files = os.listdir(world_champ_path)
        audio_files = [f for f in files if f.endswith('.mp3')]
        
        print(f"✅ Found {len(audio_files)} audio files:")
        for file in sorted(audio_files):
            print(f"   - {file}")
        
        print("\n🎯 EXPECTED BEHAVIOR:")
        print("With PBXFileSystemSynchronizedRootGroup, these files should be available in the app bundle.")
        print("The AudioService should find them using:")
        print(f'   Bundle.main.url(forResource: "filename.mp3", withExtension: nil, subdirectory: "Audio/AeroPress/World_Champions/2021_World_AeroPress_Champion_Tuomas_Merikanto_Finland_Inverted")')
        
        print("\n📋 NEXT STEPS:")
        print("1. Open Xcode (if available)")
        print("2. Build and run the app")
        print("3. Test the 2021 World Champion recipe")
        print("4. Check Xcode console for debug messages")
        
        if len(audio_files) == 8:
            print("\n✅ All 8 expected audio files are present!")
        else:
            print(f"\n⚠️  Expected 8 files, found {len(audio_files)}")
            
    else:
        print("❌ World Champion directory not found")
        print("This means the audio files are not in the expected location")
        
        # Check if the base Audio directory exists
        if os.path.exists(base_path):
            print(f"✅ Base Audio directory exists: {base_path}")
            
            # List what's in the Audio directory
            print("\nContents of Audio directory:")
            for item in os.listdir(base_path):
                item_path = os.path.join(base_path, item)
                if os.path.isdir(item_path):
                    print(f"   📁 {item}/")
                else:
                    print(f"   📄 {item}")
        else:
            print(f"❌ Base Audio directory not found: {base_path}")

if __name__ == "__main__":
    test_audio_structure()
