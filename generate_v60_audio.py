#!/usr/bin/env python3
"""
Script para generar audio SOLO para recetas V60
"""

import json
import os
import torch
import torchaudio as ta
from chatterbox.tts import ChatterboxTTS

def load_v60_recipes():
    """Cargar solo las recetas V60"""
    file_path = "PerfectBrew/Resources/recipes_v60.json"
    
    if not os.path.exists(file_path):
        print(f"❌ Archivo no encontrado: {file_path}")
        return []
    
    print(f"📖 Cargando recetas V60: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        recipes = json.load(f)
        print(f"   ✅ {len(recipes)} recetas V60 cargadas")
    
    return recipes

def create_v60_audio_structure():
    """Crear estructura de directorios para audio V60"""
    ios_audio_dir = "PerfectBrew/Resources/Audio/V60"
    os.makedirs(ios_audio_dir, exist_ok=True)
    print(f"📁 Creado directorio: {ios_audio_dir}")
    return ios_audio_dir

def generate_audio_for_v60_recipe(recipe, model, output_dir):
    """Generar audio para una receta V60"""
    # Limpiar nombre de receta para directorio
    recipe_name = recipe['title'].replace(' ', '_').replace('/', '_').replace('-', '_')
    recipe_dir = os.path.join(output_dir, recipe_name)
    os.makedirs(recipe_dir, exist_ok=True)
    
    print(f"\n🎯 Procesando: {recipe['title']}")
    print(f"📁 Directorio: {recipe_dir}")
    
    generated_files = []
    
    # Generar audio para pasos de preparación
    if 'preparation_steps' in recipe and recipe['preparation_steps']:
        for i, step in enumerate(recipe['preparation_steps'], 1):
            audio_file = os.path.join(recipe_dir, f"preparation_step_{i:02d}.wav")
            try:
                wav = model.generate(step)
                ta.save(audio_file, wav, model.sr)
                generated_files.append(audio_file)
                print(f"   ✅ Preparación paso {i}: {len(wav[0]) / model.sr:.1f}s")
            except Exception as e:
                print(f"   ❌ Error en preparación paso {i}: {e}")
    
    # Generar audio para pasos de preparación
    if 'brewing_steps' in recipe and recipe['brewing_steps']:
        for i, step in enumerate(recipe['brewing_steps'], 1):
            audio_file = os.path.join(recipe_dir, f"brewing_step_{i:02d}.wav")
            try:
                # Usar la instrucción completa (instruction)
                instruction = step.get('instruction', '')
                wav = model.generate(instruction)
                ta.save(audio_file, wav, model.sr)
                generated_files.append(audio_file)
                print(f"   ✅ Preparación paso {i}: {len(wav[0]) / model.sr:.1f}s")
            except Exception as e:
                print(f"   ❌ Error en preparación paso {i}: {e}")
    
    # Generar audio para notas (si existen)
    if 'notes' in recipe and recipe['notes']:
        notes_file = os.path.join(recipe_dir, "notes.wav")
        try:
            wav = model.generate(recipe['notes'])
            ta.save(notes_file, wav, model.sr)
            generated_files.append(notes_file)
            print(f"   ✅ Notas: {len(wav[0]) / model.sr:.1f}s")
        except Exception as e:
            print(f"   ❌ Error en notas: {e}")
    
    return generated_files

def main():
    print("🎯 Generador de Audio para Recetas V60")
    print("💰 Costo: GRATIS (Chatterbox TTS)")
    print("🌍 Idioma: Inglés")
    print("=" * 60)
    
    # Cargar recetas V60
    recipes = load_v60_recipes()
    
    if not recipes:
        print("❌ No se encontraron recetas V60")
        return
    
    print(f"\n📊 Total de recetas V60: {len(recipes)}")
    
    # Crear estructura de directorios
    v60_audio_dir = create_v60_audio_structure()
    
    # Cargar modelo TTS
    print(f"\n🤖 Cargando modelo Chatterbox TTS...")
    try:
        torch.set_default_device('cpu')
        model = ChatterboxTTS.from_pretrained(device="cpu")
        print("✅ Modelo cargado correctamente")
    except Exception as e:
        print(f"❌ Error cargando modelo: {e}")
        return
    
    # Procesar cada receta V60
    total_files = 0
    successful_recipes = 0
    
    print(f"\n{'='*60}")
    print(f"☕ Procesando {len(recipes)} recetas V60")
    print('='*60)
    
    for i, recipe in enumerate(recipes, 1):
        print(f"\n📝 Receta {i}/{len(recipes)}: {recipe['title']}")
        
        try:
            files = generate_audio_for_v60_recipe(recipe, model, v60_audio_dir)
            total_files += len(files)
            successful_recipes += 1
            print(f"✅ Completada: {len(files)} archivos generados")
        except Exception as e:
            print(f"❌ Error procesando receta: {e}")
    
    # Resumen final
    print(f"\n{'='*60}")
    print("🎉 GENERACIÓN V60 COMPLETADA")
    print(f"📊 Recetas procesadas: {successful_recipes}/{len(recipes)}")
    print(f"📁 Archivos generados: {total_files}")
    print(f"📂 Estructura: {v60_audio_dir}")
    print("\n📁 Estructura generada:")
    print("PerfectBrew/Resources/Audio/V60/")
    print("├── James_Hoffmann_V60_Single_Serve/")
    print("├── James_Hoffmann_V60_Two_People/")
    print("├── Scott_Rao_V60_Two_People/")
    print("└── ...")
    print("\n💡 Próximos pasos:")
    print("1. Verificar archivos en Xcode")
    print("2. Probar reproducción en la app")

if __name__ == "__main__":
    main()
