#!/usr/bin/env python3
"""
Script to help add the Recipes folder to Xcode as a folder reference.
This ensures the hierarchical recipe structure is included in the app bundle.
"""

import os
import subprocess

def main():
    print("🔧 Xcode Recipe Folder Setup Helper")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not os.path.exists("PerfectBrew.xcodeproj"):
        print("❌ Error: PerfectBrew.xcodeproj not found. Please run this from the project root.")
        return
    
    # Check if Recipes folder exists
    recipes_path = "PerfectBrew/Resources/Recipes"
    if not os.path.exists(recipes_path):
        print(f"❌ Error: {recipes_path} not found.")
        return
    
    print(f"✅ Found Recipes folder at: {recipes_path}")
    
    # Count recipe files
    recipe_count = 0
    for root, dirs, files in os.walk(recipes_path):
        recipe_count += len([f for f in files if f.endswith('.json')])
    
    print(f"✅ Found {recipe_count} recipe files")
    
    print("\n📋 MANUAL STEPS REQUIRED:")
    print("=" * 30)
    print("1. Open PerfectBrew.xcodeproj in Xcode")
    print("2. In the Project Navigator (left sidebar):")
    print("   - Right-click on 'Resources' folder")
    print("   - Select 'Add Files to PerfectBrew'")
    print("3. Navigate to and select the 'Recipes' folder")
    print("4. IMPORTANT: Check 'Create folder references' (not 'Create groups')")
    print("5. Click 'Add'")
    print("\n6. Verify the Recipes folder appears in Xcode with a blue folder icon")
    print("   (Blue = folder reference, Yellow = group)")
    
    print(f"\n🎯 Expected Result:")
    print(f"   - Recipes folder should be blue (folder reference)")
    print(f"   - All {recipe_count} JSON files should be visible")
    print(f"   - App should load recipes from hierarchical structure")
    
    print(f"\n🔍 To verify it worked:")
    print(f"   - Build and run the app")
    print(f"   - Check debug info shows recipes loaded")
    print(f"   - V60 recipes should appear in the app")

if __name__ == "__main__":
    main()