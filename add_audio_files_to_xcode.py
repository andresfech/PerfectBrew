#!/usr/bin/env python3
"""
Script to add audio files to Xcode project.pbxproj file.
This will add the audio files to the project so they're included in the app bundle.
"""

import os
import re
import uuid

def generate_uuid():
    """Generate a UUID for Xcode project entries."""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_audio_files_to_xcode():
    """Add audio files to the Xcode project."""
    
    project_file = "PerfectBrew.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_file):
        print("❌ Error: project.pbxproj not found")
        return False
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Find the Resources group section
    resources_group_pattern = r'(/\* Resources \*/ = \{[^}]+files = \(([^)]*)\);)'
    match = re.search(resources_group_pattern, content, re.DOTALL)
    
    if not match:
        print("❌ Error: Could not find Resources group in project file")
        return False
    
    resources_section = match.group(1)
    existing_files = match.group(2)
    
    # Get all audio files
    audio_files = []
    audio_dir = "PerfectBrew/Resources/Audio"
    
    if not os.path.exists(audio_dir):
        print("❌ Error: Audio directory not found")
        return False
    
    # Walk through audio directory and find all audio files
    for root, dirs, files in os.walk(audio_dir):
        for file in files:
            if file.endswith(('.mp3', '.wav', '.m4a', '.aac')):
                rel_path = os.path.relpath(os.path.join(root, file), "PerfectBrew")
                audio_files.append(rel_path)
    
    print(f"Found {len(audio_files)} audio files to add")
    
    # Generate file references for audio files
    file_refs = []
    build_phase_refs = []
    
    for audio_file in audio_files:
        file_id = generate_uuid()
        file_refs.append(f'\t\t{file_id} /* {os.path.basename(audio_file)} */ = {{isa = PBXFileReference; lastKnownFileType = audio.mp3; path = "{os.path.basename(audio_file)}"; sourceTree = "<group>"; }};')
        build_phase_refs.append(f'\t\t\t{file_id} /* {os.path.basename(audio_file)} */,')
    
    # Add file references to the project
    file_refs_section = '\n'.join(file_refs)
    
    # Find the PBXFileReference section and add our file references
    file_ref_pattern = r'(/\* Begin PBXFileReference section \*/\n)(.*?)(/\* End PBXFileReference section \*/)'
    file_ref_match = re.search(file_ref_pattern, content, re.DOTALL)
    
    if file_ref_match:
        new_file_refs = file_ref_match.group(1) + file_refs_section + '\n' + file_ref_match.group(2)
        content = content.replace(file_ref_match.group(0), new_file_refs)
    
    # Add files to Resources group
    new_resources_files = existing_files
    if new_resources_files.strip():
        new_resources_files += '\n'
    
    for audio_file in audio_files:
        file_id = generate_uuid()
        new_resources_files += f'\t\t\t{file_id} /* {os.path.basename(audio_file)} */,\n'
    
    new_resources_section = f'/* Resources */ = {{\n\t\tisa = PBXGroup;\n\t\tchildren = (\n{new_resources_files}\t\t);\n\t\tpath = Resources;\n\t\tsourceTree = "<group>";\n\t}};'
    
    # Replace the Resources section
    content = content.replace(resources_section, new_resources_section)
    
    # Add files to Resources build phase
    build_phase_pattern = r'(F49730982E35356D001D8E6D /\* Resources \*/ = \{[^}]+files = \(([^)]*)\);[^}]+};)'
    build_phase_match = re.search(build_phase_pattern, content, re.DOTALL)
    
    if build_phase_match:
        existing_build_files = build_phase_match.group(2)
        new_build_files = existing_build_files
        if new_build_files.strip():
            new_build_files += '\n'
        
        for audio_file in audio_files:
            file_id = generate_uuid()
            new_build_files += f'\t\t\t{file_id} /* {os.path.basename(audio_file)} */,\n'
        
        new_build_phase = f'F49730982E35356D001D8E6D /* Resources */ = {{\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n{new_build_files}\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};'
        
        content = content.replace(build_phase_match.group(1), new_build_phase)
    
    # Write the updated project file
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Successfully added audio files to Xcode project")
    return True

if __name__ == "__main__":
    print("🔧 Adding Audio Files to Xcode Project")
    print("=" * 50)
    
    if add_audio_files_to_xcode():
        print("\n🎉 Audio files have been added to the Xcode project!")
        print("📋 Next steps:")
        print("1. Open the project in Xcode")
        print("2. Build and run the app")
        print("3. Test audio playback in the 2021 World Champion recipe")
    else:
        print("\n❌ Failed to add audio files to Xcode project")
