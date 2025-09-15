#!/usr/bin/env python3
"""
Script para generar audio SOLO para la receta "Kaldi's Coffee - Single Serve"
"""

import json
import os
import torch
import torchaudio as ta
from chatterbox.tts import ChatterboxTTS

def load_kaldi_recipe():
    """Cargar la receta específica de Kaldi's Coffee"""
    file_path = "PerfectBrew/Resources/recipes_v60.json"
    
    if not os.path.exists(file_path):
        print(f"❌ Archivo no encontrado: {file_path}")
        return None
    
    print(f"📖 Cargando recetas V60: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        recipes = json.load(f)
    
    # Buscar la receta específica
    for recipe in recipes:
        if recipe['title'] == "Kaldi's Coffee - Single Serve":
            print(f"   ✅ Receta encontrada: {recipe['title']}")
            return recipe
    
    print(f"❌ Receta 'Kaldi's Coffee - Single Serve' no encontrada")
    return None

def create_kaldi_audio_structure():
    """Crear estructura de directorios para audio de Kaldi's Coffee"""
    # Crear directorio específico para esta receta
    recipe_name = "Kaldi_Coffee_Single_Serve"
    ios_audio_dir = f"PerfectBrew/Resources/Audio/V60/{recipe_name}"
    os.makedirs(ios_audio_dir, exist_ok=True)
    print(f"📁 Creado directorio: {ios_audio_dir}")
    return ios_audio_dir

def generate_audio_for_kaldi_recipe(recipe, model, output_dir):
    """Generar audio para la receta de Kaldi's Coffee"""
    print(f"\n🎯 Procesando: {recipe['title']}")
    print(f"📁 Directorio: {output_dir}")
    
    generated_files = []
    
    # Generar audio para pasos de preparación
    if 'preparation_steps' in recipe and recipe['preparation_steps']:
        print(f"\n📝 Generando audio para {len(recipe['preparation_steps'])} pasos de preparación...")
        for i, step in enumerate(recipe['preparation_steps'], 1):
            audio_file = os.path.join(output_dir, f"preparation_step_{i:02d}.wav")
            try:
                print(f"   🎤 Generando preparación paso {i}: '{step[:50]}...'")
                wav = model.generate(step)
                ta.save(audio_file, wav, model.sr)
                generated_files.append(audio_file)
                print(f"   ✅ Preparación paso {i}: {len(wav[0]) / model.sr:.1f}s")
            except Exception as e:
                print(f"   ❌ Error en preparación paso {i}: {e}")
    
    # Generar audio para pasos de preparación
    if 'brewing_steps' in recipe and recipe['brewing_steps']:
        print(f"\n☕ Generando audio para {len(recipe['brewing_steps'])} pasos de preparación...")
        for i, step in enumerate(recipe['brewing_steps'], 1):
            audio_file = os.path.join(output_dir, f"brewing_step_{i:02d}.wav")
            try:
                instruction = step.get('instruction', '')
                print(f"   🎤 Generando preparación paso {i}: '{instruction[:50]}...'")
                wav = model.generate(instruction)
                ta.save(audio_file, wav, model.sr)
                generated_files.append(audio_file)
                print(f"   ✅ Preparación paso {i}: {len(wav[0]) / model.sr:.1f}s")
            except Exception as e:
                print(f"   ❌ Error en preparación paso {i}: {e}")
    
    # Generar audio para notas (si existen)
    if 'notes' in recipe and recipe['notes']:
        notes_file = os.path.join(output_dir, "notes.wav")
        try:
            print(f"\n📝 Generando audio para notas...")
            print(f"   🎤 Generando notas: '{recipe['notes'][:50]}...'")
            wav = model.generate(recipe['notes'])
            ta.save(notes_file, wav, model.sr)
            generated_files.append(notes_file)
            print(f"   ✅ Notas: {len(wav[0]) / model.sr:.1f}s")
        except Exception as e:
            print(f"   ❌ Error en notas: {e}")
    
    return generated_files

def main():
    print("🎯 Generador de Audio para Kaldi's Coffee - Single Serve")
    print("💰 Costo: GRATIS (Chatterbox TTS)")
    print("🌍 Idioma: Inglés")
    print("=" * 70)
    
    # Cargar receta específica
    recipe = load_kaldi_recipe()
    
    if not recipe:
        print("❌ No se pudo cargar la receta")
        return
    
    print(f"\n📊 Receta cargada:")
    print(f"   Título: {recipe['title']}")
    print(f"   Método: {recipe['brewing_method']}")
    print(f"   Nivel: {recipe['skill_level']}")
    print(f"   Tiempo total: {recipe['parameters']['total_brew_time_seconds']}s")
    print(f"   Pasos preparación: {len(recipe['preparation_steps'])}")
    print(f"   Pasos preparación: {len(recipe['brewing_steps'])}")
    
    # Crear estructura de directorios
    kaldi_audio_dir = create_kaldi_audio_structure()
    
    # Cargar modelo TTS
    print(f"\n🤖 Cargando modelo Chatterbox TTS...")
    try:
        torch.set_default_device('cpu')
        model = ChatterboxTTS.from_pretrained(device="cpu")
        print("✅ Modelo cargado correctamente")
    except Exception as e:
        print(f"❌ Error cargando modelo: {e}")
        return
    
    # Generar audio para la receta
    print(f"\n{'='*70}")
    print(f"🎵 GENERANDO AUDIO PARA KALDI'S COFFEE")
    print('='*70)
    
    try:
        files = generate_audio_for_kaldi_recipe(recipe, model, kaldi_audio_dir)
        
        # Resumen final
        print(f"\n{'='*70}")
        print("🎉 GENERACIÓN COMPLETADA")
        print(f"📁 Archivos generados: {len(files)}")
        print(f"📂 Directorio: {kaldi_audio_dir}")
        print("\n📁 Archivos creados:")
        for file in files:
            print(f"   ✅ {os.path.basename(file)}")
        print("\n💡 Próximos pasos:")
        print("1. Verificar archivos en Xcode")
        print("2. Probar reproducción en la app")
        print("3. Generar audio para más recetas si es necesario")
        
    except Exception as e:
        print(f"❌ Error generando audio: {e}")

if __name__ == "__main__":
    main()
