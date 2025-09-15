#!/usr/bin/env python3
"""
Script para generar audio en ESPAÑOL para todas las recetas usando Chatterbox Multilingual TTS
"""

import json
import os
import torch
import torchaudio as ta
from chatterbox.mtl_tts import ChatterboxMultilingualTTS

def load_all_recipes():
    """Cargar todas las recetas de todos los archivos JSON"""
    recipes = []
    
    recipe_files = [
        "PerfectBrew/Resources/recipes_aeropress.json",
        "PerfectBrew/Resources/recipes_v60.json", 
        "PerfectBrew/Resources/recipes_frenchpress.json"
    ]
    
    for file_path in recipe_files:
        if os.path.exists(file_path):
            print(f"📖 Cargando recetas de: {file_path}")
            with open(file_path, 'r', encoding='utf-8') as f:
                file_recipes = json.load(f)
                recipes.extend(file_recipes)
                print(f"   ✅ {len(file_recipes)} recetas cargadas")
        else:
            print(f"⚠️  Archivo no encontrado: {file_path}")
    
    return recipes

def generate_spanish_audio_for_recipe(recipe, model, output_dir):
    """Generar audio en español para una receta completa"""
    recipe_name = recipe['title'].replace(' ', '_').replace('/', '_')
    recipe_dir = os.path.join(output_dir, recipe_name)
    os.makedirs(recipe_dir, exist_ok=True)
    
    print(f"\n🎯 Procesando: {recipe['title']}")
    print(f"📁 Directorio: {recipe_dir}")
    
    generated_files = []
    
    # Generar audio para pasos de preparación
    if 'preparation_steps' in recipe and recipe['preparation_steps']:
        prep_dir = os.path.join(recipe_dir, "preparation")
        os.makedirs(prep_dir, exist_ok=True)
        
        for i, step in enumerate(recipe['preparation_steps'], 1):
            audio_file = os.path.join(prep_dir, f"step_{i:02d}.wav")
            try:
                wav = model.generate(step, language_id="es")
                ta.save(audio_file, wav, model.sr)
                generated_files.append(audio_file)
                print(f"   ✅ Preparación paso {i}: {len(wav[0]) / model.sr:.1f}s")
            except Exception as e:
                print(f"   ❌ Error en preparación paso {i}: {e}")
    
    # Generar audio para pasos de preparación
    if 'brewing_steps' in recipe and recipe['brewing_steps']:
        brew_dir = os.path.join(recipe_dir, "brewing")
        os.makedirs(brew_dir, exist_ok=True)
        
        for i, step in enumerate(recipe['brewing_steps'], 1):
            audio_file = os.path.join(brew_dir, f"step_{i:02d}.wav")
            try:
                instruction = step.get('instruction', '')
                wav = model.generate(instruction, language_id="es")
                ta.save(audio_file, wav, model.sr)
                generated_files.append(audio_file)
                print(f"   ✅ Preparación paso {i}: {len(wav[0]) / model.sr:.1f}s")
            except Exception as e:
                print(f"   ❌ Error en preparación paso {i}: {e}")
    
    # Generar audio para notas
    if 'notes' in recipe and recipe['notes']:
        notes_file = os.path.join(recipe_dir, "notes.wav")
        try:
            wav = model.generate(recipe['notes'], language_id="es")
            ta.save(notes_file, wav, model.sr)
            generated_files.append(notes_file)
            print(f"   ✅ Notas: {len(wav[0]) / model.sr:.1f}s")
        except Exception as e:
            print(f"   ❌ Error en notas: {e}")
    
    return generated_files

def main():
    print("🎯 Generador de Audio en ESPAÑOL con Chatterbox Multilingual TTS")
    print("💰 Costo: GRATIS (Open Source)")
    print("🌍 Idioma: Español (es)")
    print("=" * 70)
    
    # Cargar todas las recetas
    recipes = load_all_recipes()
    print(f"\n📊 Total de recetas encontradas: {len(recipes)}")
    
    if not recipes:
        print("❌ No se encontraron recetas")
        return
    
    # Crear directorio de salida
    output_dir = "generated_spanish_audio"
    os.makedirs(output_dir, exist_ok=True)
    
    # Cargar modelo TTS multilingüe
    print(f"\n🤖 Cargando modelo Chatterbox Multilingual TTS...")
    try:
        # Forzar CPU
        torch.set_default_device('cpu')
        model = ChatterboxMultilingualTTS.from_pretrained(device="cpu")
        print("✅ Modelo multilingüe cargado correctamente")
    except Exception as e:
        print(f"❌ Error cargando modelo: {e}")
        return
    
    # Procesar cada receta
    total_files = 0
    successful_recipes = 0
    
    for i, recipe in enumerate(recipes, 1):
        print(f"\n{'='*50}")
        print(f"📝 Receta {i}/{len(recipes)}")
        
        try:
            files = generate_spanish_audio_for_recipe(recipe, model, output_dir)
            total_files += len(files)
            successful_recipes += 1
            print(f"✅ Completada: {len(files)} archivos generados")
        except Exception as e:
            print(f"❌ Error procesando receta: {e}")
    
    # Resumen final
    print(f"\n{'='*70}")
    print("🎉 GENERACIÓN EN ESPAÑOL COMPLETADA")
    print(f"📊 Recetas procesadas: {successful_recipes}/{len(recipes)}")
    print(f"📁 Archivos generados: {total_files}")
    print(f"📂 Directorio de salida: {output_dir}/")
    print("\n💡 Próximos pasos:")
    print("1. Revisar los archivos generados")
    print("2. Integrar en la app iOS")
    print("3. Configurar reproducción automática en español")

if __name__ == "__main__":
    main()
