#!/usr/bin/env python3
"""
Script to add audio files to Xcode project.pbxproj file.
This will add the audio files so they're included in the app bundle.
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
    
    print("🔧 Adding Audio Files to Xcode Project")
    print("=" * 50)
    
    # Read the project file
    with open(project_file, 'r') as f:
        content = f.read()
    
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
    
    # Check if we already have file references
    if "/* Audio" in content:
        print("⚠️  Audio files may already be in project")
        return True
    
    # Generate file references for audio files
    file_refs = []
    file_ref_ids = []
    
    for audio_file in audio_files:
        file_id = generate_uuid()
        file_ref_ids.append(file_id)
        file_refs.append(f'\t\t{file_id} /* {os.path.basename(audio_file)} */ = {{isa = PBXFileReference; lastKnownFileType = audio.mp3; path = "{os.path.basename(audio_file)}"; sourceTree = "<group>"; }};')
    
    # Add file references to the project
    file_refs_section = '\n'.join(file_refs)
    
    # Find the PBXFileReference section and add our file references
    file_ref_pattern = r'(/\* Begin PBXFileReference section \*/\n)(.*?)(/\* End PBXFileReference section \*/)'
    file_ref_match = re.search(file_ref_pattern, content, re.DOTALL)
    
    if file_ref_match:
        new_file_refs = file_ref_match.group(1) + file_refs_section + '\n' + file_ref_match.group(2)
        content = content.replace(file_ref_match.group(0), new_file_refs)
    
    # Add files to Resources build phase
    build_phase_pattern = r'(F49730982E35356D001D8E6D /\* Resources \*/ = \{[^}]+files = \(([^)]*)\);[^}]+};)'
    build_phase_match = re.search(build_phase_pattern, content, re.DOTALL)
    
    if build_phase_match:
        existing_build_files = build_phase_match.group(2)
        new_build_files = existing_build_files
        if new_build_files.strip():
            new_build_files += '\n'
        
        for file_id in file_ref_ids:
            new_build_files += f'\t\t\t{file_id} /* {os.path.basename(audio_files[file_ref_ids.index(file_id)])} */,\n'
        
        new_build_phase = f'F49730982E35356D001D8E6D /* Resources */ = {{\n\t\t\tisa = PBXResourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n{new_build_files}\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t}};'
        
        content = content.replace(build_phase_match.group(1), new_build_phase)
    
    # Write the updated project file
    with open(project_file, 'w') as f:
        f.write(content)
    
    print("✅ Successfully added audio files to Xcode project")
    return True

if __name__ == "__main__":
    if add_audio_files_to_xcode():
        print("\n🎉 Audio files have been added to the Xcode project!")
        print("📋 Next steps:")
        print("1. Open the project in Xcode")
        print("2. Build and run the app")
        print("3. Test audio playback in the 2021 World Champion recipe")
    else:
        print("\n❌ Failed to add audio files to Xcode project")
