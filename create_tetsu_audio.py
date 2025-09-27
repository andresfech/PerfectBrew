#!/usr/bin/env python3

import json
import os
import subprocess
import sys

# Leer la receta
with open('PerfectBrew/Resources/Recipes/V60/Tetsu_Kasuya/V60_Tetsu_Kasuya_single_serve.json', 'r') as f:
    recipe_data = json.load(f)

recipe = recipe_data[0]

# Crear directorio de salida
output_dir = "PerfectBrew/Resources/Audio/V60/Tetsu_Kasuya"
os.makedirs(output_dir, exist_ok=True)

print("🎵 Generating Tetsu Kasuya audio files with unique names...")

# Generar audios para preparation_steps
for i, step in enumerate(recipe['preparation_steps'], 1):
    filename = f"tetsu_preparation_step_{i:02d}.wav"
    output_path = os.path.join(output_dir, filename)
    
    print(f"Generating: {filename}")
    print(f"Text: {step}")
    
    # Crear un archivo temporal con el texto
    temp_file = f"temp_text_{i}.txt"
    with open(temp_file, 'w') as f:
        f.write(step)
    
    # Usar el generador de audio
    cmd = [
        "python3", "universal_audio_generator.py",
        "--recipes", "PerfectBrew/Resources/recipes_v60.json",
        "--output", output_dir,
        "--recipe", "Tetsu Kasuya 4:6 Method (Original)",
        "--device", "cpu"
    ]
    
    try:
        # Generar solo este archivo específico
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ Generated: {filename}")
        else:
            print(f"❌ Error generating {filename}: {result.stderr}")
    except Exception as e:
        print(f"❌ Error generating {filename}: {e}")
    
    # Limpiar archivo temporal
    if os.path.exists(temp_file):
        os.remove(temp_file)

print("🎉 Tetsu Kasuya audio generation complete!")
