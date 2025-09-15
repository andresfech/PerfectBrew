#!/usr/bin/env python3
"""
Script para generar audio organizado para TODAS las recetas
Usando modelo en inglés que funciona correctamente
"""

import json
import os
import torch
import torchaudio as ta
from chatterbox.tts import ChatterboxTTS

def load_recipes_by_method():
    """Cargar recetas organizadas por método de preparación"""
    recipes_by_method = {
        "AeroPress": [],
        "V60": [],
        "FrenchPress": []
    }
    
    # Archivos de recetas
    recipe_files = [
        ("PerfectBrew/Resources/recipes_aeropress.json", "AeroPress"),
        ("PerfectBrew/Resources/recipes_v60.json", "V60"),
        ("PerfectBrew/Resources/recipes_frenchpress.json", "FrenchPress")
    ]
    
    for file_path, method in recipe_files:
        if os.path.exists(file_path):
            print(f"📖 Cargando recetas de {method}: {file_path}")
            with open(file_path, 'r', encoding='utf-8') as f:
                recipes = json.load(f)
                recipes_by_method[method] = recipes
                print(f"   ✅ {len(recipes)} recetas cargadas")
        else:
            print(f"⚠️  Archivo no encontrado: {file_path}")
    
    return recipes_by_method

def create_ios_audio_structure():
    """Crear estructura de directorios para audio en iOS"""
    ios_audio_dir = "PerfectBrew/Resources/Audio"
    
    # Crear directorios base
    methods = ["AeroPress", "V60", "FrenchPress"]
    for method in methods:
        method_dir = os.path.join(ios_audio_dir, method)
        os.makedirs(method_dir, exist_ok=True)
        print(f"📁 Creado directorio: {method_dir}")
    
    return ios_audio_dir

def generate_audio_for_recipe(recipe, model, output_dir, method):
    """Generar audio para una receta completa"""
    # Limpiar nombre de receta para directorio
    recipe_name = recipe['title'].replace(' ', '_').replace('/', '_').replace('-', '_')
    recipe_dir = os.path.join(output_dir, method, recipe_name)
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
    print("🎯 Generador de Audio Organizado para PerfectBrew")
    print("💰 Costo: GRATIS (Chatterbox TTS)")
    print("🌍 Idioma: Inglés (funciona correctamente)")
    print("=" * 70)
    
    # Cargar recetas organizadas
    recipes_by_method = load_recipes_by_method()
    
    total_recipes = sum(len(recipes) for recipes in recipes_by_method.values())
    print(f"\n📊 Total de recetas: {total_recipes}")
    for method, recipes in recipes_by_method.items():
        print(f"   {method}: {len(recipes)} recetas")
    
    # Crear estructura de directorios iOS
    ios_audio_dir = create_ios_audio_structure()
    
    # Cargar modelo TTS (inglés, que funciona)
    print(f"\n🤖 Cargando modelo Chatterbox TTS (inglés)...")
    try:
        torch.set_default_device('cpu')
        model = ChatterboxTTS.from_pretrained(device="cpu")
        print("✅ Modelo cargado correctamente")
    except Exception as e:
        print(f"❌ Error cargando modelo: {e}")
        return
    
    # Procesar cada método de preparación
    total_files = 0
    successful_recipes = 0
    
    for method, recipes in recipes_by_method.items():
        if not recipes:
            continue
            
        print(f"\n{'='*60}")
        print(f"☕ Procesando {method} ({len(recipes)} recetas)")
        print('='*60)
        
        for i, recipe in enumerate(recipes, 1):
            print(f"\n📝 Receta {i}/{len(recipes)}: {recipe['title']}")
            
            try:
                files = generate_audio_for_recipe(recipe, model, ios_audio_dir, method)
                total_files += len(files)
                successful_recipes += 1
                print(f"✅ Completada: {len(files)} archivos generados")
            except Exception as e:
                print(f"❌ Error procesando receta: {e}")
    
    # Resumen final
    print(f"\n{'='*70}")
    print("🎉 GENERACIÓN ORGANIZADA COMPLETADA")
    print(f"📊 Recetas procesadas: {successful_recipes}/{total_recipes}")
    print(f"📁 Archivos generados: {total_files}")
    print(f"📂 Estructura iOS: {ios_audio_dir}")
    print("\n📁 Estructura generada:")
    print("PerfectBrew/Resources/Audio/")
    print("├── AeroPress/")
    print("│   ├── 2024_World_Champion_AeroPress/")
    print("│   ├── James_Hoffmann_Ultimate_AeroPress/")
    print("│   └── ...")
    print("├── V60/")
    print("│   ├── James_Hoffmann_V60_Single_Serve/")
    print("│   └── ...")
    print("└── FrenchPress/")
    print("    ├── James_Hoffmann_French_Press_Method/")
    print("    └── ...")
    print("\n💡 Próximos pasos:")
    print("1. Verificar archivos en Xcode")
    print("2. Actualizar AudioService.swift")
    print("3. Probar reproducción en la app")

if __name__ == "__main__":
    main()
