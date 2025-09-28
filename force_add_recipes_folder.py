#!/usr/bin/env python3
"""
Script to forcefully add the Recipes folder to Xcode project as a folder reference.
This modifies the .pbxproj file directly.
"""

import os
import re
import uuid

def generate_uuid():
    """Generate a UUID for Xcode project file."""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_recipes_folder():
    """Add Recipes folder as folder reference to Xcode project."""
    
    project_file = "PerfectBrew.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_file):
        print("❌ Error: PerfectBrew.xcodeproj/project.pbxproj not found")
        return False
    
    print("🔧 Force adding Recipes folder to Xcode project...")
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Check if Recipes folder is already added
    if "Recipes" in content and "PBXFileReference" in content:
        print("✅ Recipes folder already exists in project")
        return True
    
    # Generate UUIDs for the new entries
    recipes_uuid = generate_uuid()
    recipes_group_uuid = generate_uuid()
    
    print(f"Generated UUIDs: {recipes_uuid}, {recipes_group_uuid}")
    
    # Find the main group (the one with PerfectBrew as children)
    main_group_pattern = r'(\w+) = \{\s*isa = PBXGroup;\s*children = \([^)]*PerfectBrew[^)]*\);'
    main_group_match = re.search(main_group_pattern, content)
    
    if not main_group_match:
        print("❌ Error: Could not find main group with PerfectBrew")
        return False
    
    main_group_uuid = main_group_match.group(1)
    print(f"Found main group: {main_group_uuid}")
    
    # Create the PBXFileReference entry for Recipes folder
    recipes_reference = f"""
		{recipes_uuid} /* Recipes */ = {{isa = PBXFileReference; lastKnownFileType = folder; path = Recipes; sourceTree = \"<group>\"; }};"""
    
    # Create the PBXGroup entry for Recipes folder
    recipes_group = f"""
		{recipes_group_uuid} /* Recipes */ = {{
			isa = PBXGroup;
			children = (
			);
			path = Recipes;
			sourceTree = \"<group>\";
		}};"""
    
    # Add the file reference before the end of PBXFileReference section
    file_refs_pattern = r'(/\* Begin PBXFileReference section \*/.*?)(/\* End PBXFileReference section \*/)'
    file_refs_match = re.search(file_refs_pattern, content, re.DOTALL)
    
    if file_refs_match:
        new_file_refs = file_refs_match.group(1) + recipes_reference + "\n" + file_refs_match.group(2)
        content = content.replace(file_refs_match.group(0), new_file_refs)
        print("✅ Added Recipes file reference")
    else:
        print("❌ Error: Could not find PBXFileReference section")
        return False
    
    # Add the group before the end of PBXGroup section
    groups_pattern = r'(/\* Begin PBXGroup section \*/.*?)(/\* End PBXGroup section \*/)'
    groups_match = re.search(groups_pattern, content, re.DOTALL)
    
    if groups_match:
        new_groups = groups_match.group(1) + recipes_group + "\n" + groups_match.group(2)
        content = content.replace(groups_match.group(0), new_groups)
        print("✅ Added Recipes group")
    else:
        print("❌ Error: Could not find PBXGroup section")
        return False
    
    # Add Recipes to the main group's children
    main_group_children_pattern = rf'({main_group_uuid} = \{{[^}}]*children = \()([^)]*)(\);'
    main_group_children_match = re.search(main_group_children_pattern, content, re.DOTALL)
    
    if main_group_children_match:
        children = main_group_children_match.group(2)
        new_children = children + f"\n				{recipes_group_uuid} /* Recipes */,"
        new_main_group = main_group_children_match.group(1) + new_children + main_group_children_match.group(3)
        content = content.replace(main_group_children_match.group(0), new_main_group)
        print("✅ Added Recipes to main group children")
    else:
        print("❌ Error: Could not find main group children")
        return False
    
    # Write the modified content back
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Successfully added Recipes folder to Xcode project")
    print("📋 Next steps:")
    print("   1. Open PerfectBrew.xcodeproj in Xcode")
    print("   2. Verify Recipes folder appears with blue icon")
    print("   3. Build and run the app")
    print("   4. Check that recipes load correctly")
    
    return True

if __name__ == "__main__":
    add_recipes_folder()
