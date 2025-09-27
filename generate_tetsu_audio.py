#!/usr/bin/env python3

import json
import subprocess
import os

# Leer la receta
with open('PerfectBrew/Resources/Recipes/V60/Tetsu_Kasuya/V60_Tetsu_Kasuya_single_serve.json', 'r') as f:
    recipe_data = json.load(f)

recipe = recipe_data[0]

# Crear directorio de salida
output_dir = "PerfectBrew/Resources/Audio/V60/Tetsu_Kasuya"
os.makedirs(output_dir, exist_ok=True)

# Generar audios para preparation_steps
for i, step in enumerate(recipe['preparation_steps'], 1):
    filename = f"tetsu_preparation_step_{i:02d}.wav"
    output_path = os.path.join(output_dir, filename)
    
    print(f"Generating: {filename}")
    print(f"Text: {step}")
    
    # Usar el script de generación de audio directamente
    cmd = [
        "python3", "universal_audio_generator.py",
        "--text", step,
        "--output", output_path,
        "--device", "cpu"
    ]
    
    try:
        subprocess.run(cmd, check=True)
        print(f"✅ Generated: {filename}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error generating {filename}: {e}")

# Generar audios para brewing_steps
for i, step in enumerate(recipe['brewing_steps'], 1):
    filename = f"tetsu_brewing_step_{i:02d}.wav"
    output_path = os.path.join(output_dir, filename)
    
    print(f"Generating: {filename}")
    print(f"Text: {step['audio_script']}")
    
    # Usar el script de generación de audio directamente
    cmd = [
        "python3", "universal_audio_generator.py",
        "--text", step['audio_script'],
        "--output", output_path,
        "--device", "cpu"
    ]
    
    try:
        subprocess.run(cmd, check=True)
        print(f"✅ Generated: {filename}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error generating {filename}: {e}")

print("🎉 All audio files generated!")
