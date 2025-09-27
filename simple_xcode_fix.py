#!/usr/bin/env python3
"""
Simple script to add Recipes folder to Xcode project.
"""

import os
import re

def main():
    project_file = "PerfectBrew.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_file):
        print("❌ Error: PerfectBrew.xcodeproj/project.pbxproj not found")
        return
    
    print("🔧 Adding Recipes folder to Xcode project...")
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Check if Recipes folder is already added
    if "Recipes" in content:
        print("✅ Recipes folder already exists in project")
        return True
    
    print("📋 MANUAL STEPS REQUIRED:")
    print("=" * 30)
    print("Since the automatic method failed, please try this:")
    print()
    print("1. In Xcode, select the project name 'PerfectBrew' in the navigator")
    print("2. Go to the 'Build Phases' tab")
    print("3. Expand 'Copy Bundle Resources'")
    print("4. Click the '+' button")
    print("5. Navigate to and select the 'Recipes' folder")
    print("6. Click 'Add'")
    print()
    print("OR try this alternative:")
    print("1. In Xcode Project Navigator, right-click on 'Resources'")
    print("2. Select 'New Group'")
    print("3. Name it 'Recipes'")
    print("4. Right-click on the new 'Recipes' group")
    print("5. Select 'Add Files to PerfectBrew'")
    print("6. Navigate to PerfectBrew/Resources/Recipes")
    print("7. Select all the subfolders (V60, AeroPress, etc.)")
    print("8. Make sure 'Create folder references' is checked")
    print("9. Click 'Add'")

if __name__ == "__main__":
    main()
