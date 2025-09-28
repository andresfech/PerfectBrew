#!/usr/bin/env python3
"""
Quick Audio Generator - Creates placeholder audio files for testing
"""

import json
import os
import wave
import struct

def create_silent_audio(duration_seconds=3, sample_rate=44100, filename="silent.wav"):
    """Create a silent audio file for testing."""
    # Calculate number of frames
    num_frames = int(duration_seconds * sample_rate)
    
    # Create silent audio data (16-bit PCM)
    audio_data = [0] * num_frames
    
    # Convert to bytes
    audio_bytes = struct.pack('<' + 'h' * num_frames, *audio_data)
    
    # Write WAV file
    with wave.open(filename, 'wb') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(audio_bytes)

def generate_quick_audio():
    """Generate quick placeholder audio files for 2021 Tuomas recipe."""
    print("🚀 Quick Audio Generator for 2021 Tuomas Recipe")
    print("=" * 50)
    
    # Load recipe
    recipe_file = "PerfectBrew/Resources/Recipes/AeroPress/World_Champions/2021_Tuomas_Merikanto_Finland/AeroPress_2021_Tuomas_Merikanto_single_serve.json"
    
    with open(recipe_file, 'r') as f:
        recipe = json.load(f)
    
    if isinstance(recipe, list):
        recipe = recipe[0]
    
    title = recipe.get('title', 'Unknown Recipe')
    print(f"📝 Recipe: {title}")
    
    # Create output directory
    output_dir = "PerfectBrew/Resources/Audio/AeroPress/World_Champions/2021_Tuomas_Merikanto"
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate audio files for each brewing step
    if 'brewing_steps' in recipe:
        brewing_steps = recipe['brewing_steps']
        print(f"🎬 Creating {len(brewing_steps)} audio files...")
        
        for i, step in enumerate(brewing_steps, 1):
            audio_file_name = step.get('audio_file_name', f"step_{i:02d}.mp3")
            output_path = os.path.join(output_dir, audio_file_name)
            
            # Create silent audio file (3 seconds)
            create_silent_audio(3, filename=output_path)
            
            audio_script = step.get('audio_script', '')
            print(f"    ✅ Created: {audio_file_name}")
            print(f"       Script: {audio_script[:60]}...")
    
    print(f"🎉 Quick audio generation complete!")
    print(f"📁 Files saved to: {output_dir}")

if __name__ == "__main__":
    generate_quick_audio()

